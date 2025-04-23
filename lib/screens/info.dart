import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';

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
        const SnackBar(content: Text('Please select both role and specialty')),
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
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } else {
      // OFFLINE MODE: Just navigate forward
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server offline — continuing offline')),
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
        title: const Text('How Would You Like To Use the App?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select your Role',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 2, color: Colors.grey, offset: Offset(1, 1))
                  ],
                )),
            DropdownButton<String>(
              value: selectedRole,
              hint: const Text('Select Role'),
              onChanged: (v) => setState(() => selectedRole = v),
              items: roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('What Is Your Medical Specialty?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 2, color: Colors.grey, offset: Offset(1, 1))
                  ],
                )),
            DropdownButton<String>(
              value: selectedSpecialty,
              hint: const Text('Select Specialty'),
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
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
