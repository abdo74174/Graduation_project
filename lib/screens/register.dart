import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/services/USer/sign.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
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
      _usernameError = 'Username cannot be empty';
    } else if (email.isEmpty ||
        !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      _emailError = 'Enter a valid email';
    } else if (password.isEmpty) {
      _passwordError = 'Password cannot be empty';
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$')
        .hasMatch(password)) {
      _passwordError =
          'Password must be at least 8 characters,\ninclude a letter, number, and symbol';
    } else if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
    } else if (password != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
    }
  }

  Future<void> _register() async {
    _validateForm();

    if (_usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Please wait..."),
            ],
          ),
        ),
      );

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'username': _usernameController.text.trim(),
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await USerService().signup(
            name: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

          if (mounted) {
            Navigator.of(context).pop(); // Dismiss loading dialog

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Please login.'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop(); // Dismiss loading dialog

        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is invalid.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'Registration failed: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Dismiss loading dialog

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {}); // Trigger UI update to show errors
    }
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _register,
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
                const Text("Already have an account? ",
                    style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  child: const Text('Login',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
