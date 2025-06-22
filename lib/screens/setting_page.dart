import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/setting/ThemeNotifier.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // List of available languages with display names
  static const List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'zh', 'name': '中文'},
  ];

  Future<void> setLanguage(BuildContext context, String languageCode) async {
    final newLocale = Locale(languageCode);
    await context.setLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pkColor,
        title: Text(
          'settings.title'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            value: themeNotifier.isDarkMode,
            onChanged: (value) => themeNotifier.toggleTheme(value),
          ),
          ListTile(
            title: Text('settings.language'.tr()),
            trailing: DropdownButton<String>(
              value: currentLocale,
              items: languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setLanguage(context, newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
