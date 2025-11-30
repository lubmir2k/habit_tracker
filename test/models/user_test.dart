import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/user.dart';

void main() {
  group('User Model', () {
    test('creates user with required fields', () {
      const user = User(
        name: 'John Doe',
        username: 'johndoe',
        age: 25,
        country: 'USA',
        password: 'password123',
      );

      expect(user.name, 'John Doe');
      expect(user.username, 'johndoe');
      expect(user.age, 25);
      expect(user.country, 'USA');
      expect(user.password, 'password123');
      expect(user.prebuiltHabits, isNull);
    });

    test('creates user with prebuilt habits', () {
      const user = User(
        name: 'John Doe',
        username: 'johndoe',
        age: 25,
        country: 'USA',
        password: 'password123',
        prebuiltHabits: ['Exercise', 'Read'],
      );

      expect(user.prebuiltHabits, ['Exercise', 'Read']);
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        const user = User(
          name: 'John Doe',
          username: 'johndoe',
          age: 25,
          country: 'USA',
          password: 'password123',
          prebuiltHabits: ['Exercise'],
        );

        final json = user.toJson();

        expect(json['name'], 'John Doe');
        expect(json['username'], 'johndoe');
        expect(json['age'], 25);
        expect(json['country'], 'USA');
        expect(json['password'], 'password123');
        expect(json['prebuiltHabits'], ['Exercise']);
      });

      test('fromJson creates correct user', () {
        final json = {
          'name': 'Jane Doe',
          'username': 'janedoe',
          'age': 30,
          'country': 'UK',
          'password': 'secret',
          'prebuiltHabits': ['Meditate', 'Drink Water'],
        };

        final user = User.fromJson(json);

        expect(user.name, 'Jane Doe');
        expect(user.username, 'janedoe');
        expect(user.age, 30);
        expect(user.country, 'UK');
        expect(user.password, 'secret');
        expect(user.prebuiltHabits, ['Meditate', 'Drink Water']);
      });

      test('fromJson handles null prebuiltHabits', () {
        final json = {
          'name': 'Test User',
          'username': 'testuser',
          'age': 20,
          'country': 'Canada',
          'password': 'pass',
          'prebuiltHabits': null,
        };

        final user = User.fromJson(json);

        expect(user.prebuiltHabits, isNull);
      });

      test('round-trip serialization preserves data', () {
        const original = User(
          name: 'Test User',
          username: 'testuser',
          age: 28,
          country: 'Germany',
          password: 'testpass',
          prebuiltHabits: ['Exercise', 'Read', 'Meditate'],
        );

        final json = original.toJson();
        final restored = User.fromJson(json);

        expect(restored.name, original.name);
        expect(restored.username, original.username);
        expect(restored.age, original.age);
        expect(restored.country, original.country);
        expect(restored.password, original.password);
        expect(restored.prebuiltHabits, original.prebuiltHabits);
      });
    });

    group('copyWith', () {
      test('copies with updated name', () {
        const original = User(
          name: 'Original',
          username: 'original',
          age: 25,
          country: 'USA',
          password: 'pass',
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.name, 'Updated');
        expect(updated.username, 'original');
        expect(updated.age, 25);
      });

      test('copies with multiple updated fields', () {
        const original = User(
          name: 'Original',
          username: 'original',
          age: 25,
          country: 'USA',
          password: 'pass',
        );

        final updated = original.copyWith(
          name: 'New Name',
          age: 30,
          country: 'UK',
        );

        expect(updated.name, 'New Name');
        expect(updated.username, 'original');
        expect(updated.age, 30);
        expect(updated.country, 'UK');
        expect(updated.password, 'pass');
      });
    });

    group('equality', () {
      test('equal users are equal', () {
        const user1 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
        );

        const user2 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('different users are not equal', () {
        const user1 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
        );

        const user2 = User(
          name: 'Jane',
          username: 'jane',
          age: 30,
          country: 'UK',
          password: 'secret',
        );

        expect(user1, isNot(equals(user2)));
      });

      test('users with same fields but different prebuiltHabits are not equal', () {
        const user1 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
          prebuiltHabits: ['Exercise'],
        );

        const user2 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
          prebuiltHabits: ['Read'],
        );

        expect(user1, isNot(equals(user2)));
      });

      test('users with same prebuiltHabits are equal', () {
        const user1 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
          prebuiltHabits: ['Exercise', 'Read'],
        );

        const user2 = User(
          name: 'John',
          username: 'john',
          age: 25,
          country: 'USA',
          password: 'pass',
          prebuiltHabits: ['Exercise', 'Read'],
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });
    });
  });
}
