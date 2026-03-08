import '../models/quiz_question.dart';

/// Default number of questions per quiz.
const int DEFAULT_QUESTIONS_PER_QUIZ = 10;

/// Time limit per question in seconds.
const int QUESTION_TIME_LIMIT_SECONDS = 30;

/// Maximum number of vocabulary items allowed per unit.
const int MAX_VOCABULARY_PER_UNIT = 100;

/// Desired distribution of question types within a quiz.
///
/// These are soft targets used when generating questions.
const Map<QuizQuestionType, double> QUESTION_TYPE_DISTRIBUTION = {
  QuizQuestionType.multipleChoice: 0.4,
  QuizQuestionType.translateToEnglish: 0.2,
  QuizQuestionType.translateToGerman: 0.2,
  QuizQuestionType.trueFalse: 0.1,
  QuizQuestionType.fillBlank: 0.1,
};

