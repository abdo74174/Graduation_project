import 'package:flutter/material.dart';
import 'edit_profile.dart'; // Import the EditProfilePage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stacked Images
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allows overflow
              children: [
                // Background Image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/images/various-medical-equipments-blue-backdrop 1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Circular Profile Image
                const Positioned(
                  bottom: -80,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: AssetImage("assets/images/doctor 1.png"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // User Details
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
                      _buildProfileField("Name", "Magdy Yaqoub", Icons.person),
                      const SizedBox(height: 20),
                      _buildProfileField(
                          "Email", "MagdyYaqoub@gmail.com", Icons.email),
                      const SizedBox(height: 20),
                      _buildProfileField(
                          "Password", "************", Icons.lock),
                      const SizedBox(height: 20),
                      _buildProfileField(
                          "Specialty", "Cardiologia", Icons.medical_services),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Custom Widget to Reduce Repetition
  Widget _buildProfileField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      enabled: false, // Disable editing
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
