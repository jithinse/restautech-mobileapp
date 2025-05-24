<<<<<<< HEAD
// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
// import '../auth/login_page.dart';
//
//
// class HomeController {
//   Future<void> logout(BuildContext context) async {
//     final authService = AuthService();
//     await authService.logout();
//
//     if (context.mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const LoginPage()),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage.dart';
import '../auth/login_page.dart';

class HomeController {
  final AuthService authService = AuthService();

  Future<void> logout(BuildContext context) async {
    try {
      print('Attempting to logout...');
      await authService.logout();
      print('Logout successful');

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false
      );
    } catch (e) {
      print('Exception during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }
=======
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';


class HomeController {
  // Future<void> logout(BuildContext context) async {
  //   final authService = AuthService();
  //   await authService.logout();
  //
  //   if (context.mounted) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => const LoginPage()),
  //     );
  //   }
  // }
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
}