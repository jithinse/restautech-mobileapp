// import 'dart:convert';
// import 'dart:io';
// import 'package:logger/logger.dart';
// import '../model/usermodel.dart';
// import '../utils/constants.dart';
// import '../utils/token_storage.dart';
// import 'api_service.dart';

// class AuthController {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 0,
//       errorMethodCount: 5,
//       colors: true,
//       printEmojis: true,
//     ),
//   );

//   // Login method with improved error handling
//   static Future<Map<String, dynamic>> login(
//       String email, String password) async {
//     try {
//       _logger.d('Login attempt for email: $email');

//       final formData = {'email': email, 'password': password, 'role': 'Waiter'};

//       final stopwatch = Stopwatch()..start();
//       final response = await ApiService.postWithApiKey(
//         ApiConstants.loginEndpoint,
//         formData,
//       );
//       _logger.i('Login completed in ${stopwatch.elapsedMilliseconds}ms');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(utf8.decode(response.bodyBytes));

//         // Validate response structure
//         if (data['token'] == null || data['user'] == null) {
//           throw Exception('Invalid server response format');
//         }

//         final token = data['token'] as String;
//         final userJson = data['user'] as Map<String, dynamic>;

//         // Ensure role is set to Waiter
//         userJson['role'] = 'Waiter';
//         final user = UserModel.fromJson(userJson);

//         // Save auth data
//         await Future.wait([
//           TokenStorage.setToken(token),
//           TokenStorage.setUserData(jsonEncode(userJson)),
//           TokenStorage.setUserRole('Waiter'),
//           TokenStorage.saveCredentials(email, password),
//         ]);

//         _logger.i('Login successful for user: ${user.email}');
//         return {
//           'success': true,
//           'user': user,
//           'message': 'Login successful',
//           'role': 'Waiter',
//         };
//       } else {
//         final errorData = jsonDecode(utf8.decode(response.bodyBytes));
//         final errorMessage = errorData['message'] ?? 'Login failed';
//         _logger.w('Login failed: $errorMessage');
//         return {
//           'success': false,
//           'message': errorMessage,
//         };
//       }
//     } on TimeoutException {
//       _logger.w('Login timeout');
//       return {
//         'success': false,
//         'message': 'Connection timeout. Please try again.',
//       };
//     } on SocketException {
//       _logger.w('Network error during login');
//       return {
//         'success': false,
//         'message': 'No internet connection. Please check your network.',
//       };
//     } catch (e) {
//       _logger.e('Login error', error: e);
//       return {
//         'success': false,
//         'message': 'An unexpected error occurred. Please try again.',
//       };
//     }
//   }

//   // Auto-login with saved credentials
//   static Future<Map<String, dynamic>> autoLogin() async {
//     try {
//       _logger.d('Attempting auto-login...');
//       final credentials = await TokenStorage.getCredentials();

//       if (credentials['email'] == null || credentials['password'] == null) {
//         _logger.w('No saved credentials found');
//         return {'success': false, 'message': 'No saved credentials found'};
//       }

//       return await login(
//         credentials['email']!,
//         credentials['password']!,
//       );
//     } catch (e) {
//       _logger.e('Auto-login failed', error: e);
//       return {
//         'success': false,
//         'message': 'Auto-login failed. Please login manually.',
//       };
//     }
//   }

//   // Logout with cleanup
//   static Future<void> logout() async {
//     try {
//       _logger.d('Logging out...');
//       await TokenStorage.clear();
//       _logger.i('Logout successful');
//     } catch (e) {
//       _logger.e('Error during logout', error: e);
//       rethrow;
//     }
//   }

//   // Get cached user data with null safety
//   static Future<UserModel?> getCachedUserData() async {
//     try {
//       _logger.d('Fetching cached user data...');
//       final userDataString = await TokenStorage.getUserData();

//       if (userDataString == null) {
//         _logger.w('No user data found in cache');
//         return null;
//       }

//       final userData = jsonDecode(userDataString) as Map<String, dynamic>;
//       userData['role'] = 'Waiter'; // Ensure role is set

