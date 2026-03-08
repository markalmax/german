class UnitStatistics {
  final String unitId;

  /// Number of quizzes completed for this unit.
  final int quizzesCompleted;

  /// Average score across all quizzes for this unit (0–100).
  final double averageScore;

  /// Last time the unit was attempted.
  final DateTime? lastAttemptDate;

  /// Overall competency level for this unit (0–100).
  final double competencyLevel;

  const UnitStatistics({
    required this.unitId,
    required this.quizzesCompleted,
    required this.averageScore,
    required this.lastAttemptDate,
    required this.competencyLevel,
  });

  UnitStatistics copyWith({
    String? unitId,
    int? quizzesCompleted,
    double? averageScore,
    DateTime? lastAttemptDate,
    double? competencyLevel,
  }) {
    return UnitStatistics(
      unitId: unitId ?? this.unitId,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      averageScore: averageScore ?? this.averageScore,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      competencyLevel: competencyLevel ?? this.competencyLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'quizzesCompleted': quizzesCompleted,
      'averageScore': averageScore,
      'lastAttemptDate': lastAttemptDate?.millisecondsSinceEpoch,
      'competencyLevel': competencyLevel,
    };
  }

  factory UnitStatistics.fromMap(Map<String, dynamic> map) {
    return UnitStatistics(
      unitId: map['unitId'] as String,
      quizzesCompleted: (map['quizzesCompleted'] as num?)?.toInt() ?? 0,
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
      lastAttemptDate: map['lastAttemptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastAttemptDate'] as num).toInt(),
            )
          : null,
      competencyLevel:
          (map['competencyLevel'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

