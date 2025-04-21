import 'package:flutter/material.dart';
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

  String? _emailError;
  String? _passwordError;

  Future<void> saveLoginState(
      String token, String userId, String email, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', token);
    await prefs.setString('userId', userId); // Save user ID
    await prefs.setString('email', email); // Save email
    await prefs.setString('username', username); // Save username
  }

  void _validateForm() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String email = emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email cannot be empty');
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email');
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
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
              padding: const EdgeInsets.symmetric(vertical: 4),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    _validateForm();
                    if (_emailError != null || _passwordError != null) return;

                    final success = await USerService().login(
                      email: emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );

                    if (success) {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token') ?? '';
                      final userId = prefs.getString('userId') ?? '';
                      final email = prefs.getString('email') ?? '';
                      final username = prefs.getString('username') ?? '';

                      // Save additional user data in SharedPreferences
                      await saveLoginState(token, userId, email, username);

                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoleSelectionScreen(),
                        ),
                      );

                      showSnackbar(context, "Login Successful");
                    } else {
                      showSnackbar(
                          context, "Login Failed: Incorrect email or password");
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
            Row(
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
          ],
        ),
      ),
    );
  }
}
