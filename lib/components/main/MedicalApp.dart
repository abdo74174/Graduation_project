import 'package:flutter/material.dart';
import 'package:graduation_project/components/setting/ThemeNotifier.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/dashboard/orders_page.dart';
import 'package:graduation_project/screens/dashboard/products_page.dart';
import 'package:graduation_project/screens/dashboard/revenue_page.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/routes.dart';

class MedicalApp extends StatelessWidget {
  final bool isLoggedIn;

  const MedicalApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? HomePage() : LoginPage(),
      onGenerateRoute: AppRoutes.generateRoute,
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
