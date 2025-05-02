import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:graduation_project/services/stateMangment/cubit/user_cubit.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String? initialKindOfWork;
  final String? initialSpecialty;

  const RoleSelectionScreen({
    super.key,
    this.initialKindOfWork,
    this.initialSpecialty,
  });

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedKindOfWork;
  String? selectedSpecialty;
  List<String> workTypes = [];
  List<String> specialties = [];
  bool _serverOnline = true;
  bool _isLoading = false;

  final ServerStatusService _statusService = ServerStatusService();

  @override
  void initState() {
    super.initState();
    // Initialize selectedKindOfWork as null to avoid invalid value
    selectedKindOfWork = null;
    selectedSpecialty = widget.initialSpecialty;
    _checkServer();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final fetchedWorkTypes = await USerService().fetchWorkTypes();
    final fetchedSpecialties = await USerService().fetchSpecialties();
    if (mounted) {
      setState(() {
        workTypes = fetchedWorkTypes;
        specialties = fetchedSpecialties;
        _isLoading = false;
        // Validate initialKindOfWork
        print('Fetched workTypes: $workTypes');
        print('Initial kindOfWork: ${widget.initialKindOfWork}');
        if (widget.initialKindOfWork != null &&
            workTypes.contains(widget.initialKindOfWork)) {
          selectedKindOfWork = widget.initialKindOfWork;
        } else if (workTypes.isNotEmpty) {
          selectedKindOfWork = workTypes[0];
        }
        // Handle specialty for Doctor
        if (selectedKindOfWork == 'Doctor' &&
            selectedSpecialty == null &&
            specialties.isNotEmpty) {
          selectedSpecialty = specialties[0];
        }
        print('Selected kindOfWork: $selectedKindOfWork');
      });
    }
  }

  Future<void> _checkServer() async {
    final online = await _statusService.checkAndUpdateServerStatus();
    if (!mounted) return;
    setState(() => _serverOnline = online);
  }

  void _onNextPressed() async {
    if (selectedKindOfWork == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.error'.tr())),
      );
      return;
    }

    if (selectedKindOfWork == 'Doctor' && selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.specialtyError'.tr())),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final userId = prefs.getString('user_id');

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.emailError'.tr())),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('roleSelectionScreen.userIdError'.tr())),
      );
      return;
    }

    if (_serverOnline) {
      final success = await USerService().updateRoleAndSpecialist(
        email: email,
        kindOfWork: selectedKindOfWork,
        medicalSpecialist:
            selectedKindOfWork == 'Doctor' ? selectedSpecialty : null,
      );

      if (!mounted) return;

      if (success) {
        context.read<UserCubit>().setUser(
              userId,
              email,
              selectedKindOfWork!,
              selectedKindOfWork == 'Doctor' ? selectedSpecialty : null,
              prefs.getBool('isAdmin') ?? false,
            );
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
      // OFFLINE MODE
      context.read<UserCubit>().setUser(
            userId,
            email,
            selectedKindOfWork!,
            selectedKindOfWork == 'Doctor' ? selectedSpecialty : null,
            prefs.getBool('isAdmin') ?? false,
          );
      await prefs.setString('kindOfWork', selectedKindOfWork!);
      if (selectedKindOfWork == 'Doctor' && selectedSpecialty != null) {
        await prefs.setString('medicalSpecialist', selectedSpecialty!);
      } else {
        await prefs.remove('medicalSpecialist');
      }
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
          'roleSelectionScreen.title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: pkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'roleSelectionScreen.selectWorkType'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.grey,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  workTypes.isEmpty
                      ? const Text('No work types available')
                      : DropdownButton<String>(
                          value: selectedKindOfWork,
                          hint: Text(
                              'roleSelectionScreen.selectWorkTypeHint'.tr()),
                          isExpanded: true,
                          onChanged: (v) {
                            setState(() {
                              selectedKindOfWork = v;
                              if (v != 'Doctor') {
                                selectedSpecialty = null;
                              } else if (specialties.isNotEmpty) {
                                selectedSpecialty = specialties[0];
                              }
                            });
                          },
                          items: workTypes
                              .map((wt) =>
                                  DropdownMenuItem(value: wt, child: Text(wt)))
                              .toList(),
                        ),
                  if (selectedKindOfWork == 'Doctor') ...[
                    const SizedBox(height: 20),
                    Text(
                      'roleSelectionScreen.selectSpecialty'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.grey,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    specialties.isEmpty
                        ? const Text('No specialties available')
                        : DropdownButton<String>(
                            value: selectedSpecialty,
                            hint: Text(
                                'roleSelectionScreen.selectSpecialtyHint'.tr()),
                            isExpanded: true,
                            onChanged: (v) =>
                                setState(() => selectedSpecialty = v),
                            items: specialties
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                          ),
                  ],
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [pkColor, Color(0xFF3E84D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'roleSelectionScreen.next'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!_serverOnline) ...[
                    const SizedBox(height: 20),
                    Text(
                      'roleSelectionScreen.offlineWarning'.tr(),
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
