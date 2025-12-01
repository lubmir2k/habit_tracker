import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/user.dart';

/// Service for managing local storage using SharedPreferences.
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  /// Returns the singleton instance of StorageService.
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Resets the singleton instance. Only for testing.
  static void resetInstance() {
    _instance = null;
    _prefs = null;
  }

  // ============ User Data Operations ============

  /// Saves user data to local storage.
  Future<bool> saveUser(User user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      return await _prefs!.setString(AppConstants.userDataKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves user data from local storage.
  User? getUser() {
    try {
      final jsonString = _prefs!.getString(AppConstants.userDataKey);
      if (jsonString == null) return null;
      return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Deletes user data from local storage.
  Future<bool> deleteUser() async {
    return await _prefs!.remove(AppConstants.userDataKey);
  }

  /// Checks if a user with the given username already exists.
  bool userExists(String username) {
    final user = getUser();
    return user != null && user.username == username;
  }

  // ============ Session Management ============

  /// Sets the logged in state.
  Future<bool> setLoggedIn(bool value) async {
    return await _prefs!.setBool(AppConstants.isLoggedInKey, value);
  }

  /// Returns whether a user is currently logged in.
  bool isLoggedIn() {
    return _prefs!.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  /// Clears the session (logs out user).
  Future<void> clearSession() async {
    await setLoggedIn(false);
  }

  // ============ Authentication ============

  /// Validates login credentials against stored user or default test credentials.
  bool validateCredentials(String username, String password) {
    final user = getUser();

    // Check against stored user
    if (user != null) {
      if (user.username == username && user.password == password) {
        return true;
      }
    }

    // Check against default test credentials (course requirement)
    return username == AppConstants.defaultUsername &&
        password == AppConstants.defaultPassword;
  }

  /// Returns the currently logged in user, or null if using default credentials.
  User? getCurrentUser() {
    if (!isLoggedIn()) return null;
    return getUser();
  }

  // ============ Habits Data Operations ============

  /// Saves habits list to local storage.
  Future<bool> saveHabits(List<Habit> habits) async {
    try {
      final jsonList = habits.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(AppConstants.habitsDataKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves habits list from local storage.
  List<Habit> getHabits() {
    try {
      final jsonString = _prefs!.getString(AppConstants.habitsDataKey);
      if (jsonString == null) return [];
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Habit.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Adds a new habit.
  Future<bool> addHabit(Habit habit) async {
    final habits = getHabits();
    habits.add(habit);
    return saveHabits(habits);
  }

  /// Deletes a habit by ID.
  Future<bool> deleteHabit(String habitId) async {
    final habits = getHabits();
    habits.removeWhere((h) => h.id == habitId);
    final habitsDeleted = await saveHabits(habits);

    // Also remove completions for this habit
    final completions = _getAllCompletions();
    completions.removeWhere((c) => c.habitId == habitId);
    final completionsDeleted = await _saveAllCompletions(completions);

    return habitsDeleted && completionsDeleted;
  }

  // ============ Habit Completions Operations ============

  /// Gets all completions from storage (for reports/analytics).
  /// Filters out orphaned completions for deleted habits.
  List<HabitCompletion> getAllCompletions() {
    final completions = _getAllCompletions();
    final habitIds = getHabits().map((h) => h.id).toSet();
    // Filter out completions for deleted habits (orphaned data)
    return completions.where((c) => habitIds.contains(c.habitId)).toList();
  }

  /// Gets all completions from storage.
  List<HabitCompletion> _getAllCompletions() {
    try {
      final jsonString = _prefs!.getString(AppConstants.completionsDataKey);
      if (jsonString == null) return [];
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => HabitCompletion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves all completions to storage.
  Future<bool> _saveAllCompletions(List<HabitCompletion> completions) async {
    try {
      final jsonList = completions.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!
          .setString(AppConstants.completionsDataKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Gets completions for a specific date.
  List<HabitCompletion> getCompletionsForDate(DateTime date) {
    final dateKey = HabitCompletion.formatDateKey(date);
    return _getAllCompletions().where((c) => c.dateKey == dateKey).toList();
  }

  /// Checks if a habit is completed for a specific date.
  bool isHabitCompletedForDate(String habitId, DateTime date) {
    final dateKey = HabitCompletion.formatDateKey(date);
    return _getAllCompletions()
        .any((c) => c.habitId == habitId && c.dateKey == dateKey);
  }

  /// Marks a habit as completed for a specific date.
  Future<bool> completeHabit(String habitId, DateTime date) async {
    final completions = _getAllCompletions();
    final dateKey = HabitCompletion.formatDateKey(date);

    // Check if already completed (avoids double read)
    if (completions.any((c) => c.habitId == habitId && c.dateKey == dateKey)) {
      return true;
    }

    completions.add(HabitCompletion(
      habitId: habitId,
      date: DateTime(date.year, date.month, date.day),
    ));
    return _saveAllCompletions(completions);
  }

  /// Removes completion for a habit on a specific date.
  Future<bool> uncompleteHabit(String habitId, DateTime date) async {
    final dateKey = HabitCompletion.formatDateKey(date);
    final completions = _getAllCompletions();
    completions.removeWhere((c) => c.habitId == habitId && c.dateKey == dateKey);
    return _saveAllCompletions(completions);
  }
}
