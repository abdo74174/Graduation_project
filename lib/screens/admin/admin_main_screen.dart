import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/adding_pr_cat_sub.dart/addCatandSub.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/components/dashboard/navigation_card.dart';

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Admin Dashboard',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        useMaterial3: true,
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 cards per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            NavigationCard(
              icon: Icons.analytics,
              title: 'Analysis Dashboard',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              },
            ),
            NavigationCard(
              icon: Icons.home,
              title: 'Homepage',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            NavigationCard(
              icon: Icons.category,
              title: 'Add Category & Sub Category',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddCategorySubCategoryPage()),
                );
              },
            ),
            NavigationCard(
              icon: Icons.admin_panel_settings,
              title: 'Assign Admin',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomersPage()),
                );
              },
            ),
            NavigationCard(
              icon: Icons.admin_panel_settings,
              title: 'Chat List ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
