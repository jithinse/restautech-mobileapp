//
//
// class TokenStorage {
//   static String? _token;
//   static String? _userData;
//   static String? _userRole; // Add role storage
//
//   static Future<void> setToken(String token) async {
//     _token = token;
//   }
//
//   static Future<String?> getToken() async {
//     return _token;
//   }
//
//   static Future<void> setUserData(String userData) async {
//     _userData = userData;
//   }
//
//   static Future<String?> getUserData() async {
//     return _userData;
//   }
//
//   // Add role management methods
//   static Future<void> setUserRole(String role) async {
//     _userRole = role;
//   }
//
//   static Future<String?> getUserRole() async {
//     return _userRole ?? 'Kitchen'; // Default to kitchen if not set
//   }
//
//   static Future<void> clear() async {
//     _token = null;
//     _userData = null;
//     _userRole = null;
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  // Keys for SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _userRoleKey = 'user_role';

  // Set token in persistent storage
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token from persistent storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Set user data in persistent storage
  static Future<void> setUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  // Get user data from persistent storage
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // Set user role in persistent storage
  static Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  // Get user role from persistent storage
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'Kitchen'; // Default to kitchen if not set
  }

  // Clear all authentication data
  static Future<void> clear() async {
    try {
      print('Starting to clear token storage...');
      final prefs = await SharedPreferences.getInstance();

      // Remove token
      await prefs.remove(_tokenKey);
      print('Token removed');

      // Remove user data
      await prefs.remove(_userDataKey);
      print('User data removed');

      // Remove user role
      await prefs.remove(_userRoleKey);
      print('User role removed');

      // Verify that data is actually cleared
      final tokenAfterClear = prefs.getString(_tokenKey);
      final userDataAfterClear = prefs.getString(_userDataKey);
      final userRoleAfterClear = prefs.getString(_userRoleKey);

      print('Verification after clearing - Token: $tokenAfterClear');
      print('Verification after clearing - User Data: $userDataAfterClear');
      print('Verification after clearing - User Role: $userRoleAfterClear');

      if (tokenAfterClear == null && userDataAfterClear == null && userRoleAfterClear == null) {
        print('Token storage successfully cleared');
      } else {
        print('WARNING: Some data may not have been cleared properly');
      }
    } catch (e) {
      print('Error clearing token storage: $e');
      throw e; // Re-throw to allow caller to handle
    }
  }
}