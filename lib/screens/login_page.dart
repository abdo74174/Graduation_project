// lib/screens/login_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:graduation_project/components/sign/cutomize_inputfield.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/forget_password.dart';
import 'package:graduation_project/screens/register.dart';
import 'package:graduation_project/services/Server/check_server_online.dart';
import 'package:graduation_project/services/USer/sign.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _emailErr, _passErr;
  bool _serverOnline = true, _loggingIn = false, _allowOfflineLogin = false;
  int _count = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadServerFlag().then((_) => _checkServer());
  }

  Future<void> _loadServerFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverOnline = prefs.getBool('serverOnline') ?? true;
    });
  }

  Future<void> _saveServerFlag(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('serverOnline', on);
  }

  Future<void> _checkServer() async {
    final ok = await CheckServerOnline().checkServer();
    await _saveServerFlag(ok);
    if (!mounted) return;
    setState(() {
      _serverOnline = ok;
      _allowOfflineLogin = ok; // only allow login when online initially
    });
    if (!ok) _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _count = 10;
    setState(() {
      _allowOfflineLogin = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count == 0) {
        t.cancel();
        setState(() {
          _allowOfflineLogin = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Offline mode enabled — you may now log in')),
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
        _emailErr = 'Email cannot be empty';
      else if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(e))
        _emailErr = 'Invalid email';
      if (p.isEmpty) _passErr = 'Password cannot be empty';
    });
  }

  Future<void> _login() async {
    _validate();
    if (_emailErr != null || _passErr != null) return;

    setState(() => _loggingIn = true);

    // If still online, re-check health
    if (!_allowOfflineLogin) {
      final ok = await CheckServerOnline().checkServer();
      await _saveServerFlag(ok);
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _serverOnline = false;
          _loggingIn = false;
        });
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Server is offline, starting offline countdown')),
        );
        return;
      }
    }

    // Proceed with login even if offline mode
    final success = await USerService().login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );
    setState(() => _loggingIn = false);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final tok = prefs.getString('token') ?? '';
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', tok);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed: wrong credentials')),
      );
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
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Image.asset('assets/images/laboratory.png',
                  width: 160, height: 160),
              const SizedBox(height: 24),
              const Text('Login',
                  style: TextStyle(fontSize: 28, color: pkColor)),
              const SizedBox(height: 8),
              const Text('Login to continue using the app'),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _emailCtrl,
                hint: 'Email',
                icon: Icons.email_outlined,
                errorText: _emailErr,
                isPassword: false,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _passCtrl,
                hint: 'Password',
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
                  child: const Text('Forgot password?'),
                ),
              ),
              if (!_serverOnline) ...[
                const SizedBox(height: 16),
                const Text('Server offline, retrying in:',
                    style: TextStyle(color: Colors.red)),
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
              ],
              const SizedBox(height: 24),
              if (_serverOnline || _allowOfflineLogin)
                SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loggingIn ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkColor, // Sets the background color
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
                                  ? 'Login (Offline)'
                                  : 'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                    )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterForm()),
                    ),
                    child: const Text('Register'),
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
