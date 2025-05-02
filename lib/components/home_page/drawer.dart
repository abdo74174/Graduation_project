import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/screens/add_product.dart';
import 'package:graduation_project/screens/contact_us.dart';
import 'package:graduation_project/screens/profile.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../screens/addCatandSub.dart'; // Add this import for localization

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove authentication data
    await prefs.remove('isLoggedIn');
    await prefs.remove('userToken');
    await prefs.remove('userName');

    // Navigate to the Login screen after logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.user,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  "userName", // This should dynamically display the logged-in user's name
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.edit),
            title: Text('Profile'.tr()), // Localize here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ProfilePage();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.edit),
            title: Text('Add New Product'.tr()), // Localize here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AddProductScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.solidBell),
            title: Text('Notification'.tr()), // Localize here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChatListPage();
                  },
                ),
              );
            },
          ),ListTile(
            leading: const Icon(FontAwesomeIcons.solidBell),
            title: Text('ADD cate and Sub'.tr()), // Localize here
            onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddCategorySubCategoryPage()),

              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.phoneAlt),
            title: Text('Contact Us'.tr()), // Localize here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ContactUsPage();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.cog),
            title: Text('Settings'.tr()), // Localize here
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.signOutAlt),
            title: Text('Logout'.tr()), // Localize here
            onTap: () {
              clearEmail();

              _logout();
            },
          ),
        ],
      ),
    );
  }
}

Future<void> clearEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_email'); // Remove the email key
}
