import '../models/quiz_question.dart';

/// Helper to encode [DateTime] to an integer timestamp.
int encodeDateTime(DateTime dateTime) =>
    dateTime.millisecondsSinceEpoch;

/// Helper to decode [DateTime] from an integer timestamp.
DateTime decodeDateTime(num timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());

/// Helper to encode a nullable [DateTime].
int? encodeNullableDateTime(DateTime? dateTime) =>
    dateTime?.millisecondsSinceEpoch;

/// Helper to decode a nullable [DateTime].
DateTime? decodeNullableDateTime(num? timestamp) {
  if (timestamp == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
}

/// Encode a [Duration] as an integer number of milliseconds.
int encodeDuration(Duration duration) => duration.inMilliseconds;

/// Decode a [Duration] from an integer number of milliseconds.
Duration decodeDuration(num milliseconds) =>
    Duration(milliseconds: milliseconds.toInt());

/// Encode [QuizQuestionType] to a storable string.
String encodeQuestionType(QuizQuestionType type) => type.name;

/// Decode [QuizQuestionType] from a string.
QuizQuestionType decodeQuestionType(String? value) {
  if (value == null) return QuizQuestionType.multipleChoice;
  return QuizQuestionType.values.firstWhere(
    (t) => t.name == value,
    orElse: () => QuizQuestionType.multipleChoice,
  );
}

