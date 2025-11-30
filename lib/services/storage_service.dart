import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
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
}
