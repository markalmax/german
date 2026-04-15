import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/live_game.dart';
import '../models/unit.dart';

class LiveGameRepository {
  final FirebaseFirestore _firestore;
  final fb_auth.FirebaseAuth _auth;

  LiveGameRepository({
    FirebaseFirestore? firestore,
    fb_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb_auth.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('live_sessions');

  Future<fb_auth.User> ensureSignedInAnonymously() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  String _generateRoomCode({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  int _generateSeed() => Random.secure().nextInt(1 << 31);

  Future<LiveGameSession> createLobby({required Unit unit}) async {
    final user = await ensureSignedInAnonymously();
    final roomCode = _generateRoomCode();
    final seed = _generateSeed();

    final doc = _sessions.doc();
    final session = LiveGameSession(
      id: doc.id,
      roomCode: roomCode,
      hostUid: user.uid,
      status: LiveGameStatus.lobby,
      unitSnapshot: unit,
      shuffleSeed: seed,
      durationSeconds: unit.timeLimitSeconds,
      startsAt: null,
      endsAt: null,
      createdAt: DateTime.now(),
    );

    await doc.set({
      ...session.toCreateMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Host joins as a player too (useful for debugging / optional host play).
    await doc.collection('players').doc(user.uid).set(
          LiveGamePlayer(
            uid: user.uid,
            displayName: 'Host',
            score: 0,
            correctCount: 0,
            totalAttempts: 0,
            lastAnswerAt: null,
            wrongByWordKey: const {},
          ).toCreateMap(),
          SetOptions(merge: true),
        );

    return session;
  }

  Stream<LiveGameSession> watchSession(String sessionId) {
    return _sessions
        .doc(sessionId)
        .snapshots()
        .map((doc) => LiveGameSession.fromDoc(doc));
  }

  Future<LiveGameSession?> findByRoomCode(String roomCode) async {
    final snap = await _sessions.where('roomCode', isEqualTo: roomCode).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return LiveGameSession.fromDoc(snap.docs.first);
  }

  Stream<List<LiveGamePlayer>> watchLeaderboard(String sessionId) {
    return _sessions
        .doc(sessionId)
        .collection('players')
        .orderBy('score', descending: true)
        .orderBy('lastAnswerAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => LiveGamePlayer.fromDoc(d)).toList(),
        );
  }

  Future<void> joinSession({
    required String sessionId,
    required String displayName,
  }) async {
    final user = await ensureSignedInAnonymously();
    final doc = _sessions.doc(sessionId).collection('players').doc(user.uid);
    await doc.set(
      LiveGamePlayer(
        uid: user.uid,
        displayName: displayName,
        score: 0,
        correctCount: 0,
        totalAttempts: 0,
        lastAnswerAt: null,
        wrongByWordKey: const {},
      ).toCreateMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> startSession({
    required String sessionId,
    required int durationSeconds,
  }) async {
    final now = DateTime.now();
    final endsAt = now.add(Duration(seconds: durationSeconds));
    await _sessions.doc(sessionId).set(
      {
        'status': liveGameStatusToString(LiveGameStatus.live),
        'startsAt': FieldValue.serverTimestamp(),
        'endsAt': Timestamp.fromDate(endsAt),
      },
      SetOptions(merge: true),
    );
  }

  String wordKeyForUnit(Unit unit, int index) {
    // Stable key so analytics can aggregate across players.
    // Uses word content because Hive IDs are unit-level only.
    final w = unit.words[index];
    return '${index}_${w.native}|${w.target}';
  }

  Future<void> submitAttempt({
    required LiveGameSession session,
    required int wordIndex,
    required bool correct,
  }) async {
    final user = await ensureSignedInAnonymously();
    final playerRef = _sessions.doc(session.id).collection('players').doc(user.uid);
    final sessionRef = _sessions.doc(session.id);
    final wordKey = wordKeyForUnit(session.unitSnapshot, wordIndex);

    await _firestore.runTransaction((tx) async {
      final playerSnap = await tx.get(playerRef);
      final player = playerSnap.exists
          ? LiveGamePlayer.fromDoc(playerSnap)
          : LiveGamePlayer(
              uid: user.uid,
              displayName: 'Player',
              score: 0,
              correctCount: 0,
              totalAttempts: 0,
              lastAnswerAt: null,
              wrongByWordKey: const {},
            );

      final nextTotal = player.totalAttempts + 1;
      final nextCorrect = player.correctCount + (correct ? 1 : 0);
      final nextScore = player.score + (correct ? 1 : 0);

      final nextWrongMap = Map<String, int>.from(player.wrongByWordKey);
      if (!correct) {
        nextWrongMap[wordKey] = (nextWrongMap[wordKey] ?? 0) + 1;
      }

      tx.set(
        playerRef,
        {
          'score': nextScore,
          'correctCount': nextCorrect,
          'totalAttempts': nextTotal,
          'lastAnswerAt': FieldValue.serverTimestamp(),
          'wrongByWordKey': nextWrongMap,
        },
        SetOptions(merge: true),
      );

      if (!correct) {
        tx.set(
          sessionRef,
          {
            'wrongCounts': {wordKey: FieldValue.increment(1)},
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  Future<void> finishSession(String sessionId) async {
    await _sessions.doc(sessionId).set(
      {'status': liveGameStatusToString(LiveGameStatus.finished)},
      SetOptions(merge: true),
    );
  }
}

