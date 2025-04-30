import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/screens/password/Password%20Reset%20Screen%20.dart';
import 'package:graduation_project/services/passwordReset.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _message = '';
  bool _isLoading = false;
  final ForgotPasswordService _forgotPasswordService =
      ForgotPasswordService(dio: Dio());

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _message = 'Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _message = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      debugPrint('Checking Firebase user for email: $email');
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      final isFirebaseUser = methods.isNotEmpty;
      debugPrint('Is Firebase user: $isFirebaseUser');

      if (isFirebaseUser) {
        if (!mounted) return;
        debugPrint('Navigating to PasswordResetScreen for Firebase user');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetScreen(
              email: email,
              isFirebaseUser: true,
            ),
          ),
        );
      } else {
        debugPrint('Sending OTP for email: $email');
        var response = await _forgotPasswordService.sendOtp(email);
        debugPrint('Send OTP response: $response');

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          if (response['success'] == true) {
            debugPrint('Navigating to PasswordResetScreen for OTP flow');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PasswordResetScreen(email: email),
              ),
            );
            _emailController.clear();
          } else {
            _message =
                response['message'] ?? 'An error occurred. Please try again.';
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
      setState(() {
        _isLoading = false;
        _message = _getFirebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = 'Failed to connect to server. Please check your connection.';
      });
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      debugPrint('Navigating back to LoginPage');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please enter your email to reset your password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Image.asset(
                  'assets/images/computer-security-with-login-password-padlock.jpg',
                  height: 160),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your email",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.toLowerCase().contains('error') ||
                            _message.toLowerCase().contains('invalid')
                        ? Colors.red
                        : Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
