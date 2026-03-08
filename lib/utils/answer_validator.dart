/// Validates user's typed answer against expected translation.
/// Supports comma-separated alternatives (e.g. "hallo,hi" accepts both).
bool validateAnswer(String userAnswer, String expectedAnswer) {
  final normalized = userAnswer.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  final alternatives = expectedAnswer
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .where((s) => s.isNotEmpty);

  return alternatives.any((alt) => alt == normalized);
}
