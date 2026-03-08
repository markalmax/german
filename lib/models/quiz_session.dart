import 'quiz_question.dart';
import 'user_answer.dart';

/// Represents a single quiz play-through for a given unit.
class QuizSession {
  final String id;
  final String unitId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<QuizQuestion> questions;
  final List<UserAnswer> answers;

  /// Final score for this session in the range 0–100.
  final double score;

  /// Total time spent in this quiz.
  final Duration duration;

  final bool isCompleted;

  const QuizSession({
    required this.id,
    required this.unitId,
    required this.startTime,
    required this.endTime,
    required this.questions,
    required this.answers,
    required this.score,
    required this.duration,
    required this.isCompleted,
  });

  QuizSession copyWith({
    String? id,
    String? unitId,
    DateTime? startTime,
    DateTime? endTime,
    List<QuizQuestion>? questions,
    List<UserAnswer>? answers,
    double? score,
    Duration? duration,
    bool? isCompleted,
  }) {
    return QuizSession(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'unitId': unitId,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'questions': questions.map((q) => q.toMap()).toList(),
      'answers': answers.map((a) => a.toMap()).toList(),
      'score': score,
      'durationMs': duration.inMilliseconds,
      'isCompleted': isCompleted,
    };
  }

  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      id: map['id'] as String,
      unitId: map['unitId'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(
        (map['startTime'] as num).toInt(),
      ),
      endTime: map['endTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['endTime'] as num).toInt(),
            )
          : null,
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
          .toList(),
      answers: (map['answers'] as List<dynamic>? ?? [])
          .map((e) => UserAnswer.fromMap(e as Map<String, dynamic>))
          .toList(),
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(
        milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0,
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

