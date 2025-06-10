import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/screens/admin/admin_main_screen.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:graduation_project/screens/adding_pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/screens/contact_us.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'drawer.dart';

class DrawerItems extends StatelessWidget {
  final DrawerType drawerType;
  final bool isAdmin;
  final VoidCallback onLogout;

  const DrawerItems({
    super.key,
    required this.drawerType,
    required this.isAdmin,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _buildDrawerItems(context),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final List<Widget> items = [];

    // Main items that appear in all drawer types
    items.add(
      ListTile(
        leading: const Icon(Icons.person),
        title: Text('drawer.profile'.tr()),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        ),
      ),
    );

    // Conditional items based on drawer type
    switch (drawerType) {
      case DrawerType.main:
        items.addAll([
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text('drawer.contact_us'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('drawer.my_products'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProductsPage()),
            ),
          ),
        ]);
        break;

      case DrawerType.admin:
        items.addAll([
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: Text('drawer.admin_dashboard'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminDashboardApp()),
            ),
          ),
        ]);
        break;

      case DrawerType.seller:
        items.addAll([
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('drawer.my_products'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProductsPage()),
            ),
          ),
        ]);
        break;

      case DrawerType.buyer:
        items.addAll([
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text('drawer.contact_us'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            ),
          ),
        ]);
        break;
    }

    // Admin panel for all drawer types if user is admin
    if (isAdmin) {
      items.add(
        ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: Text('drawer.admin'.tr()),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardApp()),
          ),
        ),
      );
    }

    // Add Settings just before Logout
    items.add(
      ListTile(
        leading: const Icon(Icons.settings),
        title: Text('drawer.settings'.tr()),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        ),
      ),
    );

    // Logout always appears last
    items.add(
      ListTile(
        leading: const Icon(Icons.logout),
        title: Text('drawer.logout'.tr()),
        onTap: onLogout,
      ),
    );

    return items;
  }
}
