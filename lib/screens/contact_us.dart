import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'contact_us'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/image3.png',
                  width: 250,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.person),
                  hintText: 'full_name'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'email'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'message'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3E84D7),
                        Color(0xFF407BD4),
                        Color(0xFF4A50C6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: Text('submit'.tr(),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'contact_details'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2)
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'contact_message'.tr(),
                style: TextStyle(
                  color: Color(0xFF555720),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ContactDetailRow(
                  icon: Icons.location_on,
                  label: 'address'.tr(),
                  value: 'location'.tr()),
              ContactDetailRow(
                  icon: Icons.phone,
                  label: 'phone'.tr(),
                  value: 'phone_number'.tr()),
              ContactDetailRow(
                  icon: Icons.email,
                  label: 'email_contact'.tr(),
                  value: 'email_value'.tr()),
              ContactDetailRow(
                  icon: Icons.access_time,
                  label: 'availability'.tr(),
                  value: 'working_hours'.tr()),
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'social_media'.tr(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  SocialMediaIcon(imagePath: 'assets/images/facebook.jpg'),
                  const SizedBox(width: 10),
                  SocialMediaIcon(imagePath: 'assets/images/twitter.jpg'),
                  const SizedBox(width: 10),
                  SocialMediaIcon(imagePath: 'assets/images/linkedin.jpg'),
                  const SizedBox(width: 10),
                  SocialMediaIcon(imagePath: 'assets/images/whatsapp.jpg'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ContactDetailRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class SocialMediaIcon extends StatelessWidget {
  final String imagePath;

  const SocialMediaIcon({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: 30,
      height: 30,
    );
  }
}
