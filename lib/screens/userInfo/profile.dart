import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/screens/userInfo/edit_profile.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  bool _isServerOnline = true;
  bool _isLoading = true;
  bool _isImageLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    checkServerStatus();
  }

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkServerStatus() async {
    bool isServerOnline =
        await ServerStatusService().checkAndUpdateServerStatus();

    if (!mounted) return;
    setState(() {
      _isServerOnline = isServerOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isServerOnline
              ? Center(
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
                )
              : user == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            "No user data found!".tr(),
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    )
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
                              Positioned(
                                bottom: -60,
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    child: user?.profileImage != null &&
                                            user!.profileImage!.isNotEmpty
                                        ? Image.network(
                                            user!.profileImage!,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return SizedBox(
                                                width: 150,
                                                height: 150,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.person,
                                                  size: 80, color: Colors.grey);
                                            },
                                          )
                                        : const CircleAvatar(
                                            radius: 75,
                                            backgroundImage: AssetImage(
                                                "assets/images/doctor 1.png"),
                                          ),
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
                                    buildProfileTextField(
                                        "profile.user_name".tr(),
                                        user?.name ?? "Unknown",
                                        Icons.person),
                                    const SizedBox(height: 20),
                                    buildProfileTextField(
                                        "auth.email".tr(),
                                        user?.email ?? "Unknown".tr(),
                                        Icons.email),
                                    const SizedBox(height: 20),
                                    buildProfileTextField(
                                        "specialty".tr(),
                                        user?.medicalSpecialist ??
                                            "Unknown".tr(),
                                        Icons.medical_services),
                                    const SizedBox(height: 20),
                                    buildProfileTextField(
                                        "profile.phone".tr(),
                                        user?.phone ?? "Unknown".tr(),
                                        Icons.phone),
                                    const SizedBox(height: 20),
                                    buildProfileTextField(
                                        "profile.address".tr(),
                                        user?.address ?? "Unknown".tr(),
                                        Icons.home),
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
                                // Replace this navigation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilePage(user: user!),
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
                                'profile.edit_profile'.tr(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget buildProfileTextField(String label, String value, IconData icon) {
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
