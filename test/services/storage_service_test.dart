import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/services/storage_service.dart';
import 'package:habit_tracker/models/user.dart';
import 'package:habit_tracker/core/constants/app_constants.dart';

void main() {
  group('StorageService', () {
    setUp(() {
      StorageService.resetInstance();
      SharedPreferences.setMockInitialValues({});
    });

    group('User Data Operations', () {
      test('saves and retrieves user data', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'testuser',
          age: 25,
          country: 'USA',
          password: 'password123',
        );

        final saved = await service.saveUser(user);
        expect(saved, isTrue);

        final retrieved = service.getUser();
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test User');
        expect(retrieved.username, 'testuser');
        expect(retrieved.age, 25);
        expect(retrieved.country, 'USA');
        expect(retrieved.password, 'password123');
      });

      test('saves user with prebuilt habits', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'testuser',
          age: 25,
          country: 'USA',
          password: 'password123',
          prebuiltHabits: ['Exercise', 'Read'],
        );

        await service.saveUser(user);
        final retrieved = service.getUser();

        expect(retrieved!.prebuiltHabits, ['Exercise', 'Read']);
      });

      test('returns null when no user exists', () async {
        final service = await StorageService.getInstance();
        final user = service.getUser();
        expect(user, isNull);
      });

      test('deletes user data', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'testuser',
          age: 25,
          country: 'USA',
          password: 'password123',
        );

        await service.saveUser(user);
        expect(service.getUser(), isNotNull);

        await service.deleteUser();
        expect(service.getUser(), isNull);
      });

      test('userExists returns true for existing user', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'existinguser',
          age: 25,
          country: 'USA',
          password: 'password123',
        );

        await service.saveUser(user);
        expect(service.userExists('existinguser'), isTrue);
      });

      test('userExists returns false for non-existing user', () async {
        final service = await StorageService.getInstance();
        expect(service.userExists('nonexistent'), isFalse);
      });
    });

    group('Session Management', () {
      test('isLoggedIn returns false by default', () async {
        final service = await StorageService.getInstance();
        expect(service.isLoggedIn(), isFalse);
      });

      test('setLoggedIn updates login state', () async {
        final service = await StorageService.getInstance();

        await service.setLoggedIn(true);
        expect(service.isLoggedIn(), isTrue);

        await service.setLoggedIn(false);
        expect(service.isLoggedIn(), isFalse);
      });

      test('clearSession sets logged in to false', () async {
        final service = await StorageService.getInstance();

        await service.setLoggedIn(true);
        expect(service.isLoggedIn(), isTrue);

        await service.clearSession();
        expect(service.isLoggedIn(), isFalse);
      });
    });

    group('Authentication', () {
      test('validates correct stored user credentials', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'myuser',
          age: 25,
          country: 'USA',
          password: 'mypassword',
        );

        await service.saveUser(user);

        expect(service.validateCredentials('myuser', 'mypassword'), isTrue);
      });

      test('rejects incorrect password for stored user', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'myuser',
          age: 25,
          country: 'USA',
          password: 'mypassword',
        );

        await service.saveUser(user);

        expect(service.validateCredentials('myuser', 'wrongpassword'), isFalse);
      });

      test('validates default test credentials when no user exists', () async {
        final service = await StorageService.getInstance();

        expect(
          service.validateCredentials(
            AppConstants.defaultUsername,
            AppConstants.defaultPassword,
          ),
          isTrue,
        );
      });

      test('validates default test credentials even when user exists', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'differentuser',
          age: 25,
          country: 'USA',
          password: 'differentpassword',
        );

        await service.saveUser(user);

        // Default credentials should still work
        expect(
          service.validateCredentials(
            AppConstants.defaultUsername,
            AppConstants.defaultPassword,
          ),
          isTrue,
        );
      });

      test('rejects invalid credentials', () async {
        final service = await StorageService.getInstance();

        expect(
          service.validateCredentials('invaliduser', 'invalidpass'),
          isFalse,
        );
      });
    });

    group('getCurrentUser', () {
      test('returns null when not logged in', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'testuser',
          age: 25,
          country: 'USA',
          password: 'password123',
        );

        await service.saveUser(user);
        // Not logged in
        expect(service.getCurrentUser(), isNull);
      });

      test('returns user when logged in', () async {
        final service = await StorageService.getInstance();
        const user = User(
          name: 'Test User',
          username: 'testuser',
          age: 25,
          country: 'USA',
          password: 'password123',
        );

        await service.saveUser(user);
        await service.setLoggedIn(true);

        final currentUser = service.getCurrentUser();
        expect(currentUser, isNotNull);
        expect(currentUser!.username, 'testuser');
      });
    });
  });
}
