import 'package:shared_preferences/shared_preferences.dart';

class UserServicee {
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }
}
