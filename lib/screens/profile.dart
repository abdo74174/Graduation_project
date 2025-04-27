import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  bool _isServerOnline = true; // Assuming the server is online initially
  bool _isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
    fetchUserData();
    checkServerStatus();
  }

  /// Method to fetch user data
  void fetchUserData() async {
    try {
      // Get email from SharedPreferences
      final email = await UserService().getEmail();

      if (email == null || email.isEmpty) {
        print("No email found in SharedPreferences!");
        return;
      }

      // Fetch the user data by email
      final fetchedUser = await USerService().fetchUserByEmail(email);

      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser; // Update the user data
          _isLoading = false; // Stop the loading state
        });
      } else {
        print("User not found");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Simulate a server status check (replace with actual check logic)
  Future<void> checkServerStatus() async {
    bool isServerOnline =
        await ServerStatusService().checkAndUpdateServerStatus();
    setState(() {
      _isServerOnline = isServerOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isServerOnline
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/images/various-medical-equipments-blue-backdrop 1.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: -80,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 75,
                                backgroundImage:
                                    AssetImage("assets/images/doctor 1.png"),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildProfileField("name".tr(),
                                    user!.name ?? "user", Icons.person),
                                const SizedBox(height: 20),
                                _buildProfileField(
                                    "email".tr(), user!.email, Icons.email),
                                const SizedBox(height: 20),
                                _buildProfileField("password".tr(),
                                    "************", Icons.lock),
                                const SizedBox(height: 20),
                                _buildProfileField(
                                    "specialty".tr(),
                                    user!.medicalSpecialist ?? "Unknown",
                                    Icons.medical_services),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  user: user!,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'edit_profile'.tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 50, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(
                        "server_offline".tr(),
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Profile field widget
  Widget _buildProfileField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
