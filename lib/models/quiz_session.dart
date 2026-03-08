class QuizSession {
  final String unitId;
  final DateTime timestamp;
  final int correctCount;
  final int totalAttempts;
  final int durationSeconds;

  const QuizSession({
    required this.unitId,
    required this.timestamp,
    required this.correctCount,
    required this.totalAttempts,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'unitId': unitId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'durationSeconds': durationSeconds,
    };
  }

  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      unitId: map['unitId'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      correctCount: map['correctCount'] as int,
      totalAttempts: map['totalAttempts'] as int,
      durationSeconds: map['durationSeconds'] as int,
    );
  }
}
