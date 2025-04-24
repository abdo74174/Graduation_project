import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void toggleLanguage(BuildContext context) async {
  final currentLocale = context.locale;
  final newLocale = currentLocale.languageCode == 'en'
      ? const Locale('ar')
      : const Locale('en');

  // Change app locale
  await context.setLocale(newLocale);

  // Save to SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('locale', newLocale.languageCode);
}
