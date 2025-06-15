import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/screens/delivery/admin_dashboard_page.dart.dart';
import 'package:graduation_project/screens/delivery/delivery_person_profile_page.dart';
import 'package:graduation_project/screens/delivery/delivery_person_request_page.dart.dart';
import 'package:graduation_project/screens/donation/DonationProductsScreen.dart';
import 'package:graduation_project/screens/UserOrderStatusPage.dart';
import 'package:graduation_project/screens/admin/admin_main_screen.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/fix_product_screen.dart';
import 'package:graduation_project/screens/setting_page.dart';
import 'package:graduation_project/screens/pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/screens/contact_us/contact_us.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/screens/user_coupons.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'drawer.dart';

class DrawerItems extends StatefulWidget {
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
  State<DrawerItems> createState() => _DrawerItemsState();
}

class _DrawerItemsState extends State<DrawerItems> {
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? id = await UserServicee().getUserId();
    setState(() {
      if (id != null && id.isNotEmpty) {
        try {
          userId = int.parse(id);
        } catch (e) {
          debugPrint('Error parsing userId: $e');
          userId = null;
        }
      } else {
        userId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _buildDrawerItems(context),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    final List<Widget> items = [];

    // Main items
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

    // Conditional items
    switch (widget.drawerType) {
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
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('UserOrderStatusPage'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserOrderStatusPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('DeliveryPersonAdminPage'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardPage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('fixx'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FixProductScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('DeliveryPersonRequestPage'.tr()),
            onTap: userId != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPersonRequestPage(
                          userId: userId!,
                        ),
                      ),
                    )
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('DonationProduct'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DonationProductsScreen(),
              ),
            ),
          ),
        ]);
        break;

      case DrawerType.admin:
        items.add(
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: Text('drawer.admin_dashboard'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdminDashboardApp()),
            ),
          ),
        );
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
          if (userId != null)
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text('drawer.my_coupons'.tr()),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserCouponsPage(
                          userId: userId.toString(),
                        )),
              ),
            ),
        ]);
        break;

      case DrawerType.buyer:
        items.add(
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text('drawer.contact_us'.tr()),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsPage()),
            ),
          ),
        );
        break;
    }

    // Admin access for all types
    if (widget.isAdmin) {
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

    // Settings
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

    // Logout
    items.add(
      ListTile(
        leading: const Icon(Icons.logout),
        title: Text('drawer.logout'.tr()),
        onTap: widget.onLogout,
      ),
    );

    return items;
  }
}
