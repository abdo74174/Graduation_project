import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/contact_us.dart/contact_us.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final UserServicee _userService = UserServicee();
  final ContactUsService _apiService = ContactUsService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _problemTypeController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedProblemType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? email;
  Future<void> _loadUserData() async {
    email = await _userService.getEmail();
    setState(() {
      _emailController.text = email ?? '';
    });
  }

  Future<void> _submitMessage() async {
    if (_selectedProblemType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_select_problem_type'.tr())),
      );
      return;
    }

    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_enter_message'.tr())),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.submitContactUsMessage(
        _selectedProblemType!, _messageController.text, email);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('message_submitted'.tr())),
      );
      _messageController.clear();
      _problemTypeController.clear();
      setState(() {
        _selectedProblemType = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_submit'.tr())),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
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
              Text(
                'report_problem'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                readOnly: true,
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
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedProblemType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.warning),
                  hintText: 'select_problem_type'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'account_blocked',
                    child: Text('account_blocked'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'login_issues',
                    child: Text('login_issues'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'payment_problem',
                    child: Text('payment_problem'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'app_bugs',
                    child: Text('app_bugs'.tr()),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('other_issue'.tr()),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedProblemType = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: 'describe_your_problem'.tr(),
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
                      // gradient: const LinearGradient(
                      //   colors: [
                      //     Color(0xFF3E84D7),
                      //     Color(0xFF407BD4),
                      //     Color(0xFF4A50C6)
                      //   ],
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      // ),
                      color: pkColor),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('submit'.tr(),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text('urgent_help'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    )),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialMediaButton(
                    imagePath: 'assets/images/whatsapp.jpg',
                    onTap: () => _launchUrl('https://wa.me/201125411335'),
                    label: 'WhatsApp',
                  ),
                  SocialMediaButton(
                    imagePath: 'assets/images/phone.png',
                    onTap: () => _launchUrl('tel:+201125411335'),
                    label: 'call'.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                'contact_details'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ContactDetailRow(
                  icon: Icons.location_on,
                  label: 'address'.tr(),
                  value: '123 Main St, City, Country',
                  onTap: () => _launchUrl(
                      'https://maps.google.com/?q=123+Main+St,+City,+Country')),
              ContactDetailRow(
                  icon: Icons.phone,
                  label: 'phone'.tr(),
                  value: '+1234567890',
                  onTap: () => _launchUrl('tel:+1234567890')),
              ContactDetailRow(
                  icon: Icons.email,
                  label: 'email_contact'.tr(),
                  value: 'support@example.com',
                  onTap: () => _launchUrl('mailto:support@example.com')),
              ContactDetailRow(
                  icon: Icons.access_time,
                  label: 'availability'.tr(),
                  value: 'Mon-Fri: 9AM-5PM'),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Center(
                child: Text('follow_us'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialMediaButton(
                    imagePath: 'assets/images/facebook.jpg',
                    onTap: () => _launchUrl('https://facebook.com/yourpage'),
                  ),
                  const SizedBox(width: 15),
                  SocialMediaButton(
                    imagePath: 'assets/images/twitter.jpg',
                    onTap: () => _launchUrl('https://twitter.com/yourhandle'),
                  ),
                  const SizedBox(width: 15),
                  SocialMediaButton(
                    imagePath: 'assets/images/linkedin.jpg',
                    onTap: () => _launchUrl('https://linkedin.com/yourcompany'),
                  ),
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
  final VoidCallback? onTap;

  const ContactDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text("$label:",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            Expanded(child: Text(value)),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class SocialMediaButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String? label;

  const SocialMediaButton({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.asset(
              imagePath,
              width: 40,
              height: 40,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 5),
          Text(label!, style: const TextStyle(fontSize: 12)),
        ],
      ],
    );
  }
}
