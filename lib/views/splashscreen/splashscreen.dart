import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/token_storage.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Future<void> _checkAuthentication() async {
  //   // Add a small delay to show splash screen (optional)
  //   await Future.delayed(const Duration(milliseconds: 1000));
  //
  //   // Check if token exists
  //   final token = await TokenStorage.getToken();
  //
  //   if (token != null && token.isNotEmpty) {
  //     // User is authenticated, get their data
  //     final userData = await TokenStorage.getUserData();
  //
  //     if (userData != null && userData.isNotEmpty) {
  //       try {
  //         final userMap = jsonDecode(userData);
  //         final user = UserModel.fromJson(userMap);
  //
  //         if (mounted) {
  //           Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(builder: (_) => HomePage(user: user)),
  //           );
  //         }
  //       } catch (e) {
  //         // If there's an error parsing user data, redirect to login
  //         _navigateToLogin();
  //       }
  //     } else {
  //       _navigateToLogin();
  //     }
  //   } else {
  //     _navigateToLogin();
  //   }
  // }
  Future<void> _checkAuthentication() async {
    // Add a small delay to show splash screen (optional)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check if token exists
    final token = await TokenStorage.getToken();
    print('Current token: $token'); // Add debug print

    if (token != null && token.isNotEmpty) {
      // User is authenticated, get their data
      final userData = await TokenStorage.getUserData();
      print('Current user data: $userData'); // Add debug print

      if (userData != null && userData.isNotEmpty) {
        try {
          final userMap = jsonDecode(userData);
          final user = UserModel.fromJson(userMap);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomePage(user: user)),
            );
          }
        } catch (e) {
          print('Error parsing user data: $e'); // Add debug print
          _navigateToLogin();
        }
      } else {
        print('No user data found'); // Add debug print
        _navigateToLogin();
      }
    } else {
      print('No token found, navigating to login'); // Add debug print
      _navigateToLogin();
    }
  }
  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant, size: 80, color: Colors.blue),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text('Loading...', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}