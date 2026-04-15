import 'package:flutter/foundation.dart';

import '../models/quiz_session.dart';
import '../models/unit_stats.dart';
import '../repositories/stats_repository.dart';

class StatsProvider extends ChangeNotifier {
  final StatsRepository _repo = StatsRepository();

  List<QuizSession> _sessions = [];
  Map<String, UnitStats> _statsByUnit = {};
  bool _loaded = false;

  List<QuizSession> get sessions => List.unmodifiable(_sessions);
  Map<String, UnitStats> get statsByUnit => Map.unmodifiable(_statsByUnit);
  bool get isLoaded => _loaded;

  Future<void> init() async {
    await _repo.init();
  }

  Future<void> loadSessions({String? unitId, int limit = 50}) async {
    _sessions = await _repo.getSessions(unitId: unitId, limit: limit);
    notifyListeners();
  }

  Future<void> loadAllStats() async {
    _statsByUnit = await _repo.getAllStats();
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveSession(QuizSession session) async {
    await _repo.saveSession(session);

    final existing = _statsByUnit[session.unitId];
    final newStats = UnitStats(
      unitId: session.unitId,
      bestScore: existing != null
          ? (session.correctCount > existing.bestScore
              ? session.correctCount
              : existing.bestScore)
          : session.correctCount,
      bestTime: existing != null
          ? (session.correctCount > existing.bestScore
              ? session.durationSeconds
              : (session.correctCount == existing.bestScore && session.durationSeconds < existing.bestTime
                  ? session.durationSeconds
                  : existing.bestTime))
          : session.durationSeconds,
      totalSessions: (existing?.totalSessions ?? 0) + 1,
    );
    await _repo.updateUnitStats(newStats);
    _statsByUnit[session.unitId] = newStats;

    await loadSessions();
    notifyListeners();
  }

  UnitStats? getStatsForUnit(String unitId) => _statsByUnit[unitId];

  List<QuizSession> getSessionsForUnit(String unitId) {
    return _sessions.where((s) => s.unitId == unitId).toList();
  }

  Future<String> exportData() async {
    return await _repo.exportData();
  }

  Future<bool> importData(String jsonString) async {
    final success = await _repo.importData(jsonString);
    if (success) {
      await loadAllStats();
      await loadSessions(limit: 100);
    }
    return success;
  }

  Future<String> exportSession(QuizSession session) async {
    return await _repo.exportSession(session);
  }
}
