import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graduation_project/components/main/MedicalApp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'components/setting/ThemeNotifier.dart';
import 'services/stateMangment/cubit/user_cubit.dart';
import 'services/notifications/notification_service.dart';
import 'background/server_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await EasyLocalization.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51RYLblBFAxgnDhPb4pRPAmaoIiPTrfgJK4tfm5UYs8cnlZm19KYTuQplPfsXMWRkiPWTraQda979TjChHvkTfpKd00HAoPcRSm';
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final savedLocaleCode = prefs.getString('locale') ?? 'en';

  // Validate saved locale against supported locales
  const supportedLocaleCodes = ['en', 'ar', 'de', 'zh'];
  final startLocale = supportedLocaleCodes.contains(savedLocaleCode)
      ? Locale(savedLocaleCode)
      : const Locale('en'); // Default to English if saved locale is invalid

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('de'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          BlocProvider(create: (_) => UserCubit()),
        ],
        child: Builder(
          builder: (context) {
            final notificationService = NotificationService(context);
            notificationService.initNotifications();
            return MedicalApp(isLoggedIn: isLoggedIn);
          },
        ),
      ),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