//       return UserModel.fromJson(userData);
//     } catch (e) {
//       _logger.e('Error fetching cached user data', error: e);
//       return null;
//     }
//   }

//   // Get user role (always Waiter for this app)
//   static Future<String> getUserRole() async {
//     try {
//       _logger.d('Fetching user role...');
//       // For this waiter app, we always return 'Waiter'
//       return 'Waiter';
//     } catch (e) {
//       _logger.e('Error fetching user role', error: e);
//       return 'Waiter'; // Fallback to Waiter
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../model/usermodel.dart';
import '../utils/constants.dart';
import '../utils/token_storage.dart';
import 'api_service.dart';

class AuthController {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
    ),
  );

  // Login method with improved error handling
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      _logger.d('Login attempt for email: $email');

      final formData = {'email': email, 'password': password, 'role': 'Waiter'};

      final stopwatch = Stopwatch()..start();
      final response = await ApiService.postWithApiKey(
        ApiConstants.loginEndpoint,
        formData,
      );
      _logger.i('Login completed in ${stopwatch.elapsedMilliseconds}ms');

      // Check for HTML response
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        throw FormatException(
            'Server returned HTML response. Check endpoint URL.');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // Validate response structure
        if (data['token'] == null || data['user'] == null) {
          throw Exception('Invalid server response format');
        }

        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;

        // Ensure role is set to Waiter
        userJson['role'] = 'Waiter';
        final user = UserModel.fromJson(userJson);

        // Save auth data
        await Future.wait([
          TokenStorage.setToken(token),
          TokenStorage.setUserData(jsonEncode(userJson)),
          TokenStorage.setUserRole('Waiter'),
          TokenStorage.saveCredentials(email, password),
        ]);

        _logger.i('Login successful for user: ${user.email}');
        return {
          'success': true,
          'user': user,
          'message': 'Login successful',
          'role': 'Waiter',
        };
      } else {
        final errorMessage = data['message'] ?? 'Login failed';
        _logger.w('Login failed: $errorMessage');
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on TimeoutException {
      _logger.w('Login timeout');
      return {
        'success': false,
        'message': 'Connection timeout. Please try again.',
      };
    } on SocketException {
      _logger.w('Network error during login');
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on FormatException catch (e) {
      _logger.e('Format error during login', error: e);
      return {
        'success': false,
        'message': 'Server error. Please try again later.',
      };
    } catch (e) {
      _logger.e('Login error', error: e);
      return {
        'success': false,
        'message': ApiService.handleException(e),
      };
    }
  }

  // Auto-login with saved credentials
  static Future<Map<String, dynamic>> autoLogin() async {
    try {
      _logger.d('Attempting auto-login...');
      final credentials = await TokenStorage.getCredentials();

      if (credentials['email'] == null || credentials['password'] == null) {
        _logger.w('No saved credentials found');
        return {'success': false, 'message': 'No saved credentials found'};
      }

      return await login(
        credentials['email']!,
        credentials['password']!,
      );
    } catch (e) {
      _logger.e('Auto-login failed', error: e);
      return {
        'success': false,
        'message': 'Auto-login failed. Please login manually.',
      };
    }
  }

  // Logout with cleanup
  static Future<void> logout() async {
    try {
      _logger.d('Logging out...');
      await TokenStorage.clear();
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Error during logout', error: e);
      rethrow;
    }
  }

  // Get cached user data with null safety
  static Future<UserModel?> getCachedUserData() async {
    try {
      _logger.d('Fetching cached user data...');
      final userDataString = await TokenStorage.getUserData();

      if (userDataString == null) {
        _logger.w('No user data found in cache');
        return null;
      }

      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      userData['role'] = 'Waiter'; // Ensure role is set

      return UserModel.fromJson(userData);
    } catch (e) {
      _logger.e('Error fetching cached user data', error: e);
      return null;
    }
  }

  // Get user role (always Waiter for this app)
  static Future<String> getUserRole() async {
    try {
      _logger.d('Fetching user role...');
      // For this waiter app, we always return 'Waiter'
      return 'Waiter';
    } catch (e) {
      _logger.e('Error fetching user role', error: e);
      return 'Waiter'; // Fallback to Waiter
    }
  }
}
