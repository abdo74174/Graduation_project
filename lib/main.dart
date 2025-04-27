import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/components/setting/ThemeNotifier.dart';
import 'package:graduation_project/firebase_options.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/dashboard/orders_page.dart';
import 'package:graduation_project/screens/dashboard/products_page.dart';
import 'package:graduation_project/screens/dashboard/revenue_page.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/screens/splash_screen.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:graduation_project/services/notifications/notification_service.dart';
import 'package:graduation_project/background/server_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize background services
  await AndroidAlarmManager.initialize();
  await NotificationService.init();

  // Ensure localization is initialized
  await EasyLocalization.ensureInitialized();

  // Override HTTP client for debugging (for custom SSL certificates)
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Schedule a periodic task for server check
  await AndroidAlarmManager.periodic(
    const Duration(seconds: 20),
    123,
    hourlyServerCheck,
    wakeup: true,
    exact: true,
  );

  // Load SharedPreferences to check if the user is logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final savedLocaleCode = prefs.getString('locale') ?? 'en';

  // Run the app with EasyLocalization and BlocProvider
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLocaleCode),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          BlocProvider(create: (_) => UserCubit()),
        ],
        child: MedicalApp(isLoggedIn: isLoggedIn),
      ),
    ),
  );
}

// Custom HTTP client override for SSL certificates (only for debugging)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

class MedicalApp extends StatelessWidget {
  final bool isLoggedIn;

  const MedicalApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Graduation Project',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/products': (context) => ProductsPage(),
        '/orders': (context) => OrdersPage(),
        '/revenue': (context) => RevenuePage(),
        '/customers': (context) => CustomersPage(),
      },
    );
  }
}
