import 'package:flutter/foundation.dart';

import '../models/quiz_session.dart';
import '../models/unit.dart';
import '../models/unit_statistics.dart';
import '../models/vocabulary_item.dart';
import '../repositories/session_repository.dart';
import '../repositories/stats_repository.dart';
import '../repositories/vocab_repository.dart';
import '../utils/score_calculator.dart';

/// Provider responsible for global statistics and analytics.
class StatsProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository = SessionRepository();
  final StatsRepository _statsRepository = StatsRepository();
  final VocabRepository _vocabRepository = VocabRepository();

  List<QuizSession> _sessionsHistory = [];
  Map<String, UnitStatistics> _unitStats = {};
  double _overallAverageScore = 0.0;

  List<QuizSession> get sessionsHistory =>
      List.unmodifiable(_sessionsHistory);
  Map<String, UnitStatistics> get unitStats =>
      Map.unmodifiable(_unitStats);
  double get totalScore => _overallAverageScore;

  /// Load stats and session history from Hive.
  Future<void> init() async {
    _sessionsHistory = await _sessionRepository.loadSessions();
    final rawStats = await _statsRepository.loadStats();

    _overallAverageScore =
        (rawStats['overallAverageScore'] as num?)?.toDouble() ?? 0.0;

    final unitsMap = <String, UnitStatistics>{};
    final unitsRaw = rawStats['unitStats'] as Map<String, dynamic>? ?? {};
    for (final entry in unitsRaw.entries) {
      unitsMap[entry.key] =
          UnitStatistics.fromMap(entry.value as Map<String, dynamic>);
    }
    _unitStats = unitsMap;
    notifyListeners();
  }

  Future<void> _saveStats() async {
    final encodedUnitStats = <String, Map<String, dynamic>>{};
    for (final entry in _unitStats.entries) {
      encodedUnitStats[entry.key] = entry.value.toMap();
    }

    await _statsRepository.saveStats({
      'overallAverageScore': _overallAverageScore,
      'unitStats': encodedUnitStats,
    });
  }

  /// Record a completed quiz session and update all derived statistics.
  Future<void> recordQuizSession(QuizSession session) async {
    _sessionsHistory = [..._sessionsHistory, session];
    await _sessionRepository.addSession(session);

    // Recalculate overall average score.
    if (_sessionsHistory.isNotEmpty) {
      final total = _sessionsHistory.fold<double>(
        0.0,
        (sum, s) => sum + s.score,
      );
      _overallAverageScore = total / _sessionsHistory.length;
    }

    // Per-unit stats.
    final existing = _unitStats[session.unitId];
    final quizzesCompleted = (existing?.quizzesCompleted ?? 0) + 1;
    final previousTotal =
        (existing?.averageScore ?? 0.0) * (existing?.quizzesCompleted ?? 0);
    final newAverage = (previousTotal + session.score) / quizzesCompleted;

    final updatedUnitStats = UnitStatistics(
      unitId: session.unitId,
      quizzesCompleted: quizzesCompleted,
      averageScore: newAverage,
      lastAttemptDate: session.endTime ?? session.startTime,
      competencyLevel: existing?.competencyLevel ?? session.score,
    );

    _unitStats[session.unitId] = updatedUnitStats;

    await _saveStats();
    notifyListeners();
  }

  double getOverallScore() => _overallAverageScore;

  int getTotalQuizzesCompleted() => _sessionsHistory.length;

  double getUnitCompletionPercentage(String unitId) {
    final stats = _unitStats[unitId];
    if (stats == null) return 0.0;
    return stats.competencyLevel.clamp(0.0, 100.0);
  }

  List<QuizSession> getRecentSessions({int limit = 10}) {
    if (_sessionsHistory.length <= limit) {
      return List.unmodifiable(_sessionsHistory.reversed);
    }
    return _sessionsHistory.reversed.take(limit).toList(growable: false);
  }

  double getAverageTimePerQuestion() {
    int totalQuestions = 0;
    int totalSeconds = 0;
    for (final session in _sessionsHistory) {
      totalQuestions += session.questions.length;
      totalSeconds += session.duration.inSeconds;
    }
    if (totalQuestions == 0) return 0.0;
    return totalSeconds / totalQuestions;
  }

  /// Returns the words with the lowest success rate across all sessions.
  Future<List<VocabularyItem>> getMostMissedWords({int limit = 10}) async {
    final units = await _vocabRepository.loadUnits();
    final allItems = <String, VocabularyItem>{};
    for (final unit in units) {
      for (final item in unit.vocabularyItems) {
        allItems[item.id] = item;
      }
    }

    final missCounts = <String, int>{};
    for (final session in _sessionsHistory) {
      for (final answer in session.answers) {
        if (!answer.isCorrect) {
          final question = session.questions.firstWhere(
            (q) => q.id == answer.questionId,
            orElse: () => session.questions.first,
          );
          final vocabId = question.vocabularyItemId;
          missCounts.update(
            vocabId,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }

    final sortedIds = missCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final result = <VocabularyItem>[];
    for (final entry in sortedIds) {
      final item = allItems[entry.key];
      if (item != null) {
        result.add(item);
      }
      if (result.length >= limit) break;
    }
    return result;
  }

  Future<void> updateUnitCompetency(String unitId, double level) async {
    final existing = _unitStats[unitId];
    if (existing == null) return;
    _unitStats[unitId] = existing.copyWith(competencyLevel: level);
    await _saveStats();
    notifyListeners();
  }
}

