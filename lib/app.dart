import 'package:flutter/material.dart';

// import 'views/login.dart';
import 'views/mobile_auth.dart';
// import 'views/signup.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // home: PhoneNumberVerificationPage(),
      home: const MobileAuthPage(),
    );
  }
}
