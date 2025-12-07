# Habit Tracker

A mobile application for tracking daily habits, built with Flutter as part of the Coursera Mobile App Development Capstone Project.

## Project Overview

The Habit Tracker app allows users to manage and track daily activities, view progress, and update their personal information. Users can create custom habits, mark them as complete, and view weekly progress reports.

## Features

### Core Features
- **User Authentication** - Register and login with secure validation
- **Habit Management** - Add, delete, and personalize habits with colors
- **Progress Tracking** - View daily to-do and done lists
- **Reports** - Weekly habit progress visualization
- **Notifications** - Customizable reminders for habits
- **User Profile** - View and edit personal information

### Screens
- Login/Registration
- Home (To-Do & Done lists)
- Configure Habits
- Personal Info/Profile
- Reports
- Notifications Settings

## User Stories

All user stories are tracked as GitHub Issues. See the full list:
- [View All Issues](../../issues)
- [Product Backlog](./product_backlog.md)

### By Feature Area

| Feature | Issues |
|---------|--------|
| Authentication | [#1](../../issues/1), [#2](../../issues/2), [#3](../../issues/3) |
| Home Screen | [#4](../../issues/4), [#5](../../issues/5), [#6](../../issues/6) |
| Menu/Navigation | [#7](../../issues/7), [#8](../../issues/8), [#9](../../issues/9), [#10](../../issues/10) |
| Profile | [#11](../../issues/11), [#12](../../issues/12), [#13](../../issues/13), [#14](../../issues/14) |
| Habits | [#15](../../issues/15), [#16](../../issues/16), [#17](../../issues/17) |
| Reports | [#18](../../issues/18), [#19](../../issues/19), [#20](../../issues/20) |
| Notifications | [#21](../../issues/21), [#22](../../issues/22), [#23](../../issues/23) |

## Tech Stack

- **Framework**: Flutter 3.10+
- **Language**: Dart
- **Local Storage**: SharedPreferences
- **State Management**: StatefulWidget + setState
- **Notifications**: flutter_local_notifications
- **Charts**: fl_chart

## Architecture

### Overview

The app follows a **service-based architecture** with clear separation of concerns:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Screens   │────▶│  Services   │────▶│   Models    │
│   (UI)      │     │  (Logic)    │     │   (Data)    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │
       ▼                   ▼
┌─────────────┐     ┌─────────────┐
│   Widgets   │     │SharedPrefs  │
│ (Reusable)  │     │ (Storage)   │
└─────────────┘     └─────────────┘
```

### Key Patterns

**Singleton Services**
- `StorageService` - Manages all data persistence via SharedPreferences
- `NotificationService` - Handles local notification scheduling

```dart
// Usage example
final storage = await StorageService.getInstance();
final habits = storage.getHabits();
```

**Data Flow**
1. User interacts with **Screen** (e.g., HomeScreen)
2. Screen calls **Service** methods (e.g., StorageService.addHabit)
3. Service persists/retrieves **Models** (e.g., Habit, User)
4. Screen updates UI via `setState()`

**State Management**
- Uses Flutter's built-in `StatefulWidget` + `setState()`
- Each screen manages its own state
- Services are stateless singletons

### Data Models

| Model | Purpose |
|-------|---------|
| `User` | User profile data (name, username, age, country) |
| `Habit` | Habit definition (id, name, color) |
| `HabitCompletion` | Daily completion record |
| `NotificationSettings` | Notification preferences |

### Navigation

Uses Flutter's named routes defined in `main.dart`:
- `/login` - Authentication
- `/register` - New user registration
- `/home` - Main dashboard
- `/profile` - User profile
- `/add-habit` - Configure habits
- `/reports` - Weekly progress
- `/notifications` - Notification settings

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio or VS Code with Flutter extension
- iOS Simulator / Android Emulator

### Installation
```bash
# Clone the repository
git clone https://github.com/lubmir2k/habit_tracker.git

# Navigate to project directory
cd habit_tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
habit_tracker/
├── lib/
│   ├── main.dart              # App entry point
│   ├── core/
│   │   ├── constants/         # App-wide constants
│   │   └── theme/             # Theme configuration
│   ├── models/                # Data models (Habit, User, etc.)
│   ├── screens/               # UI screens (7 screens)
│   ├── services/              # Business logic (Storage, Notifications)
│   └── widgets/               # Reusable widgets
├── test/
│   ├── models/                # Model unit tests
│   ├── services/              # Service tests
│   └── screens/               # Widget tests
├── docs/
│   ├── ARCHITECTURE.md        # Detailed architecture docs
│   ├── DEVELOPMENT_METHODOLOGY.md
│   └── PROCESS.md
└── pubspec.yaml
```

## Development

This project follows Agile methodology with user stories guiding development. See [product_backlog.md](./product_backlog.md) for sprint planning recommendations.

### Labels
- `priority: high` - Must have for MVP
- `priority: medium` - Should have
- `priority: low` - Nice to have
- `enhancement` - New feature
- `bug` - Something isn't working

## License

This project is part of the Coursera Mobile App Development Capstone Project.

## Author

Created as part of the IBM iOS and Android Mobile App Developer Professional Certificate program.
