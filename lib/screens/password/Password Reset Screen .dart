import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/services/passwordReset.dart';

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
  String _message = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool isPasswordValid(String password) {
    final regex = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _resetPassword() async {
    if (widget.isFirebaseUser) {
      await _resetPasswordWithFirebase();
    } else {
      await _resetPasswordWithOtp();
    }
  }

  Future<void> _resetPasswordWithFirebase() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      setState(() => _message = 'Please enter a new password');
      return;
    }

    if (!isPasswordValid(newPassword)) {
      setState(() {
        _message =
            'Password must contain 8+ chars, 1 letter, 1 number, and 1 special character';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _message = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _auth.sendPasswordResetEmail(email: widget.email);
      setState(() {
        _isLoading = false;
        _message = 'Password reset email sent. Please check your inbox.';
      });

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      debugPrint('Navigating to LoginPage after Firebase reset');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}, ${e.message}');
      setState(() {
        _isLoading = false;
        _message = _getFirebaseErrorMessage(e);
      });
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _message = 'An error occurred: ${e.toString()}';
      });
    }
  }

  Future<void> _resetPasswordWithOtp() async {
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty) {
      setState(() => _message = 'Please enter the OTP');
      return;
    }

    if (newPassword.isEmpty) {
      setState(() => _message = 'Please enter a new password');
      return;
    }

    if (!isPasswordValid(newPassword)) {
      setState(() {
        _message =
            'Password must contain 8+ chars, 1 letter, 1 number, and 1 special character';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _message = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await _forgotPasswordService.verifyOtp(
          widget.email, otp, newPassword);
      debugPrint(
          'Received verify OTP response in PasswordResetScreen: $response');

      if (!mounted) return;

      if (response['success'] == true) {
        final customToken = response['customToken'] as String?;
        if (customToken == null || customToken.isEmpty) {
          debugPrint('Custom token is missing or empty');
          setState(() {
            _isLoading = false;
            _message =
                'Authentication token missing from server response. Please try again.';
          });
          return;
        }

        debugPrint('Attempting to sign in with custom token');
        await _auth.signInWithCustomToken(customToken);
        final user = _auth.currentUser;

        if (user != null && user.email == widget.email) {
          debugPrint('Updating password for user: ${user.email}');
          await user.updatePassword(newPassword);
          setState(() {
            _isLoading = false;
            _message = 'Password reset successfully';
          });

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
        setState(() {
          _isLoading = false;
          _message = response['message'] ??
              'Failed to reset password. Please try again.';
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
        _message =
            'An error occurred. Please check your connection or try again.';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              widget.isFirebaseUser
                  ? 'Enter new password for ${widget.email}'
                  : 'Enter the OTP sent to ${widget.email}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            if (!widget.isFirebaseUser) ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(), // Fixed: Removed 'the'
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 10),
            Text(
              'Must contain at least 8 characters, including 1 letter, 1 number, and 1 special character',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(), // Fixed: Removed 'the'
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              obscureText: _obscureConfirmPassword,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reset Password'),
              ),
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.toLowerCase().contains('fail') ||
                          _message.toLowerCase().contains('invalid') ||
                          _message.toLowerCase().contains('error')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
          ],
        ),
      ),
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
