class VocabularyItem {
  final String id;
  final String germanWord;
  final String englishTranslation;
  final String exampleSentence;
  final String exampleTranslation;
  final String partOfSpeech;

  /// Difficulty level from 1 (easiest) to 5 (hardest).
  final int difficultyLevel;

  /// Last time this item was reviewed in a quiz.
  final DateTime? lastReviewedAt;

  /// Total number of times this item has been reviewed.
  final int reviewCount;

  /// Success rate for this item in the range 0–100.
  final double successRate;

  const VocabularyItem({
    required this.id,
    required this.germanWord,
    required this.englishTranslation,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.partOfSpeech,
    this.difficultyLevel = 1,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.successRate = 0.0,
  });

  VocabularyItem copyWith({
    String? id,
    String? germanWord,
    String? englishTranslation,
    String? exampleSentence,
    String? exampleTranslation,
    String? partOfSpeech,
    int? difficultyLevel,
    DateTime? lastReviewedAt,
    int? reviewCount,
    double? successRate,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      germanWord: germanWord ?? this.germanWord,
      englishTranslation: englishTranslation ?? this.englishTranslation,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      successRate: successRate ?? this.successRate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'germanWord': germanWord,
      'englishTranslation': englishTranslation,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'partOfSpeech': partOfSpeech,
      'difficultyLevel': difficultyLevel,
      'lastReviewedAt': lastReviewedAt?.millisecondsSinceEpoch,
      'reviewCount': reviewCount,
      'successRate': successRate,
    };
  }

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'] as String,
      germanWord: map['germanWord'] as String,
      englishTranslation: map['englishTranslation'] as String,
      exampleSentence: map['exampleSentence'] as String? ?? '',
      exampleTranslation: map['exampleTranslation'] as String? ?? '',
      partOfSpeech: map['partOfSpeech'] as String? ?? '',
      difficultyLevel: (map['difficultyLevel'] as num?)?.toInt() ?? 1,
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastReviewedAt'] as num).toInt(),
            )
          : null,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      successRate: (map['successRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

