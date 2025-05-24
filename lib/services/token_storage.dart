<<<<<<< HEAD

=======
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
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
<<<<<<< HEAD
=======
  // Keys for SharedPreferences
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _userRoleKey = 'user_role';

<<<<<<< HEAD
  static String? _token;
  static String? _userData;
  static String? _userRole;

  static Future<void> setToken(String token) async {
    _token = token;
    // Save to SharedPreferences
=======
  // Set token in persistent storage
  static Future<void> setToken(String token) async {
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

<<<<<<< HEAD
  static Future<String?> getToken() async {
    if (_token == null) {
      // Try to get from SharedPreferences if not in memory
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    }
    return _token;
  }

  static Future<void> setUserData(String userData) async {
    _userData = userData;
    // Save to SharedPreferences
=======
  // Get token from persistent storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Set user data in persistent storage
  static Future<void> setUserData(String userData) async {
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

<<<<<<< HEAD
  static Future<String?> getUserData() async {
    if (_userData == null) {
      // Try to get from SharedPreferences if not in memory
      final prefs = await SharedPreferences.getInstance();
      _userData = prefs.getString(_userDataKey);
    }
    return _userData;
  }

  static Future<void> setUserRole(String role) async {
    _userRole = role;
    // Save to SharedPreferences
=======
  // Get user data from persistent storage
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // Set user role in persistent storage
  static Future<void> setUserRole(String role) async {
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

<<<<<<< HEAD
  static Future<String?> getUserRole() async {
    if (_userRole == null) {
      // Try to get from SharedPreferences if not in memory
      final prefs = await SharedPreferences.getInstance();
      _userRole = prefs.getString(_userRoleKey);
    }
    return _userRole ?? 'Counter'; // Default to Counter if not set
  }

=======
  // Get user role from persistent storage
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey) ?? 'Kitchen'; // Default to kitchen if not set
  }

  // Clear all authentication data
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
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