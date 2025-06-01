// ignore_for_file: use_build_context_synchronously
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
  final String initialKindOfWork;
  final String? initialSpecialty;

  const RoleSelectionScreen({
    super.key,
    required this.initialKindOfWork,
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
    selectedKindOfWork = widget.initialKindOfWork;
    selectedSpecialty = widget.initialSpecialty;
    _checkServer();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final fetchedWorkTypes = await USerService().fetchWorkTypes();
      final fetchedSpecialties = await USerService().fetchSpecialties();
      if (mounted) {
        setState(() {
          workTypes = fetchedWorkTypes;
          specialties = fetchedSpecialties;
          if (!workTypes.contains(selectedKindOfWork)) {
            selectedKindOfWork = workTypes.isNotEmpty ? workTypes[0] : null;
          }
          if (selectedKindOfWork == 'Doctor' &&
              selectedSpecialty == null &&
              specialties.isNotEmpty) {
            selectedSpecialty = specialties[0];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e'.tr())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkServer() async {
    final online = await _statusService.checkAndUpdateServerStatus();
    if (mounted) {
      setState(() => _serverOnline = online);
    }
  }

  void _onNextPressed() async {
    if (selectedKindOfWork == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('roleSelectionScreen.error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedKindOfWork == 'Doctor' && selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('roleSelectionScreen.specialtyError'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final userId = prefs.getString('user_id');

    if (email.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('roleSelectionScreen.emailError'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('roleSelectionScreen.userIdError'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_serverOnline) {
      try {
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
            SnackBar(
              content: Text('roleSelectionScreen.updateError'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: $e'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
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
        SnackBar(
          content: Text('roleSelectionScreen.offlineError'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black, const Color(0xFF1A1A1A)]
                : [pkColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: pkColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/AppIcon.png', // Consistent with LoginPage
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'roleSelectionScreen.title'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'roleSelectionScreen.selectWorkType'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      workTypes.isEmpty
                          ? Text(
                              'No work types available'.tr(),
                              style: const TextStyle(color: Colors.red),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                              itemCount: workTypes.length,
                              itemBuilder: (context, index) {
                                final workType = workTypes[index];
                                final isSelected =
                                    selectedKindOfWork == workType;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedKindOfWork = workType;
                                      if (workType != 'Doctor') {
                                        selectedSpecialty = null;
                                      } else if (specialties.isNotEmpty) {
                                        selectedSpecialty = specialties[0];
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? pkColor
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          workType == 'Doctor'
                                              ? Icons.medical_services
                                              : Icons.work,
                                          size: 40,
                                          color: isSelected
                                              ? pkColor
                                              : Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          workType,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      if (selectedKindOfWork == 'Doctor') ...[
                        const SizedBox(height: 30),
                        Text(
                          'roleSelectionScreen.selectSpecialty'.tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        specialties.isEmpty
                            ? Text(
                                'No specialties available'.tr(),
                                style: const TextStyle(color: Colors.red),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: specialties.map((specialty) {
                                  final isSelected =
                                      selectedSpecialty == specialty;
                                  return ChoiceChip(
                                    label: Text(specialty),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() =>
                                            selectedSpecialty = specialty);
                                      }
                                    },
                                    selectedColor: pkColor,
                                    backgroundColor: isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pkColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'roleSelectionScreen.next'.tr(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (!_serverOnline) ...[
                        const SizedBox(height: 16),
                        Text(
                          'roleSelectionScreen.offlineWarning'.tr(),
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
