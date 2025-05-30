// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/screens/admin/admin_main_screen.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:graduation_project/screens/adding_pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/screens/contact_us.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/services/User/sign.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/screens/favourite_page.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/components/home_page/drawer_items.dart';

import '../../screens/adding_pr_cat_sub.dart/addCatandSub.dart';

enum DrawerType { main, admin, seller, buyer }

class DrawerHome extends StatefulWidget {
  final DrawerType drawerType;

  const DrawerHome({super.key, this.drawerType = DrawerType.main});

  @override
  State<DrawerHome> createState() => _DrawerHomeState();
}

class _DrawerHomeState extends State<DrawerHome> {
  UserModel? user;

  Future<void> fetchUserData() async {
    try {
      final email = await UserServicee().getEmail();
      if (email == null || email.isEmpty) {
        print("No email found in SharedPreferences!");
        return;
      }
      final fetchedUser = await USerService().fetchUserByEmail(email);
      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
    } finally {
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userToken');
    await prefs.remove('userName');

    if (!mounted) return;

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
          child: Column(
            children: [
              // Drawer Header
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String?>(
                      future: UserServicee().getEmail(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        }
                        return const Text(
                          'Guest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Drawer Items
              Expanded(
                child: DrawerItems(
                  drawerType: widget.drawerType,
                  isAdmin: state.isAdmin,
                  onLogout: () {
                    context.read<UserCubit>().clearUser();
                    _logout();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
