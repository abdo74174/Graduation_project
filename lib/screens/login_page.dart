import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/forget_password.dart';
import 'package:graduation_project/screens/info.dart';
import 'package:graduation_project/screens/register.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final ServerStatusService _statusService = ServerStatusService();

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
    if (_emailErr != null || _passErr != null) return;

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
    bool isDummyFail = false;

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
        print('Login success: $loginSuccess'); // Debug log

        if (loginSuccess) {
          userId = prefs.getString('user_id');
          if (userId == null) {
            print('Error: user_id not found in SharedPreferences after login');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login_id_error'.tr()),
                backgroundColor: Colors.red,
              ),
            );
            success = false;
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
          print('Server login failed: Invalid credentials or server error');
        }
      } catch (e) {
        print('Error during server login: $e');
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
              dummyUser.kindOfWork ?? 'Doctor',
              dummyUser.medicalSpecialist,
              dummyUser.isAdmin,
            );
      } else {
        isDummyFail = true;
        success = false;
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
          MaterialPageRoute(builder: (_) => DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(
              initialKindOfWork: kindOfWork,
              initialSpecialty: medicalSpecialist,
            ),
          ),
        );
      }
    } else {
      final msg = isDummyFail
          ? 'offline_login_fail'.tr()
          : (userId == null && _serverOnline
              ? 'login_credentials_error'.tr()
              : 'login_fail'.tr());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                        builder: (_) => const ForgotPasswordScreen()),
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
