//
// import 'package:flutter/material.dart';
//
// import 'Authentication/login.dart';
// import 'Authentication/otp_page.dart';
// import 'Authentication/registration.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sheba One',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//       routes: {
//         '/login': (context) => const LoginPage(),
//         '/register': (context) => const RegisterPage(),
//         '/otp': (context) => const OtpVerificationPage(mobile: '',),
//         '/home': (context) => const HomePage(),
//       },
//     );
//   }
// }


// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:object/questions_page.dart';

import 'Authentication/login.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheba One',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/question_page',
      routes: {
        '/question_page': (context) =>  QuestionsPage(),
        //'/otp': (context) => const OtpVerificationPage(mobile: '',),

      },
    );
  }
}
