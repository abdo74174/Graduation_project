import 'package:flutter/material.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/User/assign_role.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final AdminApiService _apiService = AdminApiService();
  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiService.getUsers();
      setState(() {
        users = response.map((json) => UserModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleAction(String action, UserModel user) async {
    try {
      switch (action) {
        case 'Assign Admin':
          await _apiService.addAdmin(user.email, 'default_password');
          break;
        case 'Delete Admin':
          await _apiService.deleteAdmin(user.id);
          break;
        case 'Block User':
          await _apiService.blockUser(user.id);
          break;
        case 'Deactivate User':
          await _apiService.deactivateUser(user.id);
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$action completed successfully')),
      );
      await _fetchUsers();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin and User Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: pkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage!,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 30, 115, 184))),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    radius: 28,
                                    backgroundImage: AssetImage(
                                        'assets/images/user (1).png')),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _buildChip(
                                            label: user.isAdmin
                                                ? 'Admin'
                                                : user.kindOfWork,
                                            color: user.isAdmin
                                                ? Colors.blue
                                                : user.kindOfWork == 'Doctor'
                                                    ? Colors.green
                                                    : Colors.red,
                                            icon: user.isAdmin
                                                ? Icons.admin_panel_settings
                                                : user.kindOfWork == 'Doctor'
                                                    ? Icons.medical_services
                                                    : Icons.cancel,
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) =>
                                      _handleAction(value, user),
                                  itemBuilder: (context) => [
                                    _buildMenuItem(
                                        "Assign Admin", Icons.person),
                                    _buildMenuItem("Delete Admin", Icons.delete,
                                        Colors.red),
                                    _buildMenuItem(
                                        "Block User", Icons.block, Colors.red),
                                    _buildMenuItem("Deactivate User",
                                        Icons.do_not_disturb_on, Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchUsers,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildChip(
      {required String label, required Color color, required IconData icon}) {
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
