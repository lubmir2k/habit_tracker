import 'package:flutter/foundation.dart';

/// User model for the Habit Tracker app.
class User {
  final String name;
  final String username;
  final int age;
  final String country;
  final String password;
  final List<String>? prebuiltHabits;

  const User({
    required this.name,
    required this.username,
    required this.age,
    required this.country,
    required this.password,
    this.prebuiltHabits,
  });

  /// Creates a User from JSON map.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      username: json['username'] as String,
      age: json['age'] as int,
      country: json['country'] as String,
      password: json['password'] as String,
      prebuiltHabits: (json['prebuiltHabits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// Converts User to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'age': age,
      'country': country,
      'password': password,
      'prebuiltHabits': prebuiltHabits,
    };
  }

  /// Creates a copy of User with updated fields.
  User copyWith({
    String? name,
    String? username,
    int? age,
    String? country,
    String? password,
    List<String>? prebuiltHabits,
  }) {
    return User(
      name: name ?? this.name,
      username: username ?? this.username,
      age: age ?? this.age,
      country: country ?? this.country,
      password: password ?? this.password,
      prebuiltHabits: prebuiltHabits ?? this.prebuiltHabits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.name == name &&
        other.username == username &&
        other.age == age &&
        other.country == country &&
        other.password == password &&
        listEquals(other.prebuiltHabits, prebuiltHabits);
  }

  @override
  int get hashCode {
    return Object.hash(name, username, age, country, password, prebuiltHabits);
  }
}
