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

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e\n$stackTrace');
  }

  try {
    await EasyLocalization.ensureInitialized();
    print('EasyLocalization initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing EasyLocalization: $e\n$stackTrace');
  }

  try {
    Stripe.publishableKey =
        'pk_test_51RYLblBFAxgnDhPb4pRPAmaoIiPTrfgJK4tfm5UYs8cnlZm19KYTuQplPfsXMWRkiPWTraQda979TjChHvkTfpKd00HAoPcRSm';
    print('Stripe initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Stripe: $e\n$stackTrace');
  }

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
    print('HttpOverrides set for debug mode');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedLocaleCode = prefs.getString('locale') ?? 'en';
    print(
        'SharedPreferences loaded: isLoggedIn=$isLoggedIn, locale=$savedLocaleCode');

    const supportedLocaleCodes = ['en', 'ar', 'de', 'zh'];
    final startLocale = supportedLocaleCodes.contains(savedLocaleCode)
        ? Locale(savedLocaleCode)
        : const Locale('en');
    print('Start locale set to: $startLocale');

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
            BlocProvider(create: (_) => UserCubit()..loadUserData()),
          ],
          child: Builder(
            builder: (context) {
              try {
                final notificationService = NotificationService(context);
                notificationService.initNotifications().then((_) {
                  print('NotificationService initialized successfully');
                }).catchError((e, stackTrace) {
                  print(
                      'Error initializing NotificationService: $e\n$stackTrace');
                });
                return MedicalApp(
                  isLoggedIn: isLoggedIn,
                );
              } catch (e, stackTrace) {
                print('Error setting up NotificationService: $e\n$stackTrace');
                return MedicalApp(
                  isLoggedIn: isLoggedIn,
                );
              }
            },
          ),
        ),
      ),
    );
  } catch (e, stackTrace) {
    print('Error in main setup: $e\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print('Bypassing SSL for host: $host, port: $port');
      return true;
    };
    return client;
  }
}
