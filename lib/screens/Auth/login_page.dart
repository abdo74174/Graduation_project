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
import 'package:graduation_project/screens/Auth/account_status_screen.dart';
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
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _statusService.getLastKnownStatus().then((flag) {
      setState(() => _serverOnline = flag);
      print('DEBUG: Initial server status: $flag');
      _checkServer();
    });
  }

  Future<void> fetchUserData(String email) async {
    try {
      final fetchedUser = await USerService().fetchUserByEmail(email);
      if (fetchedUser == null) {
        throw Exception("User not found for email: $email");
      }
      if (fetchedUser.status == null) {
        print('DEBUG: User status is null, setting to deactivated');
        fetchedUser.status = UserStatus.deactivated;
      }
      setState(() {
        user = fetchedUser;
      });
      print('DEBUG: User fetched: ${user!.email}, Status: ${user!.status}');
    } catch (e) {
      setState(() {
        user = null;
      });
      print('DEBUG: Error fetching user data: $e');
      rethrow;
    }
  }

  Future<void> _checkServer() async {
    final ok = await _statusService.checkAndUpdateServerStatus();
    if (!mounted) return;
    setState(() {
      _serverOnline = ok;
      _allowOfflineLogin = ok;
    });
    print('DEBUG: Server check result: $ok');
    if (!ok) _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _count = 10;
    setState(() => _allowOfflineLogin = false);
    print('DEBUG: Starting countdown for offline login');
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count == 0) {
        t.cancel();
        setState(() => _allowOfflineLogin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('offline_mode_enabled'.tr())),
        );
        print('DEBUG: Offline login enabled');
      } else {
        setState(() => _count--);
        print('DEBUG: Countdown: $_count');
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
    print(
        'DEBUG: Validation - Email error: $_emailErr, Password error: $_passErr');
  }

  Future<bool> _handleUserStatus(UserModel user, BuildContext context) async {
    print('DEBUG: Handling UserStatus: ${user.status}');
    if (user.status == UserStatus.blocked ||
        user.status == UserStatus.deactivated) {
      if (!context.mounted) return true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccountStatusScreen(status: user.status),
        ),
      );
      print(
          'DEBUG: Navigated to AccountStatusScreen with status: ${user.status}');
      return true;
    }
    return false;
  }

  Future<void> _login() async {
    _validate();
    if (_emailErr != null || _passErr != null) {
      print('DEBUG: Validation failed, aborting login');
      return;
    }

    setState(() => _loggingIn = true);
    print('DEBUG: Starting login with email: ${_emailCtrl.text.trim()}');

    if (!_allowOfflineLogin && !_serverOnline) {
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
        print('DEBUG: Server offline, starting countdown');
        return;
      }
    }

    bool success = false;
    String? errorMessage;

    String? userId;
    String? kindOfWork;
    String? medicalSpecialist;
    bool isAdmin = false;
    UserStatus? status;

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
            throw Exception('login_id_error'.tr());
          }

          await fetchUserData(_emailCtrl.text.trim());
          if (user == null) {
            throw Exception('user_fetch_error'.tr());
          }

          if (await _handleUserStatus(user!, context)) return;

          success = true;
          kindOfWork = user!.kindOfWork;
          medicalSpecialist = user!.medicalSpecialist;
          isAdmin = user!.isAdmin;
          status = user!.status;

          await prefs.setString('kindOfWork', kindOfWork ?? '');
          if (medicalSpecialist != null) {
            await prefs.setString('medicalSpecialist', medicalSpecialist);
          } else {
            await prefs.remove('medicalSpecialist');
          }
          await prefs.setBool('isAdmin', isAdmin);
          await prefs.setInt('status', status!.index);
          await prefs.setString('email', _emailCtrl.text.trim());
          print(
              'DEBUG: Saved to SharedPreferences - status: ${status!.index}, isAdmin: $isAdmin');

          context.read<UserCubit>().setUser(
                userId,
                _emailCtrl.text.trim(),
                kindOfWork ?? '',
                medicalSpecialist,
                isAdmin,
              );
        } else {
          errorMessage = 'login_credentials_error'.tr();
        }
      } catch (e) {
        errorMessage = e.toString().contains('Exception')
            ? e.toString().replaceFirst('Exception: ', '')
            : 'login_fail'.tr();
        success = false;
        print('DEBUG: Login error: $e');
      } on DioException catch (e) {
        errorMessage = e.response?.data['message'] ??
            e.response?.data?.toString() ??
            'login_fail'.tr();
        success = false;
        print('DEBUG: DioException: ${e.message}');
      }
    } else {
      // Offline login
      final inputEmail = _emailCtrl.text.trim().toLowerCase();
      final inputPassword = _passCtrl.text.trim();

      UserModel? dummyUser;
      try {
        dummyUser = dummyUsers.firstWhere(
          (u) => u.email.toLowerCase() == inputEmail,
          orElse: () => throw Exception('User not found'),
        );
        print('DEBUG: Offline login - Dummy user found: ${dummyUser.email}');
      } catch (e) {
        dummyUser = null;
        print('DEBUG: Offline login - User not found: $e');
      }

      if (dummyUser != null && dummyUser.password == inputPassword) {
        if (dummyUser.status == null) {
          dummyUser.status = UserStatus.deactivated;
          print('DEBUG: Dummy user status is null, set to deactivated');
        }

        if (await _handleUserStatus(dummyUser, context)) return;

        success = true;
        userId = 'dummy_${inputEmail.hashCode}';
        setState(() {
          user = dummyUser;
        });
        kindOfWork = dummyUser.kindOfWork;
        medicalSpecialist = dummyUser.medicalSpecialist;
        isAdmin = dummyUser.isAdmin;
        status = dummyUser.status;

        await prefs.setString('user_id', userId);
        await prefs.setString('kindOfWork', kindOfWork ?? '');
        await prefs.setInt('status', status!.index);
        await prefs.setString('email', inputEmail);
        if (medicalSpecialist != null) {
          await prefs.setString('medicalSpecialist', medicalSpecialist);
        } else {
          await prefs.remove('medicalSpecialist');
        }
        await prefs.setBool('isAdmin', isAdmin);
        print(
            'DEBUG: Offline login - Saved to SharedPreferences - status: ${status!.index}');

        context.read<UserCubit>().setUser(
              userId,
              inputEmail,
              kindOfWork ?? '',
              medicalSpecialist,
              isAdmin,
            );
      } else {
        errorMessage = 'offline_login_fail'.tr();
        print('DEBUG: Offline login failed: Invalid credentials');
      }
    }

    setState(() => _loggingIn = false);

    if (success) {
      await prefs.setBool('isLoggedIn', true);
      print('DEBUG: Login successful, navigating to next screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (kindOfWork?.isNotEmpty ?? false)
              ? const HomePage()
              : RoleSelectionScreen(
                  initialKindOfWork: 'doctor',
                ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'login_fail'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      print('DEBUG: Login failed: $errorMessage');
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loggingIn = true);
    print('DEBUG: Starting Google Sign-In');

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _loggingIn = false);
        print('DEBUG: Google Sign-In cancelled');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase authentication failed');
      }
      print('DEBUG: Google Sign-In user: ${firebaseUser.email}');

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      print('DEBUG: Firestore user data: ${userDoc.data()}');

      final prefs = await SharedPreferences.getInstance();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'deactivated', // Default status for new users
        });
        print('DEBUG: Created new Firestore user with status: deactivated');

        setState(() => _loggingIn = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfileScreen(
              firebaseUser: firebaseUser,
              email: firebaseUser.email!,
            ),
          ),
        );
        print('DEBUG: Navigated to CompleteProfileScreen');
      } else {
        final response = await http.post(
          Uri.parse('https://10.0.2.2:7273/api/MedBridge/signin/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'IdToken': googleAuth.idToken}),
        );
        print('DEBUG: Google Sign-In backend response: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final userId = responseData['id']?.toString();
          if (userId == null) {
            throw Exception('Invalid backend response');
          }

          await fetchUserData(firebaseUser.email!);
          if (user == null) {
            throw Exception('Failed to fetch user data');
          }

          if (await _handleUserStatus(user!, context)) return;

          await prefs.setString('user_id', userId);
          await prefs.setString('kindOfWork', user!.kindOfWork);
          await prefs.setInt('status', user!.status.index);
          if (user!.medicalSpecialist != null) {
            await prefs.setString(
                'medicalSpecialist', user!.medicalSpecialist!);
          } else {
            await prefs.remove('medicalSpecialist');
          }
          await prefs.setBool('isAdmin', user!.isAdmin);
          await prefs.setString(
              'token', responseData['token'] ?? 'firebase_token');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', firebaseUser.email!);
          print(
              'DEBUG: Google Sign-In - Saved to SharedPreferences - status: ${user!.status.index}');

          context.read<UserCubit>().setUser(
                userId,
                firebaseUser.email!,
                user!.kindOfWork,
                user!.medicalSpecialist,
                user!.isAdmin,
              );

          setState(() => _loggingIn = false);
          print('DEBUG: Google Sign-In successful, navigating to next screen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => (user!.kindOfWork.isNotEmpty)
                  ? const HomePage()
                  : RoleSelectionScreen(
                      initialKindOfWork: 'doctor',
                    ),
            ),
          );
        } else {
          throw Exception('Backend sign-in failed: ${response.body}');
        }
      }
    } catch (e) {
      setState(() => _loggingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('Exception')
              ? e.toString().replaceFirst('Exception: ', '')
              : '${'google_sign_in_error'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('DEBUG: Google Sign-In error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
    print('DEBUG: LoginPage disposed');
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
                  ? [Colors.black, Color(0xFF1A1A1A)]
                  : [Color(0xFF3B8FDA).withOpacity(0.1), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/images/AppIcon.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back'.tr(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Sign in to continue'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email'.tr(),
                    prefixIcon: Icons.email_outlined,
                    error: _emailErr,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passCtrl,
                    label: 'Password'.tr(),
                    prefixIcon: Icons.lock_outline,
                    error: _passErr,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                      print(
                          'DEBUG: Toggled password visibility: $_obscurePassword');
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgottenPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        'Forgot Password?'.tr(),
                        style: TextStyle(
                          color: Color(0xFF3B8FDA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loggingIn ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B8FDA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _loggingIn
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Login'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with'.tr(),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        'assets/images/google.png',
                        onTap: _loginWithGoogle,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterForm(),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          children: [
                            TextSpan(text: "Don't have an account? ".tr()),
                            TextSpan(
                              text: 'Register'.tr(),
                              style: TextStyle(
                                color: Color(0xFF3B8FDA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && obscureText,
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
                    : Color(0xFF3B8FDA),
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
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialButton(String iconPath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Image.asset(iconPath),
        ),
      ),
    );
  }
}
