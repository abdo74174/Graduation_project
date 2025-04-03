import 'package:flutter/material.dart';
import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/screens/login_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      setState(() => _usernameError = 'Username cannot be empty');
      return;
    }

    if (email.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ).hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty');
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      return;
    }

    // Proceed with registration logic
    // ignore: avoid_print
    print("Registration Successful!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Image(
              image: AssetImage('assets/images/badge.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Register',
              style: TextStyle(
                color: Color(0xFF3B8FDA),
                fontSize: 30,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to start using the app',
              textAlign: TextAlign.center,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.7),
                fontSize: 16,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 20),
            CustomInputField(
              hint: 'Enter Your Username',
              icon: Icons.person_outline,
              controller: _usernameController,
              isPassword: false,
              errorText: _usernameError,
            ),
            CustomInputField(
              hint: 'Enter Your Email',
              icon: Icons.email_outlined,
              controller: _emailController,
              isPassword: false,
              errorText: _emailError,
            ),
            CustomInputField(
              hint: 'Enter Your Password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              errorText: _passwordError,
            ),
            CustomInputField(
              hint: 'Confirm Your Password',
              icon: Icons.lock_outline,
              controller: _confirmPasswordController,
              isPassword: true,
              errorText: _confirmPasswordError,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E84D7),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _validateForm,
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
