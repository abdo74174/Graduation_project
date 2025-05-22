import 'package:flutter/material.dart';
import 'package:graduation_project/components/setting/ThemeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void toggleLanguage(BuildContext context) {
    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'en') {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
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
            trailing: ElevatedButton(
              onPressed: () => toggleLanguage(context),
              child: Text(
                context.locale.languageCode == 'en' ? 'العربية' : 'English',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
