/// Habit Tracker - A mobile app for tracking daily habits.
///
/// This is the main entry point for the Habit Tracker application.
/// Built with Flutter as part of the Coursera Mobile App Development
/// Capstone Project.
library;

import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/add_habit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reports_screen.dart';
import 'services/notification_service.dart';

/// Application entry point.
///
/// Initializes Flutter bindings and the notification service before
/// launching the app. The notification service must be initialized
/// early to handle scheduled notifications.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const HabitTrackerApp());
}

/// Root widget for the Habit Tracker application.
///
/// Configures the MaterialApp with:
/// - Material 3 theme from [AppTheme]
/// - Named routes for navigation
/// - Login screen as the initial route
///
/// ## Routes
/// - `/login` - User authentication
/// - `/register` - New user registration
/// - `/home` - Main dashboard with habit lists
/// - `/profile` - User profile view/edit
/// - `/reports` - Weekly progress charts
/// - `/notifications` - Notification settings
/// - `/add-habit` - Add/manage habits
class HabitTrackerApp extends StatelessWidget {
  /// Creates the root application widget.
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/add-habit': (context) => const AddHabitScreen(),
      },
    );
  }
}
