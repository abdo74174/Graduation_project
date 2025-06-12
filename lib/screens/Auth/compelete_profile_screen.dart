import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/screens/userInfo/info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User firebaseUser;
  final String email;

  const CompleteProfileScreen({
    Key? key,
    required this.firebaseUser,
    required this.email,
  }) : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalSpecialistController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _medicalSpecialistController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      // Prepare user data
      final userData = {
        'email': widget.email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'medicalSpecialist': _medicalSpecialistController.text.isNotEmpty
            ? _medicalSpecialistController.text.trim()
            : null,
        'kindOfWork': 'Doctor',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'name': widget.firebaseUser.displayName ?? 'Google User',
        'password': _passwordController.text.trim(),
        'confirmPassword': _confirmPasswordController.text.trim(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.firebaseUser.uid)
          .set({
        'email': widget.email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'medicalSpecialist': _medicalSpecialistController.text.isNotEmpty
            ? _medicalSpecialistController.text.trim()
            : null,
        'kindOfWork': 'Doctor',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'name': widget.firebaseUser.displayName ?? 'Google User',
      }, SetOptions(merge: true));

      // Save to backend
      final response = await http.post(
        Uri.parse(
            'https://10.0.2.2:7273/api/MedBridge/signin/google/complete-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', responseData['id'].toString());
        await prefs.setString('kindOfWork', responseData['kindOfWork'] ?? '');
        await prefs.setInt(
            'status', UserStatus.deactivated.index); // Assuming UserStatus enum
        if (responseData['medicalSpecialist'] != null) {
          await prefs.setString(
              'medicalSpecialist', responseData['medicalSpecialist']);
        } else {
          await prefs.remove('medicalSpecialist');
        }
        await prefs.setBool('isAdmin', responseData['isAdmin'] ?? false);
        await prefs.setString('token', responseData['token'] ?? '');
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', widget.email);

        context.read<UserCubit>().setUser(
              responseData['id'],
              widget.email,
              responseData['kindOfWork'] ?? '',
              responseData['medicalSpecialist'],
              responseData['isAdmin'] ?? false,
            );

        print(
            'Profile completion successful, navigating to RoleSelectionScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(
              initialKindOfWork: 'Doctor',
              initialSpecialty: _medicalSpecialistController.text.isNotEmpty
                  ? _medicalSpecialistController.text.trim()
                  : null,
            ),
          ),
        );
      } else {
        print('Backend profile completion failed: ${response.body}');
        throw Exception('Backend profile completion failed: ${response.body}');
      }
    } catch (e) {
      print('Error completing profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_completion_error'.tr() + ': $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('complete_profile'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'phone'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'phone_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'address'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'address_required'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicalSpecialistController,
                  decoration: InputDecoration(
                    labelText: 'medical_specialist_optional'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password'.tr(),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'password_required'.tr();
                    }
                    if (value.length < 6) {
                      return 'password_too_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr(),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'confirm_password_required'.tr();
                    }
                    if (value != _passwordController.text) {
                      return 'passwords_do_not_match'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'complete_profile'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
