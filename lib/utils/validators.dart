bool isValidGermanWord(String word) {
  final trimmed = word.trim();
  if (trimmed.isEmpty) return false;
  // Very light validation: allow letters, umlauts, ß and spaces/hyphens.
  final regex = RegExp(r"^[A-Za-zÄÖÜäöüß\-\s']+$");
  return regex.hasMatch(trimmed);
}

bool isValidEnglishTranslation(String translation) {
  final trimmed = translation.trim();
  if (trimmed.isEmpty) return false;
  // Allow basic Latin letters, punctuation and spaces.
  final regex = RegExp(r"^[A-Za-z0-9 ,.'!?-]+$");
  return regex.hasMatch(trimmed);
}

