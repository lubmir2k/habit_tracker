import 'package:flutter/foundation.dart';

/// Model for notification settings.
class NotificationSettings {
  final bool globalEnabled;
  final bool morningEnabled;
  final int morningHour;
  final int morningMinute;
  final bool afternoonEnabled;
  final int afternoonHour;
  final int afternoonMinute;
  final bool eveningEnabled;
  final int eveningHour;
  final int eveningMinute;
  final Set<String> enabledHabitIds;

  const NotificationSettings({
    this.globalEnabled = false,
    this.morningEnabled = true,
    this.morningHour = 8,
    this.morningMinute = 0,
    this.afternoonEnabled = true,
    this.afternoonHour = 12,
    this.afternoonMinute = 0,
    this.eveningEnabled = true,
    this.eveningHour = 18,
    this.eveningMinute = 0,
    this.enabledHabitIds = const {},
  });

  /// Creates NotificationSettings from JSON map.
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      globalEnabled: json['globalEnabled'] as bool? ?? false,
      morningEnabled: json['morningEnabled'] as bool? ?? true,
      morningHour: json['morningHour'] as int? ?? 8,
      morningMinute: json['morningMinute'] as int? ?? 0,
      afternoonEnabled: json['afternoonEnabled'] as bool? ?? true,
      afternoonHour: json['afternoonHour'] as int? ?? 12,
      afternoonMinute: json['afternoonMinute'] as int? ?? 0,
      eveningEnabled: json['eveningEnabled'] as bool? ?? true,
      eveningHour: json['eveningHour'] as int? ?? 18,
      eveningMinute: json['eveningMinute'] as int? ?? 0,
      enabledHabitIds: (json['enabledHabitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
    );
  }

  /// Converts NotificationSettings to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'globalEnabled': globalEnabled,
      'morningEnabled': morningEnabled,
      'morningHour': morningHour,
      'morningMinute': morningMinute,
      'afternoonEnabled': afternoonEnabled,
      'afternoonHour': afternoonHour,
      'afternoonMinute': afternoonMinute,
      'eveningEnabled': eveningEnabled,
      'eveningHour': eveningHour,
      'eveningMinute': eveningMinute,
      'enabledHabitIds': enabledHabitIds.toList(),
    };
  }

  /// Creates a copy with updated fields.
  NotificationSettings copyWith({
    bool? globalEnabled,
    bool? morningEnabled,
    int? morningHour,
    int? morningMinute,
    bool? afternoonEnabled,
    int? afternoonHour,
    int? afternoonMinute,
    bool? eveningEnabled,
    int? eveningHour,
    int? eveningMinute,
    Set<String>? enabledHabitIds,
  }) {
    return NotificationSettings(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      morningHour: morningHour ?? this.morningHour,
      morningMinute: morningMinute ?? this.morningMinute,
      afternoonEnabled: afternoonEnabled ?? this.afternoonEnabled,
      afternoonHour: afternoonHour ?? this.afternoonHour,
      afternoonMinute: afternoonMinute ?? this.afternoonMinute,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      eveningHour: eveningHour ?? this.eveningHour,
      eveningMinute: eveningMinute ?? this.eveningMinute,
      enabledHabitIds: enabledHabitIds ?? this.enabledHabitIds,
    );
  }

  /// Formats a time slot as a string (e.g., "8:00 AM").
  static String formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  String get morningTimeString => formatTime(morningHour, morningMinute);
  String get afternoonTimeString => formatTime(afternoonHour, afternoonMinute);
  String get eveningTimeString => formatTime(eveningHour, eveningMinute);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.globalEnabled == globalEnabled &&
        other.morningEnabled == morningEnabled &&
        other.morningHour == morningHour &&
        other.morningMinute == morningMinute &&
        other.afternoonEnabled == afternoonEnabled &&
        other.afternoonHour == afternoonHour &&
        other.afternoonMinute == afternoonMinute &&
        other.eveningEnabled == eveningEnabled &&
        other.eveningHour == eveningHour &&
        other.eveningMinute == eveningMinute &&
        setEquals(other.enabledHabitIds, enabledHabitIds);
  }

  @override
  int get hashCode {
    return Object.hash(
      globalEnabled,
      morningEnabled,
      morningHour,
      morningMinute,
      afternoonEnabled,
      afternoonHour,
      afternoonMinute,
      eveningEnabled,
      eveningHour,
      eveningMinute,
      Object.hashAll(enabledHabitIds),
    );
  }
}
