import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/quiz_session.dart';

/// Repository responsible for persisting quiz sessions in Hive.
class SessionRepository {
  static const String _sessionsBoxName = 'sessions';

  Box<String>? _sessionsBox;

  Future<Box<String>> _getBox() async {
    if (_sessionsBox != null) return _sessionsBox!;
    _sessionsBox = await Hive.openBox<String>(_sessionsBoxName);
    return _sessionsBox!;
  }

  /// Load all quiz sessions from Hive.
  Future<List<QuizSession>> loadSessions() async {
    final box = await _getBox();
    final sessions = <QuizSession>[];
    for (final key in box.keys) {
      final jsonString = box.get(key);
      if (jsonString == null) continue;
      final map = json.decode(jsonString) as Map<String, dynamic>;
      sessions.add(QuizSession.fromMap(map));
    }
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Replace all stored sessions with the provided list.
  Future<void> saveSessions(List<QuizSession> sessions) async {
    final box = await _getBox();
    await box.clear();
    for (final session in sessions) {
      await box.put(session.id, json.encode(session.toMap()));
    }
  }

  /// Append a single session to the Hive box.
  Future<void> addSession(QuizSession session) async {
    final box = await _getBox();
    await box.put(session.id, json.encode(session.toMap()));
  }
}

