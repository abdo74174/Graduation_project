// ignore_for_file: use_build_context_synchronously
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/services/passwordReset.dart';
import 'package:easy_localization/easy_localization.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  final bool isFirebaseUser;

  const PasswordResetScreen({
    Key? key,
    required this.email,
    this.isFirebaseUser = false,
  }) : super(key: key);

  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ForgotPasswordService _forgotPasswordService =
      ForgotPasswordService(dio: Dio());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _otpErr, _newPasswordErr, _confirmPasswordErr;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool isPasswordValid(String password) {
    final regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    return regex.hasMatch(password);
  }

  void _validate() {
    setState(() {
      _otpErr = null;
      _newPasswordErr = null;
      _confirmPasswordErr = null;

      final otp = _otpController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (!widget.isFirebaseUser && otp.isEmpty) {
        _otpErr = 'otp_empty'.tr();
      }
      if (newPassword.isEmpty) {
        _newPasswordErr = 'password_empty'.tr();
      } else if (!isPasswordValid(newPassword)) {
        _newPasswordErr =
            'Password must contain 8+ chars, 1 letter, 1 number, and 1 special character'
                .tr();
      }
      if (confirmPassword.isEmpty) {
        _confirmPasswordErr = 'confirm_password_empty'.tr();
      } else if (newPassword != confirmPassword) {
        _confirmPasswordErr = 'passwords_do_not_match'.tr();
      }
    });
  }

  Future<void> _resetPassword() async {
    _validate();
    if (_otpErr != null ||
        _newPasswordErr != null ||
        _confirmPasswordErr != null) {
      return;
    }

    if (widget.isFirebaseUser) {
      await _resetPasswordWithFirebase();
    } else {
      await _resetPasswordWithOtp();
    }
  }

  Future<void> _resetPasswordWithFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Password reset email sent. Please check your inbox.'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      debugPrint('Navigating to LoginPage after Firebase reset');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFirebaseErrorMessage(e).tr()),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPasswordWithOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _forgotPasswordService.verifyOtp(
        widget.email,
        _otpController.text.trim(),
        _newPasswordController.text.trim(),
      );
      debugPrint(
          'Received verify OTP response in PasswordResetScreen: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        final customToken = response['customToken'] as String?;
        if (customToken == null || customToken.isEmpty) {
          debugPrint('Custom token is missing or empty');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Authentication token missing from server response. Please try again.'
                      .tr()),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        debugPrint('Attempting to sign in with custom token');
        await _auth.signInWithCustomToken(customToken);
        final user = _auth.currentUser;

        if (user != null && user.email == widget.email) {
          debugPrint('Updating password for user: ${user.email}');
          await user.updatePassword(_newPasswordController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          debugPrint('Navigating to LoginPage after OTP reset');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          debugPrint(
              'User mismatch: expected ${widget.email}, got ${user?.email}');
          throw FirebaseAuthException(
            code: 'user-mismatch',
            message: 'Signed-in user does not match the provided email',
          );
        }
      } else {
        debugPrint('Password reset failed: ${response['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ??
                'Failed to reset password. Please try again.'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFirebaseErrorMessage(e).tr()),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'An error occurred. Please check your connection or try again.'
                  .tr()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-custom-token':
        return 'Invalid authentication token. Please try again.';
      case 'user-mismatch':
        return 'User email does not match. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'The authentication credential is invalid or expired. Please try again.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [Colors.black, const Color(0xFF1A1A1A)]
                  : [const Color(0xFF3B8FDA).withOpacity(0.1), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/reset-password.jpg',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Reset Password'.tr(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    widget.isFirebaseUser
                        ? 'Enter new password for ${widget.email}'.tr()
                        : 'Enter the OTP sent to ${widget.email}'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!widget.isFirebaseUser) ...[
                    _buildTextField(
                      controller: _otpController,
                      label: 'OTP Code'.tr(),
                      prefixIcon: Icons.lock_outline,
                      error: _otpErr,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(
                    controller: _newPasswordController,
                    label: 'New Password'.tr(),
                    prefixIcon: Icons.lock_outline,
                    error: _newPasswordErr,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Must contain at least 8 characters, including 1 letter, 1 number, and 1 special character'
                        .tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password'.tr(),
                    prefixIcon: Icons.lock_outline,
                    error: _confirmPasswordErr,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B8FDA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Reset Password'.tr(),
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    String? error,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null ? Colors.red : Colors.transparent,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF3B8FDA),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              counterText: maxLength != null ? '' : null,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
