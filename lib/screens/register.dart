import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

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
  bool _isLoading = false;

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

      String username = _usernameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (username.isEmpty) {
        _usernameError = 'username_error'.tr();
      }
      if (email.isEmpty ||
          !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
        _emailError = 'email_error'.tr();
      }
      if (password.isEmpty) {
        _passwordError = 'password_error'.tr();
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$')
          .hasMatch(password)) {
        _passwordError = 'password_pattern_error'.tr();
      }
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'confirm_password_error'.tr();
      } else if (password != confirmPassword) {
        _confirmPasswordError = 'password_mismatch'.tr();
      }
    });
  }

  Future<void> _register() async {
    _validateForm();

    if (_usernameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user_id already exists
      final prefs = await SharedPreferences.getInstance();
      final existingUserId = prefs.getString('user_id');
      if (existingUserId != null) {
        print(
            'Warning: Existing user_id found: $existingUserId. Clearing for new signup.');
        await prefs.clear(); // Clear all SharedPreferences for a fresh signup
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup_existing_user_error'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Perform signup
      await USerService().signup(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        isAdmin: false,
      );

      // Verify user_id and email after signup
      final userId = prefs.getString('user_id');
      final email = prefs.getString('email');

      if (userId == null || email == null) {
        print(
            'Error: user_id or email not found in SharedPreferences after signup');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup_id_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Set user state in UserCubit
      context.read<UserCubit>().setUser(
            userId,
            email,
            'Doctor', // Default kindOfWork as per UserController
            null, // medicalSpecialist is null initially
            false, // isAdmin is false
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signup_failed'.tr() + ': $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Image(
                    image: AssetImage('assets/images/badge.png'),
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'register'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF3B8FDA),
                      fontSize: 30,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'create_account'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 16,
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomInputField(
                    hint: 'enter_username'.tr(),
                    icon: Icons.person_outline,
                    controller: _usernameController,
                    isPassword: false,
                    errorText: _usernameError,
                  ),
                  CustomInputField(
                    hint: 'enter_email'.tr(),
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    isPassword: false,
                    errorText: _emailError,
                  ),
                  CustomInputField(
                    hint: 'enter_password'.tr(),
                    icon: Icons.lock_outline,
                    controller: _passwordController,
                    isPassword: true,
                    errorText: _passwordError,
                  ),
                  CustomInputField(
                    hint: 'confirm_password'.tr(),
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
                          vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child: Text(
                      'register_button'.tr(),
                      style: const TextStyle(
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
                      Text("already_have_account".tr(),
                          style: const TextStyle(fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        ),
                        child: Text('login'.tr(),
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
