import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;
  String? selectedSpecialty;

  final List<String> roles = ['Doctor', 'Merchant', 'MedicalTrader'];
  bool _serverOnline = true;

  final ServerStatusService _statusService = ServerStatusService();

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    final online = await _statusService.checkAndUpdateServerStatus();
    if (!mounted) return;
    setState(() => _serverOnline = online);
  }

  void _onNextPressed() async {
    if (selectedRole == null || selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.error'.tr())),
      );
      return;
    }

    if (_serverOnline) {
      final success = await USerService().updateRoleAndSpecialist(
        email: 'test@gmail.com',
        role: selectedRole,
        medicalSpecialist: selectedSpecialty,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('roleSelectionScreen.updateError'.tr())),
        );
      }
    } else {
      // OFFLINE MODE: Just navigate forward
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.offlineError'.tr())),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'roleSelectionScreen.title'.tr(), // Using .tr() for translation
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'roleSelectionScreen.selectRole'
                  .tr(), // Translated text for 'Select your Role'
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      blurRadius: 2, color: Colors.grey, offset: Offset(1, 1))
                ],
              ),
            ),
            DropdownButton<String>(
              value: selectedRole,
              hint: Text('roleSelectionScreen.selectRoleHint'
                  .tr()), // Translated text for hint
              onChanged: (v) => setState(() => selectedRole = v),
              items: roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'roleSelectionScreen.selectSpecialty'
                  .tr(), // Translated text for 'What Is Your Medical Specialty?'
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                      blurRadius: 2, color: Colors.grey, offset: Offset(1, 1))
                ],
              ),
            ),
            DropdownButton<String>(
              value: selectedSpecialty,
              hint: Text('roleSelectionScreen.selectSpecialtyHint'
                  .tr()), // Translated text for hint
              onChanged: (v) => setState(() => selectedSpecialty = v),
              items: specialties
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[900]!,
                    Colors.blue[500]!,
                    Colors.blue[300]!
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _onNextPressed,
                child: Text(
                  'roleSelectionScreen.next'.tr(), // Translated text for 'Next'
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
