import 'package:cloud_firestore/cloud_firestore.dart';

import 'unit.dart';

enum LiveGameStatus { lobby, live, finished }

LiveGameStatus liveGameStatusFromString(String value) {
  switch (value) {
    case 'lobby':
      return LiveGameStatus.lobby;
    case 'live':
      return LiveGameStatus.live;
    case 'finished':
      return LiveGameStatus.finished;
    default:
      return LiveGameStatus.lobby;
  }
}

String liveGameStatusToString(LiveGameStatus value) {
  switch (value) {
    case LiveGameStatus.lobby:
      return 'lobby';
    case LiveGameStatus.live:
      return 'live';
    case LiveGameStatus.finished:
      return 'finished';
  }
}

class LiveGameSession {
  final String id;
  final String roomCode;
  final String hostUid;
  final LiveGameStatus status;
  final Unit unitSnapshot;
  final int shuffleSeed;
  final int durationSeconds;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime createdAt;

  const LiveGameSession({
    required this.id,
    required this.roomCode,
    required this.hostUid,
    required this.status,
    required this.unitSnapshot,
    required this.shuffleSeed,
    required this.durationSeconds,
    required this.startsAt,
    required this.endsAt,
    required this.createdAt,
  });

  Map<String, dynamic> toCreateMap() {
    return {
      'roomCode': roomCode,
      'hostUid': hostUid,
      'status': liveGameStatusToString(status),
      'unitSnapshot': unitSnapshot.toMap(),
      'shuffleSeed': shuffleSeed,
      'durationSeconds': durationSeconds,
      'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt!),
      'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LiveGameSession.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return LiveGameSession(
      id: doc.id,
      roomCode: (data['roomCode'] as String?) ?? '',
      hostUid: (data['hostUid'] as String?) ?? '',
      status: liveGameStatusFromString((data['status'] as String?) ?? 'lobby'),
      unitSnapshot:
          Unit.fromMap((data['unitSnapshot'] as Map<String, dynamic>?) ?? {}),
      shuffleSeed: (data['shuffleSeed'] as num?)?.toInt() ?? 0,
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      startsAt: (data['startsAt'] as Timestamp?)?.toDate(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate(),
      createdAt:
          ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }
}

class LiveGamePlayer {
  final String uid;
  final String displayName;
  final int score;
  final int correctCount;
  final int totalAttempts;
  final DateTime? lastAnswerAt;
  final Map<String, int> wrongByWordKey;

  const LiveGamePlayer({
    required this.uid,
    required this.displayName,
    required this.score,
    required this.correctCount,
    required this.totalAttempts,
    required this.lastAnswerAt,
    required this.wrongByWordKey,
  });

  Map<String, dynamic> toCreateMap() {
    return {
      'displayName': displayName,
      'score': score,
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'lastAnswerAt':
          lastAnswerAt == null ? null : Timestamp.fromDate(lastAnswerAt!),
      'wrongByWordKey': wrongByWordKey,
    };
  }

  factory LiveGamePlayer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final wrongRaw = data['wrongByWordKey'];
    return LiveGamePlayer(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      correctCount: (data['correctCount'] as num?)?.toInt() ?? 0,
      totalAttempts: (data['totalAttempts'] as num?)?.toInt() ?? 0,
      lastAnswerAt: (data['lastAnswerAt'] as Timestamp?)?.toDate(),
      wrongByWordKey: wrongRaw is Map
          ? wrongRaw.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            )
          : <String, int>{},
    );
  }
}

