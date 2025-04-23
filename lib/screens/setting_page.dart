import 'package:flutter/material.dart';
import 'package:graduation_project/components/setting/ThemeNotifier.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeNotifier.isDarkMode,
            onChanged: (value) => themeNotifier.toggleTheme(value),
          ),
        ],
      ),
    );
  }
}
