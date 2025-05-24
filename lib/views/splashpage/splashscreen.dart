import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/token_storage.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Add a short delay for splash screen visibility
      await Future.delayed(const Duration(milliseconds: 1500));

      // Get token and user data directly from TokenStorage
      // The updated TokenStorage will check SharedPreferences if the static variables are null
      final token = await TokenStorage.getToken();
      final userDataString = await TokenStorage.getUserData();

      if (token != null && userDataString != null) {
        try {
          // Parse user data for the HomePage
          final userData = jsonDecode(userDataString);
          final user = UserModel.fromJson(userData);

          // Navigate to HomePage with the user data
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => HomePage(user: user)),
            );
          }
          return;
        } catch (e) {
          print('Error parsing user data: $e');
          // If we can't parse the user data, clear everything and go to login
          await TokenStorage.clear();
        }
      }

      // If no valid stored data, go to login page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      print('Error during auth check: $e');
      // On error, go to login page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your app logo
            Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Counter App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}