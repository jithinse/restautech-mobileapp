// import 'package:flutter/material.dart';
//
// import '../ views/auth/login_page.dart';
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Login Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:waiterapr04/views/splashpage/splashscreen.dart';

 // adjust path to your login page

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      debugShowCheckedModeBanner: false, // ✅ Hides debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // use true if you're using Material 3
      ),
      home: const SplashPage(), // or whatever your start page is
    );
  }
}
