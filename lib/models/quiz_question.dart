enum QuizQuestionType {
  multipleChoice,
  trueFalse,
  translateToEnglish,
  translateToGerman,
  fillBlank,
}

class QuizQuestion {
  final String id;
  final String vocabularyItemId;
  final QuizQuestionType questionType;
  final String germanWord;
  final String englishTranslation;
  final List<String> options;
  final String correctAnswer;

  const QuizQuestion({
    required this.id,
    required this.vocabularyItemId,
    required this.questionType,
    required this.germanWord,
    required this.englishTranslation,
    required this.options,
    required this.correctAnswer,
  });

  QuizQuestion copyWith({
    String? id,
    String? vocabularyItemId,
    QuizQuestionType? questionType,
    String? germanWord,
    String? englishTranslation,
    List<String>? options,
    String? correctAnswer,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      vocabularyItemId: vocabularyItemId ?? this.vocabularyItemId,
      questionType: questionType ?? this.questionType,
      germanWord: germanWord ?? this.germanWord,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vocabularyItemId': vocabularyItemId,
      'questionType': questionType.name,
      'germanWord': germanWord,
      'englishTranslation': englishTranslation,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      vocabularyItemId: map['vocabularyItemId'] as String,
      questionType: QuizQuestionType.values.firstWhere(
        (t) => t.name == map['questionType'],
        orElse: () => QuizQuestionType.multipleChoice,
      ),
      germanWord: map['germanWord'] as String,
      englishTranslation: map['englishTranslation'] as String,
      options: (map['options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      correctAnswer: map['correctAnswer'] as String,
    );
  }
}

