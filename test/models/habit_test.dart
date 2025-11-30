import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/habit_completion.dart';

void main() {
  group('Habit Model', () {
    test('creates habit with required fields', () {
      final habit = Habit(
        id: 'test-id',
        name: 'Exercise',
        colorValue: 0xFFE53935,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(habit.id, 'test-id');
      expect(habit.name, 'Exercise');
      expect(habit.colorValue, 0xFFE53935);
      expect(habit.createdAt, DateTime(2024, 1, 1));
    });

    test('color getter returns correct Color', () {
      final habit = Habit(
        id: 'test-id',
        name: 'Exercise',
        colorValue: 0xFFE53935,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(habit.color.toARGB32(), 0xFFE53935);
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        final habit = Habit(
          id: 'test-id',
          name: 'Exercise',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        );

        final json = habit.toJson();

        expect(json['id'], 'test-id');
        expect(json['name'], 'Exercise');
        expect(json['colorValue'], 0xFFE53935);
        expect(json['createdAt'], '2024-01-01T12:00:00.000');
      });

      test('fromJson creates correct habit', () {
        final json = {
          'id': 'test-id',
          'name': 'Read',
          'colorValue': 0xFF1E88E5,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        final habit = Habit.fromJson(json);

        expect(habit.id, 'test-id');
        expect(habit.name, 'Read');
        expect(habit.colorValue, 0xFF1E88E5);
        expect(habit.createdAt, DateTime(2024, 1, 15, 10, 30, 0));
      });

      test('round-trip serialization preserves data', () {
        final original = Habit(
          id: 'round-trip-id',
          name: 'Meditate',
          colorValue: 0xFF43A047,
          createdAt: DateTime(2024, 6, 15, 8, 0, 0),
        );

        final json = original.toJson();
        final restored = Habit.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.colorValue, original.colorValue);
        expect(restored.createdAt, original.createdAt);
      });
    });

    group('copyWith', () {
      test('copies with updated name', () {
        final original = Habit(
          id: 'test-id',
          name: 'Original',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1),
        );

        final updated = original.copyWith(name: 'Updated');

        expect(updated.name, 'Updated');
        expect(updated.id, 'test-id');
        expect(updated.colorValue, 0xFFE53935);
      });

      test('copies with multiple updated fields', () {
        final original = Habit(
          id: 'test-id',
          name: 'Original',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1),
        );

        final updated = original.copyWith(
          name: 'New Name',
          colorValue: 0xFF1E88E5,
        );

        expect(updated.name, 'New Name');
        expect(updated.colorValue, 0xFF1E88E5);
        expect(updated.id, 'test-id');
      });
    });

    group('equality', () {
      test('equal habits are equal', () {
        final habit1 = Habit(
          id: 'test-id',
          name: 'Exercise',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1),
        );

        final habit2 = Habit(
          id: 'test-id',
          name: 'Exercise',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(habit1, equals(habit2));
        expect(habit1.hashCode, equals(habit2.hashCode));
      });

      test('different habits are not equal', () {
        final habit1 = Habit(
          id: 'id-1',
          name: 'Exercise',
          colorValue: 0xFFE53935,
          createdAt: DateTime(2024, 1, 1),
        );

        final habit2 = Habit(
          id: 'id-2',
          name: 'Read',
          colorValue: 0xFF1E88E5,
          createdAt: DateTime(2024, 1, 2),
        );

        expect(habit1, isNot(equals(habit2)));
      });
    });
  });

  group('HabitCompletion Model', () {
    test('creates completion with required fields', () {
      final completion = HabitCompletion(
        habitId: 'habit-1',
        date: DateTime(2024, 1, 15),
      );

      expect(completion.habitId, 'habit-1');
      expect(completion.date, DateTime(2024, 1, 15));
    });

    test('dateKey returns correct format', () {
      final completion = HabitCompletion(
        habitId: 'habit-1',
        date: DateTime(2024, 1, 5),
      );

      expect(completion.dateKey, '2024-01-05');
    });

    test('dateKey pads single digit month and day', () {
      final completion = HabitCompletion(
        habitId: 'habit-1',
        date: DateTime(2024, 3, 9),
      );

      expect(completion.dateKey, '2024-03-09');
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        final completion = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
        );

        final json = completion.toJson();

        expect(json['habitId'], 'habit-1');
        expect(json['date'], '2024-01-15T00:00:00.000');
      });

      test('fromJson creates correct completion', () {
        final json = {
          'habitId': 'habit-2',
          'date': '2024-06-20T00:00:00.000',
        };

        final completion = HabitCompletion.fromJson(json);

        expect(completion.habitId, 'habit-2');
        expect(completion.date, DateTime(2024, 6, 20));
      });

      test('round-trip serialization preserves data', () {
        final original = HabitCompletion(
          habitId: 'habit-3',
          date: DateTime(2024, 12, 25),
        );

        final json = original.toJson();
        final restored = HabitCompletion.fromJson(json);

        expect(restored.habitId, original.habitId);
        expect(restored.dateKey, original.dateKey);
      });
    });

    group('equality', () {
      test('completions with same habitId and date are equal', () {
        final completion1 = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
        );

        final completion2 = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
        );

        expect(completion1, equals(completion2));
        expect(completion1.hashCode, equals(completion2.hashCode));
      });

      test('completions with different dates are not equal', () {
        final completion1 = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
        );

        final completion2 = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 16),
        );

        expect(completion1, isNot(equals(completion2)));
      });

      test('completions with different habitIds are not equal', () {
        final completion1 = HabitCompletion(
          habitId: 'habit-1',
          date: DateTime(2024, 1, 15),
        );

        final completion2 = HabitCompletion(
          habitId: 'habit-2',
          date: DateTime(2024, 1, 15),
        );

        expect(completion1, isNot(equals(completion2)));
      });
    });
  });
}
