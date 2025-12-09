class TimeRange {
  /// Returns a tuple-like Map with 'start' and 'end' for relevant range
  /// Contextual definition: from now (inclusive) to now + 7 days (exclusive)
  static Map<String, DateTime> getRelevantRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final end = now.add(const Duration(days: 7));
    return {
      'start': start,
      'end': end,
    };
  }
}
