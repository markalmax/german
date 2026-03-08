import '../models/quiz_session.dart';

/// Calculate the quiz score as a percentage in the range 0–100.
double calculateQuizScore(QuizSession session) {
  if (session.questions.isEmpty) return 0.0;
  final correctCount =
      session.answers.where((a) => a.isCorrect).length;
  return correctCount / session.questions.length * 100.0;
}

/// Return a short rating label for a given score.
String getScoreRating(double score) {
  if (score >= 90) return 'Excellent';
  if (score >= 75) return 'Good';
  if (score >= 60) return 'Fair';
  return 'Need practice';
}

/// Return an encouraging or constructive performance message.
String getPerformanceMessage(double score) {
  if (score >= 90) {
    return 'Outstanding work! Your German vocabulary is very strong.';
  } else if (score >= 75) {
    return 'Great job! A bit more practice will make you fluent with this unit.';
  } else if (score >= 60) {
    return 'You are getting there. Review the missed words and try again.';
  } else {
    return 'Every expert started where you are now. Keep practicing!';
  }
}

