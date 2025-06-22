import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/User/assign_role.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage>
    with TickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  late AnimationController _animationController;
  late AnimationController _refreshController;
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool isLoading = false;
  String? errorMessage;
  bool isRetrying = false;
  String? _userOfAppIdString;
  String searchQuery = '';
  String selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadUserId();
    _fetchUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
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

    _refreshController.repeat();

    try {
      final response = await _apiService.getUsers();
      if (mounted) {
        setState(() {
          users = response.map((json) => UserModel.fromJson(json)).toList();
          _filterUsers();
          isLoading = false;
          isRetrying = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    } finally {
      _refreshController.stop();
      _refreshController.reset();
    }
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesSearch = user.name
                ?.toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
            false ||
                user.email.toLowerCase().contains(searchQuery.toLowerCase());

        final matchesFilter = selectedFilter == 'All' ||
            (selectedFilter == 'Admins' && user.isAdmin) ||
            (selectedFilter == 'Users' && !user.isAdmin) ||
            (selectedFilter == 'Active' && user.status == UserStatus.active) ||
            (selectedFilter == 'Blocked' &&
                user.status == UserStatus.blocked) ||
            (selectedFilter == 'Deactivated' &&
                user.status == UserStatus.deactivated) ||
            (selectedFilter == 'Doctors' && user.kindOfWork == 'Doctor'.tr());

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _handleAction(String action, UserModel user) async {
    if (user.id == int.parse(_userOfAppIdString!)) {
      _showSnackBar(
          'You cannot perform actions on your own account.'.tr(), Colors.red);
      return;
    }

    // Show confirmation dialog for destructive actions
    if (['Remove Admin', 'Block User', 'Deactivate User'].contains(action)) {
      final confirmed = await _showConfirmationDialog(action, user);
      if (!confirmed) return;
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
        _showSnackBar('$action completed successfully'.tr(), Colors.green);
        await _fetchUsers();
      }
    } catch (e) {
      String errorText = e.toString();
      String message = _getErrorMessage(errorText);

      if (mounted) {
        _showSnackBar(message, Colors.red);
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

  String _getErrorMessage(String errorText) {
    if (errorText.contains("Admin not found".tr())) {
      return "المستخدم ليس مسؤولًا أو غير موجود".tr();
    } else if (errorText.contains("Main admin cannot be deleted".tr())) {
      return "لا يمكن حذف المسؤول الرئيسي".tr();
    } else if (errorText.contains("Admin already exists".tr())) {
      return "هذا المستخدم بالفعل مسؤول".tr();
    } else if (errorText.contains("User is already blocked".tr())) {
      return "المستخدم محظور بالفعل".tr();
    } else if (errorText.contains("User is already unblocked".tr())) {
      return "المستخدم غير محظور بالفعل".tr();
    } else if (errorText.contains("User is already active".tr())) {
      return "المستخدم نشط بالفعل".tr();
    } else if (errorText.contains("Invalid user".tr())) {
      return "المستخدم غير صالح أو مسؤول".tr();
    } else {
      return "حدث خطأ: $errorText".tr();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String action, UserModel user) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Confirm Action'.tr()),
              ],
            ),
            content:
                Text('Are you sure you want to $action for ${user.name}?'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Confirm'.tr()),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...'.tr(),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                          _filterUsers();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterUsers();
              },
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Admins',
                'Users',
                'Doctors',
                'Active',
                'Blocked',
                'Deactivated'
              ]
                  .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: selectedFilter == filter,
                          label: Text(filter.tr()),
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                            _filterUsers();
                          },
                          selectedColor: pkColor.withOpacity(0.3),
                          checkmarkColor: pkColor,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalUsers = users.length;
    final admins = users.where((u) => u.isAdmin).length;
    final activeUsers =
        users.where((u) => u.status == UserStatus.active).length;
    final blockedUsers =
        users.where((u) => u.status == UserStatus.blocked).length;

    return Container(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildStatCard('Total Users'.tr(), totalUsers.toString(),
              Icons.people, Colors.blue),
          _buildStatCard('Admins'.tr(), admins.toString(),
              Icons.admin_panel_settings, Colors.purple),
          _buildStatCard('Active'.tr(), activeUsers.toString(),
              Icons.check_circle, Colors.green),
          _buildStatCard(
              'Blocked'.tr(), blockedUsers.toString(), Icons.block, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Failed to load users'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.refresh),
              label: Text(isRetrying ? 'Retrying...'.tr() : 'Retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: pkColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pkColor,
        foregroundColor: Colors.white,
        title: Text(
          'User Management'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          RotationTransition(
            turns: _refreshController,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: isLoading ? null : _fetchUsers,
            ),
          ),
        ],
      ),
      body: isLoading && users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: pkColor),
                  const SizedBox(height: 16),
                  Text('Loading users...'.tr()),
                ],
              ),
            )
          : errorMessage != null && users.isEmpty
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildSearchAndFilter(),
                    if (users.isNotEmpty) _buildStatsCards(),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return AnimatedOpacity(
                            opacity: _animationController.value,
                            duration: const Duration(milliseconds: 300),
                            child: filteredUsers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No users found'.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = filteredUsers[index];
                                      return _buildUserCard(user, index);
                                    },
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _fetchUsers,
        backgroundColor: pkColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: Text('Refresh'.tr()),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: _getUserAvatarColor(user),
                    child: user.name != null && user.name!.isNotEmpty
                        ? Text(
                            user.name![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            label: user.isAdmin ? 'Admin'.tr() : 'User'.tr(),
                            color: user.isAdmin ? Colors.blue : Colors.grey,
                            icon: user.isAdmin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                          ),
                          if (user.kindOfWork == 'Doctor'.tr())
                            _buildChip(
                              label: 'Doctor'.tr(),
                              color: Colors.green,
                              icon: Icons.medical_services,
                            ),
                          _buildChip(
                            label: _getStatusLabel(user.status.index),
                            color: _getStatusColor(user.status.index),
                            icon: _getStatusIcon(user.status.index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Menu
                if (_userOfAppIdString != null &&
                    int.tryParse(_userOfAppIdString!) != user.id)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => _handleAction(value, user),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => _buildPopupMenuItems(user),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getUserAvatarColor(UserModel user) {
    if (user.isAdmin) return Colors.blue;
    if (user.kindOfWork == 'Doctor'.tr()) return Colors.green;
    switch (user.status) {
      case UserStatus.active:
        return Colors.teal;
      case UserStatus.blocked:
        return Colors.red;
      case UserStatus.deactivated:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(UserModel user) {
    List<PopupMenuEntry<String>> menuItems = [];

    // Admin role actions
    if (!user.isAdmin) {
      menuItems.add(
          _buildMenuItem("Assign Admin".tr(), Icons.person_add, Colors.blue));
    } else {
      menuItems.add(
          _buildMenuItem("Remove Admin".tr(), Icons.person_remove, Colors.red));
    }

    // Status-based actions
    switch (user.status) {
      case UserStatus.active:
        menuItems.addAll([
          const PopupMenuDivider(),
          _buildMenuItem("Block User".tr(), Icons.block, Colors.red),
          _buildMenuItem(
              "Deactivate User".tr(), Icons.person_off, Colors.orange),
        ]);
        break;
      case UserStatus.blocked:
        menuItems.addAll([
          const PopupMenuDivider(),
          _buildMenuItem("Unblock User".tr(), Icons.lock_open, Colors.green),
        ]);
        break;
      case UserStatus.deactivated:
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String label, IconData icon,
      [Color? iconColor]) {
    return PopupMenuItem<String>(
      value: label,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
