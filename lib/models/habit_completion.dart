/// Model for tracking daily habit completions.
class HabitCompletion {
  final String habitId;
  final DateTime date;

  const HabitCompletion({
    required this.habitId,
    required this.date,
  });

  /// Get a normalized date key (YYYY-MM-DD) for storage.
  String get dateKey => formatDateKey(date);

  /// Static method to format any DateTime as a date key (YYYY-MM-DD).
  static String formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Creates a HabitCompletion from JSON map.
  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Converts HabitCompletion to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion &&
        other.habitId == habitId &&
        other.dateKey == dateKey;
  }

  @override
  int get hashCode {
    return Object.hash(habitId, dateKey);
  }
}
