import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/unit.dart';
import '../models/word.dart';
import '../models/quiz_session.dart';
import '../utils/answer_validator.dart';

enum QuizDirection { nativeToTarget, targetToNative }

class QuizState {
  final int remainingSeconds;
  final Word? currentWord;
  final QuizDirection direction;
  final int correctCount;
  final int totalAttempts;
  final bool? lastCorrect; // null = no answer yet
  final bool isActive;

  const QuizState({
    this.remainingSeconds = 600, // 10 minutes
    this.currentWord,
    this.direction = QuizDirection.nativeToTarget,
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.lastCorrect,
    this.isActive = false,
  });

  QuizState copyWith({
    int? remainingSeconds,
    Word? currentWord,
    QuizDirection? direction,
    int? correctCount,
    int? totalAttempts,
    bool? lastCorrect,
    bool clearLastCorrect = false,
    bool? isActive,
  }) {
    return QuizState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentWord: currentWord ?? this.currentWord,
      direction: direction ?? this.direction,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastCorrect: clearLastCorrect ? null : (lastCorrect ?? this.lastCorrect),
      isActive: isActive ?? this.isActive,
    );
  }
}

class QuizProvider extends ChangeNotifier {
  QuizState _state = const QuizState();
  Timer? _timer;
  List<Word> _wordPool = [];
  int _wordIndex = 0;
  Unit? _currentUnit;
  int _quizDurationSeconds = 600;

  QuizState get state => _state;
  Unit? get currentUnit => _currentUnit;

  void startQuiz(Unit unit) {
    if (unit.words.isEmpty) return;

    _currentUnit = unit;
    _quizDurationSeconds = unit.timeLimitSeconds;
    _wordPool = List.from(unit.words)..shuffle();
    _wordIndex = 0;

    _state = QuizState(
      remainingSeconds: _quizDurationSeconds,
      currentWord: _wordPool.isNotEmpty ? _wordPool[0] : null,
      direction: QuizDirection.nativeToTarget,
      correctCount: 0,
      totalAttempts: 0,
      lastCorrect: null,
      isActive: true,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_state.remainingSeconds <= 0) {
      _timer?.cancel();
      _state = _state.copyWith(isActive: false);
      notifyListeners();
      return;
    }
    _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (!_state.isActive || _state.currentWord == null) return;

    final word = _state.currentWord!;
    final expected = _state.direction == QuizDirection.nativeToTarget
        ? word.target
        : word.native;
    final correct = validateAnswer(answer, expected);

    _state = _state.copyWith(
      correctCount: _state.correctCount + (correct ? 1 : 0),
      totalAttempts: _state.totalAttempts + 1,
      lastCorrect: correct,
    );

    _advanceToNextWord();
    notifyListeners();
  }

  void skipWord() {
    if (!_state.isActive) return;
    _state = _state.copyWith(
      totalAttempts: _state.totalAttempts + 1,
      lastCorrect: false,
    );
    _advanceToNextWord();
    notifyListeners();
  }

  void _advanceToNextWord() {
    if (_state.remainingSeconds <= 0) return;

    _wordIndex++;
    // End quiz if all words have been shown
    if (_wordIndex >= _wordPool.length) {
      _timer?.cancel();
      _state = _state.copyWith(isActive: false);
      return;
    }
    
    final nextWord = _wordPool[_wordIndex];
    _state = _state.copyWith(
      currentWord: nextWord,
      direction: QuizDirection.nativeToTarget,
      clearLastCorrect: true,
    );
  }

  QuizSession? finishQuiz() {
    _timer?.cancel();
    if (_currentUnit == null) return null;

    final session = QuizSession(
      unitId: _currentUnit!.id,
      timestamp: DateTime.now(),
      correctCount: _state.correctCount,
      totalAttempts: _state.totalAttempts,
      durationSeconds: _quizDurationSeconds - _state.remainingSeconds,
    );

    _state = const QuizState();
    _currentUnit = null;
    _wordPool = [];
    notifyListeners();

    return session;
  }

  void reset() {
    _timer?.cancel();
    _state = const QuizState();
    _currentUnit = null;
    _wordPool = [];
    _wordIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
