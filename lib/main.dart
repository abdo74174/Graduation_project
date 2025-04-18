import 'package:flutter/material.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MedicalApp(isLoggedIn: isLoggedIn));
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
