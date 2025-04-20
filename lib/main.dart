import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Override the HTTP client to allow invalid certificates for development purposes
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MedicalApp(isLoggedIn: isLoggedIn));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

class MedicalApp extends StatelessWidget {
  final bool isLoggedIn;

  const MedicalApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const WelcomePage(),
    );
  }
}
