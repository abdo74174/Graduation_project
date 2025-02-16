// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:graduation_project/screens/login_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterFormState createState() => _RegisterFormState();
}

//

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
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
              color: Colors.black.withOpacity(0.7),
              fontSize: 16,
              fontFamily: 'Oswald',
            ),
          ),
          const SizedBox(height: 20),
          inputField('Enter Your Username', Icons.person_outline,
              _usernameController, false,
              errorText: _usernameError),
          inputField(
              'Enter Your Email', Icons.email_outlined, _emailController, false,
              errorText: _emailError),
          inputField('Enter Your Password', Icons.lock_outline,
              _passwordController, true,
              errorText: _passwordError),
          inputField('Confirm Your Password', Icons.lock_outline,
              _confirmPasswordController, true,
              errorText: _confirmPasswordError),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3E84D7),
                    Color(0xFF407BD4),
                    Color(0xFF4A50C6)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _validateForm,
                child: const Text(
                  'Register',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? ",
                    style: TextStyle(color: Colors.black, fontSize: 14)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }));
                  },
                  child: const Text('Login',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ////

  Widget inputField(String hint, IconData icon,
      TextEditingController controller, bool isPassword,
      {String? errorText}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (icon == Icons.lock_outline
                ? _isPasswordHidden
                : _isConfirmPasswordHidden)
            : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isPassword ? _isPasswordHidden : _isConfirmPasswordHidden)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _isPasswordHidden = !_isPasswordHidden;
                      } else {
                        _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                      }
                    });
                  },
                )
              : null,
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black12),
          ),
          errorText: errorText,
        ),
      ),
    );
  }

  void _validateForm() {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username cannot be empty';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    //print("Username: $username");
    // print("Email: $email");
    // print("Password: $password");
    // print("Confirm Password: $confirmPassword");
  }
}
