# Architecture

This document describes the architecture and design patterns used in the Habit Tracker app.

## Overview

The app follows a **service-based architecture** with clear separation between UI, business logic, and data layers.

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │ HomeScreen  │  │LoginScreen  │  │ProfileScreen│  ...     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘          │
└─────────┼────────────────┼────────────────┼─────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Business Logic                          │
│  ┌─────────────────────┐  ┌─────────────────────────┐       │
│  │   StorageService    │  │  NotificationService    │       │
│  │   (Singleton)       │  │     (Singleton)         │       │
│  └──────────┬──────────┘  └────────────┬────────────┘       │
└─────────────┼──────────────────────────┼────────────────────┘
              │                          │
              ▼                          ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │SharedPreferences│  │ Local Notifs    │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── main.dart                    # App entry point, route definitions
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # App-wide constants, defaults
│   └── theme/
│       └── app_theme.dart       # Material 3 theme configuration
├── models/
│   ├── habit.dart               # Habit data model
│   ├── habit_completion.dart    # Daily completion record
│   ├── notification_settings.dart
│   └── user.dart                # User profile model
├── screens/
│   ├── home_screen.dart         # Main dashboard
│   ├── login_screen.dart        # Authentication
│   ├── register_screen.dart     # User registration
│   ├── profile_screen.dart      # User profile view/edit
│   ├── add_habit_screen.dart    # Habit configuration
│   ├── reports_screen.dart      # Weekly progress
│   └── notifications_screen.dart # Notification settings
├── services/
│   ├── storage_service.dart     # Data persistence
│   └── notification_service.dart # Local notifications
└── widgets/
    ├── app_drawer.dart          # Navigation drawer
    ├── empty_state.dart         # Reusable empty state
    └── feedback_helper.dart     # Consistent snackbars
```

## Design Patterns

### Singleton Pattern

Both services use the singleton pattern to ensure a single instance throughout the app:

```dart
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
}
```

**Why Singleton?**
- Ensures consistent data access across screens
- Manages SharedPreferences lifecycle
- Avoids redundant initialization

### Data Models

All models follow a consistent pattern:

```dart
class Model {
  // Immutable fields
  final String id;
  final String name;

  // Constructor
  const Model({required this.id, required this.name});

  // JSON serialization
  factory Model.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  // Immutable updates
  Model copyWith({String? id, String? name}) { ... }

  // Value equality
  @override
  bool operator ==(Object other) { ... }
  @override
  int get hashCode { ... }
}
```

## State Management

The app uses Flutter's built-in state management:

### StatefulWidget + setState

Each screen manages its own state:

```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _habits = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final service = await StorageService.getInstance();
    final habits = service.getHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }
}
```

**Why setState?**
- Simple and sufficient for this app's complexity
- No external dependencies
- Easy to understand and maintain

## Data Persistence

### SharedPreferences

All data is stored locally using SharedPreferences:

| Key | Data Type | Content |
|-----|-----------|---------|
| `user_data` | JSON String | User profile |
| `habits_data` | JSON Array | List of habits |
| `completions_data` | JSON Array | Completion records |
| `notification_settings` | JSON String | Notification prefs |
| `is_logged_in` | Boolean | Session state |

### Data Flow Example

```
User taps "Complete Habit"
         │
         ▼
HomeScreen._toggleHabitCompletion()
         │
         ▼
StorageService.completeHabit(habitId, date)
         │
         ▼
SharedPreferences.setString('completions_data', json)
         │
         ▼
setState() updates UI
```

## Navigation

Uses Flutter's named route navigation:

```dart
// In main.dart
MaterialApp(
  routes: {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    // ...
  },
)

// Navigation
Navigator.pushNamed(context, '/home');
Navigator.pushReplacementNamed(context, '/login');
Navigator.pop(context);
```

## Notifications

Uses `flutter_local_notifications` with timezone support:

1. **Initialization** - Called in `main()` before app starts
2. **Permission Request** - iOS requires explicit permission
3. **Scheduling** - Daily repeating notifications at user-defined times
4. **Cancellation** - All notifications cancelled when disabled

## UI Patterns

### Consistent Empty States

Uses `EmptyState` widget:

```dart
EmptyState(
  icon: Icons.checklist,
  title: 'No habits yet',
  subtitle: 'Start building better habits',
  actionLabel: 'Add Habit',
  onAction: () => Navigator.pushNamed(context, '/add-habit'),
)
```

### Consistent Feedback

Uses `FeedbackHelper` for snackbars:

```dart
FeedbackHelper.showSuccess(context, 'Habit added');
FeedbackHelper.showError(context, 'Failed to save');
FeedbackHelper.showInfo(context, 'Notifications enabled');
```

## Testing Strategy

```
test/
├── models/           # Unit tests for data models
│   ├── habit_test.dart
│   ├── user_test.dart
│   └── notification_settings_test.dart
├── services/         # Integration tests for services
│   └── storage_service_test.dart
└── screens/          # Widget tests for UI
    └── login_screen_test.dart
```

### Running Tests

```bash
flutter test                    # All tests
flutter test test/models/       # Model tests only
flutter test --coverage         # With coverage report
```

## Future Considerations

Areas for potential improvement:

1. **State Management** - Consider Riverpod/Bloc for complex features
2. **Database** - Migrate to SQLite for larger datasets
3. **Testing** - Add integration tests with `flutter_driver`
4. **CI/CD** - Add GitHub Actions for automated testing
