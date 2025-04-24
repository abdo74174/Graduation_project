import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/forget_password.dart';
import 'package:graduation_project/screens/register.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/USer/sign.dart';
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
  int _count = 10;
  Timer? _timer;

  String _dummyEmail = "user@gmail.com";
  String _dummyPassword = "user";

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
      if (e.isEmpty)
        _emailErr = 'email_empty'.tr();
      else if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(e))
        _emailErr = 'email_invalid'.tr();
      if (p.isEmpty) _passErr = 'password_empty'.tr();
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

    if (_serverOnline) {
      success = await USerService().login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
    } else {
      final inputEmail = _emailCtrl.text.trim().toLowerCase();
      final inputPassword = _passCtrl.text.trim();

      User? dummmyUser;
      try {
        dummmyUser = dummyUsers.firstWhere(
          (u) => u.email.toLowerCase() == inputEmail,
        );
      } catch (e) {
        dummmyUser = null;
      }

      if (dummmyUser != null && dummmyUser.password == inputPassword) {
        success = true;
      } else {
        isDummyFail = true;
        success = false;
      }
    }

    setState(() => _loggingIn = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final tok = prefs.getString('token') ?? 'dummy_token';
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', tok);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      final msg = isDummyFail ? 'offline_login_fail'.tr() : 'login_fail'.tr();
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
                  style: const TextStyle(fontSize: 28, color: pkColor)),
              const SizedBox(height: 8),
              Text('login_continue'.tr()),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _emailCtrl,
                hint: 'email'.tr(),
                icon: Icons.email_outlined,
                errorText: _emailErr,
                isPassword: false,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _passCtrl,
                hint: 'password'.tr(),
                icon: Icons.lock_outline,
                errorText: _passErr,
                isPassword: true,
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
                      backgroundColor: pkColor,
                    ),
                    child: _loggingIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: pkColor,
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
