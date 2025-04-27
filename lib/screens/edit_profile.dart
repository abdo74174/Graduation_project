import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import the easy_localization package
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/profile.dart';
import 'package:graduation_project/services/USer/sign.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final UserModel user;

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _obscurePassword = true;
  String? _selectedCategory;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _categories = [
    "Cardiology",
    "Neurology",
    "Orthopedics",
    "General"
  ];
  // UserModel? _currentUser;
  // This function fetches user data from the server
  // void fetchUserData() async {
  //   try {
  //     final fetchedUser =
  //         await USerService().fetchUserByEmail(widget.user.email);
  //     if (fetchedUser != null) {
  //       setState(() {
  //         _currentUser = fetchedUser;
  //         _nameController.text = _currentUser?.name ?? "user";
  //         _emailController.text = _currentUser?.email ?? "user@gmail.com";
  //         _passwordController.text =
  //             _currentUser?.password ?? "423m4po523h5o25oi52io[5]";

  //         // Ensure the value exists before assigning it
  //         _selectedCategory =
  //             _categories.contains(_currentUser?.medicalSpecialist)
  //                 ? _currentUser?.medicalSpecialist
  //                 : null;
  //       });
  //     } else {
  //       print("User not found");
  //     }
  //   } catch (e) {
  //     print("Error fetching user: $e");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // Populate the text fields with the user data passed from ProfilePage
    _nameController.text = widget.user.name ?? ''; // Set name
    _emailController.text = widget.user.email ?? ''; // Set email
    _passwordController.text = widget.user.password ?? ''; // Set password
    _selectedCategory = _categories.contains(widget.user.medicalSpecialist)
        ? widget.user.medicalSpecialist
        : null; // Set category if it exists
    // fetchUserData(); // Fetch user data when the page is loaded
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
        title: Text(
          "edit_profile".tr(), // Use .tr() to get the localized string
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: const AssetImage("assets/images/doctor 1.png"),
            ),
            const SizedBox(height: 20),

            _buildLabel("user_name".tr()), // Localize the label text
            _buildTextField(_nameController, Icons.person),

            _buildLabel("email".tr()), // Localize the label text
            _buildTextField(_emailController, Icons.email),

            const SizedBox(height: 15),
            _buildLabel("category".tr()), // Localize the label text

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon:
                    const Icon(Icons.medical_services, color: Colors.grey),
              ),
              value: _selectedCategory,
              hint: Text("select_category".tr()), // Localize the hint text
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
                      medicalSpecialist: _selectedCategory ?? "",
                      profileImage: null,
                    );

                    if (!mounted) return;

                    showSnackbar(
                        context,
                        "updated_successfully"
                            .tr()); // Localize success message
                  } catch (e) {
                    if (!mounted) return;

                    showSnackbar(context,
                        "update_failed".tr()); // Localize failure message
                    print("❌ Caught Error: $e");
                  }
                },
                child: Text(
                  "save_changes".tr(), // Localize the button text
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
