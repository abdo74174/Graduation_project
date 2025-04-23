import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool _isServerOnline = true; // Assuming the server is online initially

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Method to fetch user data
  void fetchUserData() async {
    try {
      // Check server status (you can replace this with actual server check logic)
      final serverStatus = await checkServerStatus();
      setState(() {
        _isServerOnline = serverStatus;
      });

      // If server is online, fetch real data, otherwise fetch from dummy data
      if (_isServerOnline) {
        final fetchedUser =
            await USerService().fetchUserByEmail("test@gmail.com");
        if (fetchedUser != null) {
          setState(() {
            user = fetchedUser;
          });
        } else {
          print("User not found");
        }
      } else {
        // If server is offline, use dummy data
        final dummyUser =
            dummyUsers.firstWhere((u) => u.email == "test@gmail.com",
                orElse: () => User(
                      id: 1,
                      email: 'test@gmail.com',
                      phone: 1233,
                      createdAt:
                          Timestamp.fromMillisecondsSinceEpoch(1618317040000)
                              .toDate(), // Dummy timestamp
                      role: 'Doctor',
                      products: [],
                      contactUsMessages: [],
                    ));
        setState(() {
          user = dummyUser;
        });
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  // Simulate a server status check (replace with actual check logic)
  Future<bool> checkServerStatus() async {
    // Replace this with actual server check logic
    return Future.delayed(
        const Duration(seconds: 2), () => false); // Simulating server offline
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            _buildProfileField(
                                "Name", user!.name ?? "user", Icons.person),
                            const SizedBox(height: 20),
                            _buildProfileField(
                                "Email", user!.email, Icons.email),
                            const SizedBox(height: 20),
                            _buildProfileField(
                                "Password", "************", Icons.lock),
                            const SizedBox(height: 20),
                            _buildProfileField(
                                "Specialty",
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
                              builder: (context) => EditProfilePage()),
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
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
