import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local prototype authentication. For production, move accounts and session
/// validation to a secure backend; SharedPreferences is device-local storage.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _usersKey = 'proofpath_users_v1';
  static const _sessionKey = 'proofpath_signed_in_username_v1';

  String _hash(String password) => sha256.convert(utf8.encode(password)).toString();

  Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_sessionKey);
    if (username == null) return null;
    final users = _readUsers(prefs);
    for (final user in users) {
      if ((user['username'] as String).toLowerCase() == username.toLowerCase()) {
        return Map<String, dynamic>.from(user)..remove('passwordHash');
      }
    }
    await prefs.remove(_sessionKey);
    return null;
  }

  Future<String?> register({
    required String fullName,
    required String username,
    required String password,
    required int age,
    required String gender,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    if (users.any((u) => (u['username'] as String).toLowerCase() == username.toLowerCase())) {
      return 'That username is already taken. Please choose another.';
    }
    users.add({
      'fullName': fullName.trim(),
      'username': username.trim(),
      'passwordHash': _hash(password),
      'age': age,
      'gender': gender,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_sessionKey, username.trim());
    return null;
  }

  Future<String?> login({required String username, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    for (final user in users) {
      if ((user['username'] as String).toLowerCase() == username.trim().toLowerCase() &&
          user['passwordHash'] == _hash(password)) {
        await prefs.setString(_sessionKey, user['username'] as String);
        return null;
      }
    }
    return 'Incorrect username or password.';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  List<Map<String, dynamic>> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}
