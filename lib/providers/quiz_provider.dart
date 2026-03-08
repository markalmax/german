import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/quiz_question.dart';
import '../models/quiz_session.dart';
import '../models/unit.dart';
import '../models/user_answer.dart';
import '../utils/constants.dart';
import '../utils/score_calculator.dart';

/// Provider responsible for quiz gameplay and question generation.
class QuizProvider extends ChangeNotifier {
  QuizSession? _currentSession;
  int _currentQuestionIndex = 0;
  bool _isQuizActive = false;

  int _remainingSeconds = QUESTION_TIME_LIMIT_SECONDS;
  Timer? _timer;
  DateTime? _questionStartTime;

  QuizSession? get currentSession => _currentSession;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isQuizActive => _isQuizActive;
  int get remainingSeconds => _remainingSeconds;

  int get totalQuestions => _currentSession?.questions.length ?? 0;

  /// Initialize a new quiz for the given unit.
  Future<void> startQuiz(
    Unit unit, {
    int questionCount = DEFAULT_QUESTIONS_PER_QUIZ,
  }) async {
    if (unit.vocabularyItems.isEmpty) return;

    _timer?.cancel();
    _remainingSeconds = QUESTION_TIME_LIMIT_SECONDS;
    _currentQuestionIndex = 0;

    final questions = generateQuestions(unit, questionCount);
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final startTime = DateTime.now();

    _currentSession = QuizSession(
      id: sessionId,
      unitId: unit.id,
      startTime: startTime,
      endTime: null,
      questions: questions,
      answers: const [],
      score: 0.0,
      duration: Duration.zero,
      isCompleted: false,
    );

    _isQuizActive = true;
    _questionStartTime = DateTime.now();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = QUESTION_TIME_LIMIT_SECONDS;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        // Time's up for this question: record as incorrect and move on.
        _handleTimeout();
      } else {
        _remainingSeconds -= 1;
        notifyListeners();
      }
    });
  }

  void _handleTimeout() {
    final question = getCurrentQuestion();
    if (!_isQuizActive || _currentSession == null || question == null) {
      _timer?.cancel();
      return;
    }

    final secondsTaken =
        QUESTION_TIME_LIMIT_SECONDS - _remainingSeconds + 1;

    final timeoutAnswer = UserAnswer(
      questionId: question.id,
      userAnswer: '',
      isCorrect: false,
      timeTakenSeconds: secondsTaken.clamp(0, QUESTION_TIME_LIMIT_SECONDS),
    );

    final updatedAnswers = List<UserAnswer>.from(_currentSession!.answers)
      ..add(timeoutAnswer);
    _currentSession =
        _currentSession!.copyWith(answers: updatedAnswers);

    nextQuestion();
  }

  /// Generate randomized questions for the given unit.
  List<QuizQuestion> generateQuestions(Unit unit, int count) {
    final items = [...unit.vocabularyItems];
    items.shuffle();
    if (items.isEmpty) return const [];

    // Ensure we have enough items to build distractors.
    final allItems = [...items];

    final questions = <QuizQuestion>[];
    for (var i = 0; i < count; i++) {
      final item = items[i % items.length];
      final typeIndex = i % 5;
      final type = QuizQuestionType.values[typeIndex];

      final id =
          '${item.id}_${DateTime.now().microsecondsSinceEpoch}_$i';

      switch (type) {
        case QuizQuestionType.multipleChoice:
          final options = _buildEnglishOptions(item, allItems);
          questions.add(
            QuizQuestion(
              id: id,
              vocabularyItemId: item.id,
              questionType: QuizQuestionType.multipleChoice,
              germanWord: item.germanWord,
              englishTranslation: item.englishTranslation,
              options: options,
              correctAnswer: item.englishTranslation,
            ),
          );
          break;
        case QuizQuestionType.trueFalse:
          final isTrue = i.isEven;
          final wrong = _pickDifferentEnglish(item, allItems) ??
              item.englishTranslation;
          final statement =
              isTrue ? item.englishTranslation : wrong;
          questions.add(
            QuizQuestion(
              id: id,
              vocabularyItemId: item.id,
              questionType: QuizQuestionType.trueFalse,
              germanWord: item.germanWord,
              englishTranslation: statement,
              options: const ['True', 'False'],
              correctAnswer: isTrue ? 'True' : 'False',
            ),
          );
          break;
        case QuizQuestionType.translateToEnglish:
          questions.add(
            QuizQuestion(
              id: id,
              vocabularyItemId: item.id,
              questionType: QuizQuestionType.translateToEnglish,
              germanWord: item.germanWord,
              englishTranslation: item.englishTranslation,
              options: const [],
              correctAnswer: item.englishTranslation,
            ),
          );
          break;
        case QuizQuestionType.translateToGerman:
          questions.add(
            QuizQuestion(
              id: id,
              vocabularyItemId: item.id,
              questionType: QuizQuestionType.translateToGerman,
              germanWord: item.germanWord,
              englishTranslation: item.englishTranslation,
              options: const [],
              correctAnswer: item.germanWord,
            ),
          );
          break;
        case QuizQuestionType.fillBlank:
          final sentence = item.exampleSentence.isNotEmpty
              ? item.exampleSentence
              : '${item.germanWord} ...';
          final blanked = sentence.replaceAll(
            item.germanWord,
            '____',
          );
          final opts = _buildGermanOptions(item, allItems);
          questions.add(
            QuizQuestion(
              id: id,
              vocabularyItemId: item.id,
              questionType: QuizQuestionType.fillBlank,
              germanWord: blanked,
              englishTranslation: item.exampleTranslation,
              options: opts,
              correctAnswer: item.germanWord,
            ),
          );
          break;
      }
    }

    questions.shuffle();
    return questions;
  }

  List<String> _buildEnglishOptions(
    dynamic item,
    List<dynamic> allItems,
  ) {
    final options = <String>{item.englishTranslation};
    final others = [...allItems]..shuffle();
    for (final other in others) {
      if (other.id == item.id) continue;
      options.add(other.englishTranslation);
      if (options.length >= 4) break;
    }
    return options.toList()..shuffle();
  }

  List<String> _buildGermanOptions(
    dynamic item,
    List<dynamic> allItems,
  ) {
    final options = <String>{item.germanWord};
    final others = [...allItems]..shuffle();
    for (final other in others) {
      if (other.id == item.id) continue;
      options.add(other.germanWord);
      if (options.length >= 4) break;
    }
    return options.toList()..shuffle();
  }

  String? _pickDifferentEnglish(
    dynamic item,
    List<dynamic> allItems,
  ) {
    final candidates = allItems
        .where((other) => other.id != item.id)
        .toList()
      ..shuffle();
    if (candidates.isEmpty) return null;
    return candidates.first.englishTranslation;
  }

  /// Record the user's answer for the current question.
  void submitAnswer(String questionId, String userAnswer) {
    if (!_isQuizActive || _currentSession == null) return;

    final question = getCurrentQuestion();
    if (question == null || question.id != questionId) return;

    final now = DateTime.now();
    final elapsed = _questionStartTime != null
        ? now.difference(_questionStartTime!).inSeconds
        : (QUESTION_TIME_LIMIT_SECONDS - _remainingSeconds);
    final secondsTaken =
        elapsed.clamp(0, QUESTION_TIME_LIMIT_SECONDS);

    final isCorrect = _isAnswerCorrect(question, userAnswer);
    final answer = UserAnswer(
      questionId: question.id,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      timeTakenSeconds: secondsTaken,
    );

    final updatedAnswers = List<UserAnswer>.from(
      _currentSession!.answers.where(
        (a) => a.questionId != question.id,
      ),
    )..add(answer);

    _currentSession =
        _currentSession!.copyWith(answers: updatedAnswers);

    notifyListeners();
  }

  bool _isAnswerCorrect(QuizQuestion question, String userAnswer) {
    final normalizedUser = userAnswer.trim().toLowerCase();
    switch (question.questionType) {
      case QuizQuestionType.multipleChoice:
      case QuizQuestionType.translateToEnglish:
      case QuizQuestionType.translateToGerman:
      case QuizQuestionType.fillBlank:
        return normalizedUser ==
            question.correctAnswer.trim().toLowerCase();
      case QuizQuestionType.trueFalse:
        final isTrue = normalizedUser == 'true';
        final isFalse = normalizedUser == 'false';
        if (!isTrue && !isFalse) return false;
        return (question.correctAnswer.toLowerCase() == 'true' &&
                isTrue) ||
            (question.correctAnswer.toLowerCase() == 'false' &&
                isFalse);
    }
  }

  /// Move to the next question or end the quiz if this was the last one.
  void nextQuestion() {
    if (_currentSession == null) return;

    if (_currentQuestionIndex + 1 >= totalQuestions) {
      unawaited(endQuiz());
      return;
    }

    _currentQuestionIndex += 1;
    _questionStartTime = DateTime.now();
    _remainingSeconds = QUESTION_TIME_LIMIT_SECONDS;
    notifyListeners();
  }

  QuizQuestion? getCurrentQuestion() {
    if (_currentSession == null ||
        _currentSession!.questions.isEmpty) {
      return null;
    }
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _currentSession!.questions.length) {
      return null;
    }
    return _currentSession!.questions[_currentQuestionIndex];
  }

  int getCurrentQuestionIndex() => _currentQuestionIndex;

  /// Finalize the current quiz session.
  Future<void> endQuiz() async {
    _timer?.cancel();
    if (_currentSession == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(_currentSession!.startTime);
    final completedSession = _currentSession!.copyWith(
      endTime: endTime,
      duration: duration,
      score: calculateScore(_currentSession!),
      isCompleted: true,
    );

    _currentSession = completedSession;
    _isQuizActive = false;
    notifyListeners();
  }

  /// Compute the final score (0–100) for a given session.
  double calculateScore(QuizSession session) {
    return calculateQuizScore(session);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

