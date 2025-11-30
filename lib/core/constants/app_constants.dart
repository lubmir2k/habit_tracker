/// Application-wide constants for the Habit Tracker app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Habit Tracker';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String habitsDataKey = 'habits_data';
  static const String completionsDataKey = 'completions_data';

  // Default Test Credentials (course requirement)
  static const String defaultUsername = 'testuser';
  static const String defaultPassword = 'password123';

  // Validation
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int minAge = 1;
  static const int maxAge = 120;

  // Prebuilt Habits
  static const List<String> prebuiltHabits = [
    'Exercise',
    'Read',
    'Meditate',
    'Drink Water',
  ];

  // Default Habit Colors (as int values for storage)
  static const List<int> defaultHabitColors = [
    0xFFE53935, // Red
    0xFF1E88E5, // Blue
    0xFF43A047, // Green
    0xFFFDD835, // Yellow
    0xFF8E24AA, // Purple
    0xFFFF9800, // Orange
  ];
}
