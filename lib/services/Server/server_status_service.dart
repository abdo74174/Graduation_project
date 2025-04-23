import 'package:shared_preferences/shared_preferences.dart';
import 'check_server_online.dart';

class ServerStatusService {
  static const _key = 'serverOnline';

  Future<bool> getLastKnownStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  Future<void> saveStatus(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isOnline);
  }

  Future<bool> checkAndUpdateServerStatus() async {
    final isOnline = await CheckServerOnline().checkServer();
    await saveStatus(isOnline);
    return isOnline;
  }
}
