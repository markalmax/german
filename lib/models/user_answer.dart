class UserAnswer {
  final String questionId;
  final String userAnswer;
  final bool isCorrect;
  final int timeTakenSeconds;

  const UserAnswer({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeTakenSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timeTakenSeconds': timeTakenSeconds,
    };
  }

  factory UserAnswer.fromMap(Map<String, dynamic> map) {
    return UserAnswer(
      questionId: map['questionId'] as String,
      userAnswer: map['userAnswer'] as String? ?? '',
      isCorrect: map['isCorrect'] as bool? ?? false,
      timeTakenSeconds: (map['timeTakenSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}

