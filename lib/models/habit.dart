import 'package:flutter/material.dart';

/// Habit model for tracking daily habits.
class Habit {
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  /// Get the Color object from the stored color value.
  Color get color => Color(colorValue);

  /// Creates a Habit from JSON map.
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts Habit to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of Habit with updated fields.
  Habit copyWith({
    String? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.colorValue == colorValue &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, colorValue, createdAt);
  }
}
