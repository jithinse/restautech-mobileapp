// import 'package:flutter/material.dart';
//
<<<<<<< HEAD
// import '../ views/auth/login_page.dart';
=======
// import '../views/auth/login_page.dart';
//
//
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
<<<<<<< HEAD
//       title: 'Login Demo',
=======
//       debugShowCheckedModeBanner: false,
//       title: 'Counter ',
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:waiterapr04/views/splashpage/splashscreen.dart';

 // adjust path to your login page

class MyApp extends StatelessWidget {
  const MyApp({super.key});
=======

import 'package:flutter/material.dart';

import '../views/splashscreen/splashscreen.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
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
=======
      debugShowCheckedModeBanner: false,
      title: 'Counter ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
>>>>>>> 99e1abe077ecd4f17b54ef1dd4154a9f4432b6a5
