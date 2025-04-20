import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/profile.dart';
import 'package:graduation_project/services/sign.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _obscurePassword = true;
  String? _selectedCategory;
  User? user;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _categories = [
    "Cardiology",
    "Neurology",
    "Orthopedics",
    "General"
  ];
  void fetchUserData() async {
    try {
      final fetchedUser = await USerService().fetchUserByEmail("m@gmail.com");
      if (fetchedUser != null) {
        setState(() {
          user = fetchedUser;
          _nameController.text = user?.name ?? "";
          _emailController.text = user?.email ?? "";
          _passwordController.text = user?.password ?? "";

          // ✅ تأكد إن القيمة موجودة قبل تعيينها
          _selectedCategory = _categories.contains(user?.medicalSpecialist)
              ? user?.medicalSpecialist
              : null;
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),

                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        const AssetImage("assets/images/doctor 1.png"),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("User Name"),
                  _buildTextField(_nameController, Icons.person),

                  _buildLabel("Email"),
                  _buildTextField(_emailController, Icons.email),

                  // _buildLabel("Password"),
                  // TextField(
                  //   controller: _passwordController,
                  //   obscureText: _obscurePassword,
                  //   decoration: InputDecoration(
                  //     suffixIcon: IconButton(
                  //       icon: Icon(
                  //         _obscurePassword
                  //             ? Icons.visibility_off
                  //             : Icons.visibility,
                  //         color: Colors.grey,
                  //       ),
                  //       onPressed: () {
                  //         setState(() {
                  //           _obscurePassword = !_obscurePassword;
                  //         });
                  //       },
                  //     ),
                  //     border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10)),
                  //   ),
                  // ),

                  const SizedBox(height: 15),
                  _buildLabel("Category"),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.medical_services,
                          color: Colors.grey),
                    ),
                    value: _selectedCategory,
                    hint: const Text("Select your Category"),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 25),

                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.indigo],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        try {
                          await USerService().updateUserProfile(
                            email: _emailController.text,
                            name: _nameController.text,
                            // password: _passwordController.text,
                            medicalSpecialist: _selectedCategory ?? "",
                            profileImage: null,
                          );

                          if (!mounted) return;

                          showSnackbar(context, "Updated Successfully");
                        } catch (e) {
                          if (!mounted) return;

                          showSnackbar(context, "Update Failed");
                          print("❌ Caught Error: $e");
                        }
                      },
                      child: const Text(
                        "Save changes",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
