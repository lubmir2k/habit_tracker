/// Application-wide constants for the Habit Tracker app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Habit Tracker';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

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
}
