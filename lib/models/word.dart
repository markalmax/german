class Word {
  final String native;
  final String target;

  const Word({
    required this.native,
    required this.target,
  });

  Map<String, dynamic> toMap() {
    return {
      'native': native,
      'target': target,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      native: map['native'] as String,
      target: map['target'] as String,
    );
  }

  Word copyWith({String? native, String? target}) {
    return Word(
      native: native ?? this.native,
      target: target ?? this.target,
    );
  }
}
