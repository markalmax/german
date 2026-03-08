import 'vocabulary_item.dart';

/// Represents a vocabulary learning unit, such as "Food & Drink".
class Unit {
  final String id;
  final String name;
  final String description;
  final List<VocabularyItem> vocabularyItems;
  final DateTime createdAt;
  final bool isCompleted;

  /// Competency level for this unit in the range 0–100.
  final double competencyLevel;

  const Unit({
    required this.id,
    required this.name,
    this.description = '',
    required this.vocabularyItems,
    required this.createdAt,
    this.isCompleted = false,
    this.competencyLevel = 0.0,
  });

  Unit copyWith({
    String? id,
    String? name,
    String? description,
    List<VocabularyItem>? vocabularyItems,
    DateTime? createdAt,
    bool? isCompleted,
    double? competencyLevel,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      vocabularyItems: vocabularyItems ?? this.vocabularyItems,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      competencyLevel: competencyLevel ?? this.competencyLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'vocabularyItems': vocabularyItems.map((v) => v.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'competencyLevel': competencyLevel,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      vocabularyItems: (map['vocabularyItems'] as List<dynamic>? ?? [])
          .map(
            (e) => VocabularyItem.fromMap(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num).toInt(),
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
      competencyLevel:
          (map['competencyLevel'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

