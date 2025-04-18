// ignore: must_be_immutable
// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/forget_password.dart';
import 'package:graduation_project/screens/info.dart';
import 'package:graduation_project/screens/register.dart';
import 'package:graduation_project/services/Sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId); // optional: store user id
  }

  String? _emailError;

  String? _passwordError;

  void clear() {
    emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Image(
            image: AssetImage('assets/images/laboratory.png'),
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'Login',
            style: TextStyle(
              color: Color(0xFF3B8FDA),
              fontSize: 30,
              fontFamily: 'Oswald',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Login to continue for Using App',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Oswald',
            ),
          ),
          const SizedBox(height: 20),
          CustomInputField(
            controller: emailController,
            hint: 'Enter Your Email',
            icon: Icons.email_outlined,
            isPassword: false,
            errorText: _emailError,
          ),
          CustomInputField(
            controller: _passwordController,
            hint: 'Enter Your Password',
            icon: Icons.lock_outline,
            isPassword: true,
            errorText: _passwordError,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forget your password?',
                  style: TextStyle(color: pkColor, fontSize: 14),
                ),
              ),
            ),
          ),
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
                onPressed: () async {
                  _validateForm();

                  if (_emailError != null || _passwordError != null) {
                    return;
                  }
                  bool isLoggedIn = LoginSuccess();

                  if (isLoggedIn) {
                    // for clear controllers
                    // clear();

                    await saveLoginState(emailController.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoleSelectionScreen(),
                      ),
                    );
                    showSnackbar(context, "Login Sucesssssss");
                  }
                },
                child: const Text(
                  'Login',
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
                const Text("Don't have an account? ",
                    style: TextStyle(color: Colors.black, fontSize: 14)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return RegisterForm();
                    }));
                  },
                  child: const Text('Register',
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              onPressed: () {},
              icon: Image.asset('assets/images/google.png', height: 30),
              label: const Text(
                'Sign in with Google',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool LoginSuccess() {
    _validateForm();
    if (_emailError == null && _passwordError == null) {
      USerService().login(
          email: emailController.text, password: _passwordController.text);
      return true;
    }

    return false;
  }

  // ignore: unused_element
  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String email = emailController.text;
    String password = _passwordController.text;

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
  }

  // Future<User> fetchUser() async {
  //   User user;
  //   try {
  //     user = await USerService()
  //         .GetUser(Email: emailController.text); // Pass the user ID

  //     return user;
  //     print('User fetched: ${user.name}, ${user.email}');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  //     return new use;
  // }
}
