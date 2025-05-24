import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiter/Controllers/auth_controller.dart';
import 'package:waiter/login/loginpage.dart';
import 'package:waiter/pages/restaruntlayout.dart';
import 'package:waiter/pages/todaysmenu.dart';

import 'package:waiter/provider/cartprovider2.dart';
import 'package:waiter/utils/catgoryprovider.dart';
import 'package:waiter/utils/menuprovider.dart';

import 'package:waiter/utils/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await _checkAuthState();
  runApp(
      MyApp(initialRoute: isLoggedIn ? '/RestaurantPlannerScreen' : '/login'));
}

Future<bool> _checkAuthState() async {
  try {
    final token = await TokenStorage.getToken();
    if (token == null) return false;
    final user = await AuthController.getCachedUserData();
    return user != null;
  } catch (e) {
    print('Error during auth state check: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Restaurant Waiter App',
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/RestaurantPlannerScreen': (context) => TableManagementScreen(),
          '/TodaysMenuScreen': (context) {
            // Get the arguments passed when navigating to this route
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?;
            return MenuScreen(
              tableId: args?['tableId'] ?? 0, // Default value if null
              tableNumber: args?['tableNumber'] ?? '', // Default value if null
            );
          },
        },
        // Optional: Handle unknown routes
        onGenerateRoute: (settings) {
          // You can add additional route handling here if needed
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        },
      ),
    );
  }
}
