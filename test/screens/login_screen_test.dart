import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/screens/login_screen.dart';
import 'package:habit_tracker/services/storage_service.dart';
import 'package:habit_tracker/core/constants/app_constants.dart';

void main() {
  setUp(() {
    StorageService.resetInstance();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestApp({Widget? home}) {
    return MaterialApp(
      home: home ?? const LoginScreen(),
      routes: {
        '/home': (context) => const Scaffold(body: Text('Home Screen')),
        '/register': (context) => const Scaffold(body: Text('Register Screen')),
        '/login': (context) => const LoginScreen(),
      },
    );
  }

  group('LoginScreen', () {
    group('UI elements', () {
      testWidgets('displays app name', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text(AppConstants.appName), findsOneWidget);
      });

      testWidgets('displays welcome message', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text('Welcome back!'), findsOneWidget);
      });

      testWidgets('displays username field', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      });

      testWidgets('displays password field', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      });

      testWidgets('displays login button', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      });

      testWidgets('displays sign up link', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text("Don't have an account? "), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
      });

      testWidgets('displays test credentials hint', (tester) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text('Test Credentials'), findsOneWidget);
        expect(
            find.text('Username: ${AppConstants.defaultUsername}'), findsOneWidget);
        expect(
            find.text('Password: ${AppConstants.defaultPassword}'), findsOneWidget);
      });
    });

    group('Form validation', () {
      testWidgets('shows error for empty username', (tester) async {
        await tester.pumpWidget(createTestApp());

        // Tap login without entering anything
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text('Username is required'), findsOneWidget);
      });

      testWidgets('shows error for empty password', (tester) async {
        await tester.pumpWidget(createTestApp());

        // Enter username but not password
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Username'), 'testuser');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('no validation error with valid input', (tester) async {
        await tester.pumpWidget(createTestApp());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Username'), 'testuser');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pump();

        expect(find.text('Username is required'), findsNothing);
        expect(find.text('Password is required'), findsNothing);
      });
    });

    group('Password visibility', () {
      testWidgets('password is obscured by default', (tester) async {
        await tester.pumpWidget(createTestApp());

        final passwordField = tester.widget<TextField>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Password'),
            matching: find.byType(TextField),
          ),
        );

        expect(passwordField.obscureText, isTrue);
      });

      testWidgets('tapping visibility icon toggles password visibility',
          (tester) async {
        await tester.pumpWidget(createTestApp());

        // Initially obscured
        var passwordField = tester.widget<TextField>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Password'),
            matching: find.byType(TextField),
          ),
        );
        expect(passwordField.obscureText, isTrue);

        // Tap visibility icon
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Now visible
        passwordField = tester.widget<TextField>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Password'),
            matching: find.byType(TextField),
          ),
        );
        expect(passwordField.obscureText, isFalse);

        // Tap again
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Obscured again
        passwordField = tester.widget<TextField>(
          find.descendant(
            of: find.widgetWithText(TextFormField, 'Password'),
            matching: find.byType(TextField),
          ),
        );
        expect(passwordField.obscureText, isTrue);
      });
    });

    group('Navigation', () {
      testWidgets('tapping Sign Up navigates to register screen',
          (tester) async {
        await tester.pumpWidget(createTestApp());

        await tester.tap(find.widgetWithText(TextButton, 'Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Register Screen'), findsOneWidget);
      });
    });

    group('Login flow', () {
      testWidgets('successful login with default credentials navigates to home',
          (tester) async {
        await tester.pumpWidget(createTestApp());

        await tester.enterText(find.widgetWithText(TextFormField, 'Username'),
            AppConstants.defaultUsername);
        await tester.enterText(find.widgetWithText(TextFormField, 'Password'),
            AppConstants.defaultPassword);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text('Home Screen'), findsOneWidget);
      });

      testWidgets('shows error snackbar for invalid credentials',
          (tester) async {
        await tester.pumpWidget(createTestApp());

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Username'), 'wronguser');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'wrongpass');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid username or password'), findsOneWidget);
        // Still on login screen
        expect(find.text('Welcome back!'), findsOneWidget);
      });

      testWidgets('login button is enabled before submitting', (tester) async {
        await tester.pumpWidget(createTestApp());

        // Verify button is enabled before login
        final button = tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Login'));
        expect(button.onPressed, isNotNull);
      });
    });
  });
}
