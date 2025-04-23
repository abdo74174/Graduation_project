import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/screens/login_page.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/screens/add_product.dart';
import 'package:graduation_project/screens/contact_us.dart';
import 'package:graduation_project/screens/profile.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  Future<void> _logout() async {
    // Get the instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove authentication data (e.g., token, user info)
    await prefs.remove(
        'userToken'); // Remove the token or any key that stores user data
    await prefs.remove('userName'); // Remove the username if stored

    // Navigate to the Login screen after logout
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Make sure LoginScreen is the correct import
      (Route<dynamic> route) => false, // This removes all routes in the stack
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
                  "userName", // You might want to dynamically set the username here
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.edit),
            title: const Text('Profile'),
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
            title: const Text('Add New Product'),
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
            title: const Text('Notification'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.phoneAlt),
            title: const Text('Contact Us'),
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
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.signOutAlt),
            title: const Text('Logout'),
            onTap: () {
              _logout(); // Call the logout function
            },
          ),
        ],
      ),
    );
  }
}
