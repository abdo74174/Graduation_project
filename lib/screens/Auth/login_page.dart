// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/Auth/compelete_profile_screen.dart';
import 'package:graduation_project/screens/Auth/register.dart';
import 'package:graduation_project/screens/admin/admin_main_screen.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/password/forget_password.dart';
import 'package:graduation_project/screens/userInfo/info.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final ServerStatusService _statusService = ServerStatusService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _emailErr, _passErr;
  bool _serverOnline = true, _loggingIn = false, _allowOfflineLogin = false;
  bool _obscurePassword = true;
  int _count = 10;
  Timer? _timer;

  final String _dummyEmail = "user@gmail.com";
  final String _dummyPassword = "user";

  @override
  void initState() {
    super.initState();
    _statusService.getLastKnownStatus().then((flag) {
      setState(() => _serverOnline = flag);
      _checkServer();
    });
  }

  Future<void> _checkServer() async {
    final ok = await _statusService.checkAndUpdateServerStatus();
    if (!mounted) return;
    setState(() {
      _serverOnline = ok;
      _allowOfflineLogin = ok;
    });
    if (!ok) _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _count = 10;
    setState(() => _allowOfflineLogin = false);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count == 0) {
        t.cancel();
        setState(() => _allowOfflineLogin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('offline_mode_enabled'.tr())),
        );
      } else {
        setState(() => _count--);
      }
    });
  }

  void _validate() {
    setState(() {
      _emailErr = null;
      _passErr = null;
      final e = _emailCtrl.text.trim();
      final p = _passCtrl.text.trim();
      if (e.isEmpty) {
        _emailErr = 'email_empty'.tr();
      } else if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(e)) {
        _emailErr = 'email_invalid'.tr();
      }
      if (p.isEmpty) {
        _passErr = 'password_empty'.tr();
      }
    });
  }

  Future<void> _login() async {
    _validate();
    if (_emailErr != null || _passErr != null) {
      return;
    }

    setState(() => _loggingIn = true);

    if (!_allowOfflineLogin) {
      final ok = await _statusService.checkAndUpdateServerStatus();
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _serverOnline = false;
          _loggingIn = false;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('server_offline_msg'.tr())),
        );
        return;
      }
    }

    bool success = false;
    // ignore: unused_local_variable
    bool isDummyFail = false;
    String? errorMessage;

    String? userId;
    String? kindOfWork;
    String? medicalSpecialist;
    bool isAdmin = false;

    final prefs = await SharedPreferences.getInstance();

    if (_serverOnline) {
      try {
        final loginSuccess = await USerService().login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

        if (loginSuccess) {
          userId = prefs.getString('user_id');
          if (userId == null) {
            errorMessage = 'login_id_error'.tr();
          } else {
            success = true;
            kindOfWork = prefs.getString('kindOfWork') ?? 'Doctor';
            medicalSpecialist = prefs.getString('medicalSpecialist');
            isAdmin = prefs.getBool('isAdmin') ?? false;
            context.read<UserCubit>().setUser(
                  userId,
                  _emailCtrl.text.trim(),
                  kindOfWork,
                  medicalSpecialist,
                  isAdmin,
                );
          }
        } else {
          errorMessage = 'login_credentials_error'.tr();
        }
      } on FirebaseAuthException catch (e) {
        errorMessage = e.message ?? 'firebase_login_error'.tr();
        success = false;
      } on DioException catch (e) {
        errorMessage = e.response?.data['message'] ??
            e.response?.data?.toString() ??
            'login_fail'.tr();
        success = false;
      } catch (e) {
        errorMessage = 'login_fail'.tr();
        success = false;
      }
    } else {
      final inputEmail = _emailCtrl.text.trim().toLowerCase();
      final inputPassword = _passCtrl.text.trim();

      UserModel? dummyUser;
      try {
        dummyUser = dummyUsers.firstWhere(
          (u) => u.email.toLowerCase() == inputEmail,
          orElse: () => throw Exception('User not found'),
        );
      } catch (e) {
        dummyUser = null;
      }

      if (dummyUser != null && dummyUser.password == inputPassword) {
        success = true;
        userId = 'dummy_${inputEmail.hashCode}';
        await prefs.setString('user_id', userId);
        await prefs.setString('kindOfWork', dummyUser.kindOfWork ?? 'Doctor');
        if (dummyUser.medicalSpecialist != null) {
          await prefs.setString(
              'medicalSpecialist', dummyUser.medicalSpecialist!);
        } else {
          await prefs.remove('medicalSpecialist');
        }
        await prefs.setBool('isAdmin', dummyUser.isAdmin);
        context.read<UserCubit>().setUser(
              userId,
              _emailCtrl.text.trim(),
              dummyUser.kindOfWork,
              dummyUser.medicalSpecialist,
              dummyUser.isAdmin,
            );
      } else {
        isDummyFail = true;
        success = false;
        errorMessage = 'offline_login_fail'.tr();
      }
    }

    setState(() => _loggingIn = false);

    if (success) {
      final tok = prefs.getString('token') ?? 'dummy_token';
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', tok);
      await prefs.setString('email', _emailCtrl.text.trim());

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboardApp()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(
              initialKindOfWork: kindOfWork ?? 'Doctor',
              initialSpecialty: medicalSpecialist,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'login_fail'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loggingIn = true);

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loggingIn = false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase authentication failed');
      }

      // Check if the user exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      final prefs = await SharedPreferences.getInstance();
      String? kindOfWork;
      String? medicalSpecialist;
      bool isAdmin = false;

      if (!userDoc.exists) {
        // Save minimal user data to Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigate to CompleteProfileScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfileScreen(
              firebaseUser: firebaseUser,
              email: firebaseUser.email!,
            ),
          ),
        );
      } else {
        final userData = userDoc.data();
        kindOfWork = userData?['kindOfWork'] ?? 'Doctor';
        medicalSpecialist = userData?['medicalSpecialist'];
        isAdmin = userData?['isAdmin'] ?? false;

        // Save user data to backend
        final response = await http.post(
          Uri.parse('https://10.0.2.2:7273/api/MedBridge/signin/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'IdToken': googleAuth.idToken}),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userId = responseData['id']?.toString();
          if (userId == null) {
            throw Exception('Invalid backend response');
          }

          // Update SharedPreferences
          await prefs.setString('user_id', userId);
          await prefs.setString('kindOfWork', kindOfWork!);
          if (medicalSpecialist != null) {
            await prefs.setString('medicalSpecialist', medicalSpecialist);
          } else {
            await prefs.remove('medicalSpecialist');
          }
          await prefs.setBool('isAdmin', isAdmin);
          await prefs.setString(
              'token', responseData['token'] ?? 'firebase_token');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', firebaseUser.email!);

          // Update UserCubit
          context.read<UserCubit>().setUser(
                userId,
                firebaseUser.email!,
                kindOfWork,
                medicalSpecialist,
                isAdmin,
              );

          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RoleSelectionScreen(
                  initialKindOfWork: kindOfWork!,
                  initialSpecialty: medicalSpecialist,
                ),
              ),
            );
          }
        } else {
          throw Exception('Backend sign-in failed: ${response.body}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('google_sign_in_error'.tr() + ': $e')),
      );
    } finally {
      setState(() => _loggingIn = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Image.asset('assets/images/laboratory.png',
                  width: 160, height: 160),
              const SizedBox(height: 24),
              Text('login'.tr(),
                  style: const TextStyle(fontSize: 28, color: Colors.blue)),
              const SizedBox(height: 8),
              Text('login_continue'.tr()),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  hintText: 'email'.tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorText: _emailErr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                decoration: InputDecoration(
                  hintText: 'password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  errorText: _passErr,
                  border: const OutlineInputBorder(),
                ),
                obscureText: _obscurePassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgottenPasswordScreen()),
                  ),
                  child: Text('forgot_password'.tr()),
                ),
              ),
              if (!_serverOnline) ...[
                const SizedBox(height: 16),
                Text('server_offline_retrying'.tr(),
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _count / 10,
                        color: Colors.red,
                      ),
                    ),
                    Text('$_count', style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${'dummy_credentials'.tr()}\nEmail: $_dummyEmail\nPassword: $_dummyPassword',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              if (_serverOnline || _allowOfflineLogin)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loggingIn ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: _loggingIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _allowOfflineLogin && !_serverOnline
                                ? 'login_offline'.tr()
                                : 'login'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_serverOnline)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _loggingIn ? null : _loginWithGoogle,
                    icon: Image.asset('assets/images/google.png',
                        width: 24, height: 24),
                    label: Text(
                      'sign_in_with_google'.tr(),
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('no_account'.tr()),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterForm()),
                    ),
                    child: Text('register'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
