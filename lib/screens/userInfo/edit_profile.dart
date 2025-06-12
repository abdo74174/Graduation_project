import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? _selectedSpecialist;
  File? _profileImage;
  bool _hasExistingImage = false;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<String> _specialists = [];
  bool _isLoadingSpecialties = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchSpecialties(); // Call this method directly
  }

  void _initializeData() {
    _nameController.text = widget.user.name ?? '';
    _emailController.text = widget.user.email;
    _passwordController.text = widget.user.password ?? '';
    _phoneController.text = widget.user.phone ?? '';
    _addressController.text = widget.user.address ?? '';
    _hasExistingImage = widget.user.profileImage?.isNotEmpty ?? false;
  }

  Future<void> _fetchSpecialties() async {
    setState(() => _isLoadingSpecialties = true);
    try {
      final fetchedSpecialties = await USerService().fetchSpecialties();
      if (mounted) {
        setState(() {
          _specialists = fetchedSpecialties;
          // Set the selected specialist only after we have the list
          _selectedSpecialist =
              _specialists.contains(widget.user.medicalSpecialist)
                  ? widget.user.medicalSpecialist
                  : null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load specialties: $e'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSpecialties = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ),
        ),
        title: Text(
          "edit_profile".tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image Section
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(_profileImage!, fit: BoxFit.cover)
                          : _hasExistingImage
                              ? CachedNetworkImage(
                                  imageUrl: widget.user.profileImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Image.asset(
                                  "assets/images/doctor 1.png",
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "profile.user_name".tr(),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "auth.email".tr(),
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Category Dropdown
            _isLoadingSpecialties
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: _selectedSpecialist,
                    decoration: InputDecoration(
                      labelText: "product.specialist".tr(),
                      prefixIcon: const Icon(Icons.medical_services),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _specialists.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpecialist = newValue;
                      });
                    },
                  ),
            const SizedBox(height: 20),
            // Phone Field
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: "profile.phone".tr(),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "profile.address".tr(),
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveProfile,
                child: Text(
                  "profile.save_changes".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _hasExistingImage = false;
        });
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  Future<void> _saveProfile() async {
    try {
      String? base64Image;
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      await USerService().updateUserProfile(
        email: _emailController.text,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        medicalSpecialist: _selectedSpecialist ?? "",
        profileImage: base64Image,
      );

      if (!mounted) return;
      showSnackbar(context, "profile.updated_successfully".tr());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, "profile.update_failed".tr());
      debugPrint("Profile update error: $e".tr());
    }
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
