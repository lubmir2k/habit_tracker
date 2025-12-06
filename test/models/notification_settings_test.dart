import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/notification_settings.dart';

void main() {
  group('NotificationSettings Model', () {
    test('creates with default values', () {
      const settings = NotificationSettings();

      expect(settings.globalEnabled, isFalse);
      expect(settings.morningEnabled, isTrue);
      expect(settings.morningHour, 8);
      expect(settings.morningMinute, 0);
      expect(settings.afternoonEnabled, isTrue);
      expect(settings.afternoonHour, 12);
      expect(settings.afternoonMinute, 0);
      expect(settings.eveningEnabled, isTrue);
      expect(settings.eveningHour, 18);
      expect(settings.eveningMinute, 0);
      expect(settings.enabledHabitIds, isEmpty);
    });

    test('creates with custom values', () {
      final settings = NotificationSettings(
        globalEnabled: true,
        morningEnabled: false,
        morningHour: 7,
        morningMinute: 30,
        afternoonEnabled: true,
        afternoonHour: 13,
        afternoonMinute: 15,
        eveningEnabled: false,
        eveningHour: 20,
        eveningMinute: 45,
        enabledHabitIds: {'habit-1', 'habit-2'},
      );

      expect(settings.globalEnabled, isTrue);
      expect(settings.morningEnabled, isFalse);
      expect(settings.morningHour, 7);
      expect(settings.morningMinute, 30);
      expect(settings.afternoonEnabled, isTrue);
      expect(settings.afternoonHour, 13);
      expect(settings.afternoonMinute, 15);
      expect(settings.eveningEnabled, isFalse);
      expect(settings.eveningHour, 20);
      expect(settings.eveningMinute, 45);
      expect(settings.enabledHabitIds, {'habit-1', 'habit-2'});
    });

    group('JSON serialization', () {
      test('toJson returns correct map', () {
        final settings = NotificationSettings(
          globalEnabled: true,
          morningEnabled: true,
          morningHour: 9,
          morningMinute: 30,
          afternoonEnabled: false,
          afternoonHour: 14,
          afternoonMinute: 0,
          eveningEnabled: true,
          eveningHour: 21,
          eveningMinute: 15,
          enabledHabitIds: {'habit-1'},
        );

        final json = settings.toJson();

        expect(json['globalEnabled'], isTrue);
        expect(json['morningEnabled'], isTrue);
        expect(json['morningHour'], 9);
        expect(json['morningMinute'], 30);
        expect(json['afternoonEnabled'], isFalse);
        expect(json['afternoonHour'], 14);
        expect(json['afternoonMinute'], 0);
        expect(json['eveningEnabled'], isTrue);
        expect(json['eveningHour'], 21);
        expect(json['eveningMinute'], 15);
        expect(json['enabledHabitIds'], ['habit-1']);
      });

      test('fromJson creates correct settings', () {
        final json = {
          'globalEnabled': true,
          'morningEnabled': false,
          'morningHour': 6,
          'morningMinute': 45,
          'afternoonEnabled': true,
          'afternoonHour': 15,
          'afternoonMinute': 30,
          'eveningEnabled': false,
          'eveningHour': 19,
          'eveningMinute': 0,
          'enabledHabitIds': ['habit-a', 'habit-b'],
        };

        final settings = NotificationSettings.fromJson(json);

        expect(settings.globalEnabled, isTrue);
        expect(settings.morningEnabled, isFalse);
        expect(settings.morningHour, 6);
        expect(settings.morningMinute, 45);
        expect(settings.afternoonEnabled, isTrue);
        expect(settings.afternoonHour, 15);
        expect(settings.afternoonMinute, 30);
        expect(settings.eveningEnabled, isFalse);
        expect(settings.eveningHour, 19);
        expect(settings.eveningMinute, 0);
        expect(settings.enabledHabitIds, {'habit-a', 'habit-b'});
      });

      test('fromJson uses defaults for missing fields', () {
        final json = <String, dynamic>{};

        final settings = NotificationSettings.fromJson(json);

        expect(settings.globalEnabled, isFalse);
        expect(settings.morningEnabled, isTrue);
        expect(settings.morningHour, 8);
        expect(settings.morningMinute, 0);
        expect(settings.afternoonEnabled, isTrue);
        expect(settings.afternoonHour, 12);
        expect(settings.afternoonMinute, 0);
        expect(settings.eveningEnabled, isTrue);
        expect(settings.eveningHour, 18);
        expect(settings.eveningMinute, 0);
        expect(settings.enabledHabitIds, isEmpty);
      });

      test('round-trip serialization preserves data', () {
        final original = NotificationSettings(
          globalEnabled: true,
          morningEnabled: false,
          morningHour: 7,
          morningMinute: 15,
          afternoonEnabled: true,
          afternoonHour: 13,
          afternoonMinute: 45,
          eveningEnabled: true,
          eveningHour: 20,
          eveningMinute: 30,
          enabledHabitIds: {'habit-1', 'habit-2', 'habit-3'},
        );

        final json = original.toJson();
        final restored = NotificationSettings.fromJson(json);

        expect(restored, original);
      });
    });

    group('copyWith', () {
      test('copies with updated globalEnabled', () {
        const original = NotificationSettings(globalEnabled: false);
        final updated = original.copyWith(globalEnabled: true);

        expect(updated.globalEnabled, isTrue);
        expect(updated.morningEnabled, original.morningEnabled);
        expect(updated.morningHour, original.morningHour);
      });

      test('copies with updated time slot', () {
        const original = NotificationSettings();
        final updated = original.copyWith(
          morningHour: 10,
          morningMinute: 45,
        );

        expect(updated.morningHour, 10);
        expect(updated.morningMinute, 45);
        expect(updated.afternoonHour, original.afternoonHour);
      });

      test('copies with updated enabledHabitIds', () {
        const original = NotificationSettings();
        final updated = original.copyWith(
          enabledHabitIds: {'new-habit'},
        );

        expect(updated.enabledHabitIds, {'new-habit'});
      });

      test('copies with multiple updated fields', () {
        const original = NotificationSettings();
        final updated = original.copyWith(
          globalEnabled: true,
          morningEnabled: false,
          eveningHour: 22,
          eveningMinute: 30,
        );

        expect(updated.globalEnabled, isTrue);
        expect(updated.morningEnabled, isFalse);
        expect(updated.eveningHour, 22);
        expect(updated.eveningMinute, 30);
        // Unchanged fields
        expect(updated.afternoonEnabled, original.afternoonEnabled);
        expect(updated.afternoonHour, original.afternoonHour);
      });
    });

    group('formatTime', () {
      test('formats AM times correctly', () {
        expect(NotificationSettings.formatTime(8, 0), '8:00 AM');
        expect(NotificationSettings.formatTime(9, 30), '9:30 AM');
        expect(NotificationSettings.formatTime(11, 45), '11:45 AM');
      });

      test('formats PM times correctly', () {
        expect(NotificationSettings.formatTime(12, 0), '12:00 PM');
        expect(NotificationSettings.formatTime(13, 0), '1:00 PM');
        expect(NotificationSettings.formatTime(18, 30), '6:30 PM');
        expect(NotificationSettings.formatTime(23, 59), '11:59 PM');
      });

      test('formats midnight correctly', () {
        expect(NotificationSettings.formatTime(0, 0), '12:00 AM');
        expect(NotificationSettings.formatTime(0, 30), '12:30 AM');
      });

      test('formats noon correctly', () {
        expect(NotificationSettings.formatTime(12, 0), '12:00 PM');
        expect(NotificationSettings.formatTime(12, 15), '12:15 PM');
      });

      test('pads minutes with leading zero', () {
        expect(NotificationSettings.formatTime(8, 5), '8:05 AM');
        expect(NotificationSettings.formatTime(14, 9), '2:09 PM');
      });
    });

    group('equality', () {
      test('equal settings are equal', () {
        final settings1 = NotificationSettings(
          globalEnabled: true,
          morningHour: 7,
          enabledHabitIds: {'habit-1'},
        );

        final settings2 = NotificationSettings(
          globalEnabled: true,
          morningHour: 7,
          enabledHabitIds: {'habit-1'},
        );

        expect(settings1, equals(settings2));
        expect(settings1.hashCode, equals(settings2.hashCode));
      });

      test('different settings are not equal', () {
        const settings1 = NotificationSettings(globalEnabled: true);
        const settings2 = NotificationSettings(globalEnabled: false);

        expect(settings1, isNot(equals(settings2)));
      });

      test('settings with different enabledHabitIds are not equal', () {
        final settings1 = NotificationSettings(
          enabledHabitIds: {'habit-1'},
        );

        final settings2 = NotificationSettings(
          enabledHabitIds: {'habit-2'},
        );

        expect(settings1, isNot(equals(settings2)));
      });

      test('settings with same enabledHabitIds in different order are equal', () {
        final settings1 = NotificationSettings(
          enabledHabitIds: {'habit-1', 'habit-2'},
        );

        final settings2 = NotificationSettings(
          enabledHabitIds: {'habit-2', 'habit-1'},
        );

        expect(settings1, equals(settings2));
      });
    });

    group('time string getters', () {
      test('morningTimeString returns formatted time', () {
        const settings = NotificationSettings(
          morningHour: 7,
          morningMinute: 30,
        );
        expect(settings.morningTimeString, '7:30 AM');
      });

      test('afternoonTimeString returns formatted time', () {
        const settings = NotificationSettings(
          afternoonHour: 14,
          afternoonMinute: 15,
        );
        expect(settings.afternoonTimeString, '2:15 PM');
      });

      test('eveningTimeString returns formatted time', () {
        const settings = NotificationSettings(
          eveningHour: 20,
          eveningMinute: 45,
        );
        expect(settings.eveningTimeString, '8:45 PM');
      });

      test('default time strings', () {
        const settings = NotificationSettings();
        expect(settings.morningTimeString, '8:00 AM');
        expect(settings.afternoonTimeString, '12:00 PM');
        expect(settings.eveningTimeString, '6:00 PM');
      });
    });
  });
}
