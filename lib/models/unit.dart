import 'word.dart';

class Unit {
  final String id;
  final String name;
  final int order;
  final List<Word> words;
  final bool isCustom;
  final int timeLimitSeconds;

  const Unit({
    required this.id,
    required this.name,
    required this.order,
    required this.words,
    this.isCustom = false,
    this.timeLimitSeconds = 600,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'words': words.map((w) => w.toMap()).toList(),
      'isCustom': isCustom,
      'timeLimitSeconds': timeLimitSeconds,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map, {String? idOverride}) {
    return Unit(
      id: idOverride ?? map['id'] as String? ?? '',
      name: map['name'] as String,
      order: (map['order'] as num?)?.toInt() ?? 0,
      words: (map['words'] as List<dynamic>?)
              ?.map((w) => Word.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
      isCustom: map['isCustom'] as bool? ?? false,
      timeLimitSeconds: (map['timeLimitSeconds'] as num?)?.toInt() ?? 600,
    );
  }

  Unit copyWith({
    String? id,
    String? name,
    int? order,
    List<Word>? words,
    bool? isCustom,
    int? timeLimitSeconds,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      words: words ?? this.words,
      isCustom: isCustom ?? this.isCustom,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
    );
  }
}
