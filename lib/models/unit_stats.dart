class UnitStats {
  final String unitId;
  final int bestScore;
  final int bestTime; // best score achieved in this many seconds
  final int totalSessions;

  const UnitStats({
    required this.unitId,
    required this.bestScore,
    required this.bestTime,
    required this.totalSessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'bestScore': bestScore,
      'bestTime': bestTime,
      'totalSessions': totalSessions,
    };
  }

  factory UnitStats.fromMap(Map<String, dynamic> map) {
    return UnitStats(
      unitId: map['unitId'] as String,
      bestScore: map['bestScore'] as int? ?? 0,
      bestTime: map['bestTime'] as int? ?? 0,
      totalSessions: map['totalSessions'] as int? ?? 0,
    );
  }

  UnitStats copyWith({
    String? unitId,
    int? bestScore,
    int? bestTime,
    int? totalSessions,
  }) {
    return UnitStats(
      unitId: unitId ?? this.unitId,
      bestScore: bestScore ?? this.bestScore,
      bestTime: bestTime ?? this.bestTime,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
