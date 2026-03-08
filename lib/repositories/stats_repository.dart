import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/quiz_session.dart';
import '../models/unit_stats.dart';

class StatsRepository {
  static const String _sessionsBoxName = 'sessions';
  static const String _statsBoxName = 'stats';

  Box<String>? _sessionsBox;
  Box<String>? _statsBox;

  Future<void> init() async {
    _sessionsBox = await Hive.openBox<String>(_sessionsBoxName);
    _statsBox = await Hive.openBox<String>(_statsBoxName);
  }

  Future<void> saveSession(QuizSession session) async {
    if (_sessionsBox == null) return;
    final key = '${session.unitId}_${session.timestamp.millisecondsSinceEpoch}';
    await _sessionsBox!.put(key, json.encode(session.toMap()));
  }

  Future<List<QuizSession>> getSessions({String? unitId, int? limit}) async {
    if (_sessionsBox == null) return [];
    final sessions = <QuizSession>[];
    for (final key in _sessionsBox!.keys) {
      final jsonString = _sessionsBox!.get(key);
      if (jsonString != null) {
        final session = QuizSession.fromMap(json.decode(jsonString) as Map<String, dynamic>);
        if (unitId == null || session.unitId == unitId) {
          sessions.add(session);
        }
      }
    }
    sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && sessions.length > limit) {
      return sessions.take(limit).toList();
    }
    return sessions;
  }

  Future<UnitStats?> getUnitStats(String unitId) async {
    if (_statsBox == null) return null;
    final jsonString = _statsBox!.get(unitId);
    if (jsonString == null) return null;
    return UnitStats.fromMap(json.decode(jsonString) as Map<String, dynamic>);
  }

  Future<void> updateUnitStats(UnitStats stats) async {
    if (_statsBox == null) return;
    await _statsBox!.put(stats.unitId, json.encode(stats.toMap()));
  }

  Future<Map<String, UnitStats>> getAllStats() async {
    if (_statsBox == null) return {};
    final map = <String, UnitStats>{};
    for (final key in _statsBox!.keys) {
      final jsonString = _statsBox!.get(key);
      if (jsonString != null) {
        final stats = UnitStats.fromMap(json.decode(jsonString) as Map<String, dynamic>);
        map[stats.unitId] = stats;
      }
    }
    return map;
  }
}
