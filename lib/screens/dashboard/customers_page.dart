import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/User/assign_role.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final AdminApiService _apiService = AdminApiService();
  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;
  bool isRetrying = false;
  String? _userOfAppIdString;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchUsers();
  }

  Future<void> _loadUserId() async {
    _userOfAppIdString = await UserServicee().getUserId();
  }

  Future<void> _fetchUsers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await _apiService.getUsers();
      if (mounted) {
        setState(() {
          users = response.map((json) => UserModel.fromJson(json)).toList();
          isLoading = false;
          isRetrying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAction(String action, UserModel user) async {
    if (user.id == int.parse(_userOfAppIdString!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot perform actions on your own account.'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      switch (action) {
        case 'Assign Admin':
          await _apiService.addAdmin(user.id);
          break;
        case 'Remove Admin':
          await _apiService.deleteAdmin(user.id);
          break;
        case 'Block User':
          await _apiService.blockUser(user.id);
          break;
        case 'Unblock User':
          await _apiService.unblockUser(user.id);
          break;
        case 'Deactivate User':
          await _apiService.deactivateUser(user.id);
          break;
        case 'Activate User':
          await _apiService.activateUser(user.id);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action completed successfully'.tr())),
        );
        await _fetchUsers();
      }
    } catch (e) {
      String errorText = e.toString();
      String message;

      if (errorText.contains("Admin not found".tr())) {
        message = "المستخدم ليس مسؤولًا أو غير موجود".tr();
      } else if (errorText.contains("Main admin cannot be deleted".tr())) {
        message = "لا يمكن حذف المسؤول الرئيسي".tr();
      } else if (errorText.contains("Admin already exists".tr())) {
        message = "هذا المستخدم بالفعل مسؤول".tr();
      } else if (errorText.contains("User is already blocked".tr())) {
        message = "المستخدم محظور بالفعل".tr();
      } else if (errorText.contains("User is already unblocked".tr())) {
        message = "المستخدم غير محظور بالفعل".tr();
      } else if (errorText.contains("User is already active".tr())) {
        message = "المستخدم نشط بالفعل".tr();
      } else if (errorText.contains("Invalid user".tr())) {
        message = "المستخدم غير صالح أو مسؤول".tr();
      } else {
        message = "حدث خطأ: $errorText".tr();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Error in _handleAction: $errorText");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Connection Error'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              errorMessage ?? 'Failed to load users'.tr(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isRetrying
                  ? null
                  : () {
                      setState(() {
                        isRetrying = true;
                      });
                      _fetchUsers();
                    },
              icon: isRetrying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.refresh),
              label: Text(isRetrying ? 'Retrying...'.tr() : 'Retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _fetchUsers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  AssetImage('assets/images/user (1).png'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildChip(
                                        label: user.isAdmin
                                            ? 'Admin'.tr()
                                            : 'User'.tr(),
                                        color: user.isAdmin
                                            ? Colors.blue
                                            : (user.kindOfWork == 'Doctor'.tr()
                                                ? Colors.green
                                                : Colors.red),
                                        icon: user.isAdmin
                                            ? Icons.admin_panel_settings
                                            : (user.kindOfWork == 'Doctor'.tr()
                                                ? Icons.medical_services
                                                : Icons.person),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildChip(
                                        label:
                                            _getStatusLabel(user.status.index),
                                        color:
                                            _getStatusColor(user.status.index),
                                        icon: _getStatusIcon(user.status.index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_userOfAppIdString != null &&
                                int.tryParse(_userOfAppIdString!) != user.id)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) =>
                                    _handleAction(value, user),
                                itemBuilder: (context) {
                                  return _buildPopupMenuItems(user);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _fetchUsers,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(UserModel user) {
    List<PopupMenuEntry<String>> menuItems = [];

    // Admin role actions
    if (!user.isAdmin) {
      menuItems.add(
        _buildMenuItem("Assign Admin".tr(), Icons.person_add),
      );
    } else {
      menuItems.add(
        _buildMenuItem("Remove Admin".tr(), Icons.person_remove, Colors.red),
      );
    }

    // Status-based actions
    switch (user.status) {
      case UserStatus.active:
        // For active users, show block and deactivate options
        menuItems.addAll([
          const PopupMenuDivider(),
          _buildMenuItem("Block User".tr(), Icons.block, Colors.red),
          _buildMenuItem(
              "Deactivate User".tr(), Icons.person_off, Colors.orange),
        ]);
        break;
      case UserStatus.blocked:
        // For blocked users, only show unblock option
        menuItems.addAll([
          const PopupMenuDivider(),
          _buildMenuItem("Unblock User".tr(), Icons.lock_open, Colors.green),
        ]);
        break;
      case UserStatus.deactivated:
        // For deactivated users, only show activate option
        menuItems.addAll([
          const PopupMenuDivider(),
          _buildMenuItem(
              "Activate User".tr(), Icons.person_add_alt_1, Colors.green),
        ]);
        break;
    }

    return menuItems;
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Active'.tr();
      case 1:
        return 'Blocked'.tr();
      case 2:
        return 'Deactivated'.tr();
      default:
        return 'Unknown'.tr();
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.block;
      case 2:
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, IconData icon,
      [Color? iconColor]) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.black87),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
