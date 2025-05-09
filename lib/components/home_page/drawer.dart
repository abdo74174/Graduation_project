// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/screens/admin/admin_main_screen.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:graduation_project/screens/adding_pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/screens/contact_us.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../screens/adding_pr_cat_sub.dart/addCatandSub.dart';

class DrawerHome extends StatefulWidget {
  const DrawerHome({super.key});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userToken');
    await prefs.remove('userName');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
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
                    Text(
                      state.email ?? 'Guest',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.edit),
                title: Text('Profile'.tr()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.edit),
                title: Text('Add New Product'.tr()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.phoneAlt),
                title: Text('Contact Us'.tr()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.cog),
                title: Text('Settings'.tr()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              if (state.isAdmin) // Conditionally show Admin tile
                ListTile(
                  leading: const Icon(FontAwesomeIcons.userLarge),
                  title: Text('Admin'.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardApp(),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.signOutAlt),
                title: Text('Logout'.tr()),
                onTap: () {
                  context.read<UserCubit>().clearUser();
                  _logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
