import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:graduation_project/components/home_page/drawer.dart';
import 'package:graduation_project/components/home_page/searchbar.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/screens/cart.dart';
import 'package:graduation_project/screens/categories_page.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/delivery/delivery_person_request_page.dart.dart';
import 'package:graduation_project/screens/delivery/user_order_confirmation_page.dart';
import 'package:graduation_project/screens/discounted_products_page.dart';
import 'package:graduation_project/screens/favourite_page.dart';
import 'package:graduation_project/screens/installments/installment_product_page.dart';
import 'package:graduation_project/screens/installments/installment_terms_page.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fix_product_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];
  List<ProductModel> searchResults = [];
  bool isLoading = true;
  bool isOffline = false;
  int _selectedIndex = 0;
  Timer? _debounce;
  PageController _discountPageController =
      PageController(viewportFraction: 0.85);
  Timer? _autoSlideTimer;
  int? UserIdd;

  @override
  void initState() {
    super.initState();
    _initApp();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_discountPageController.hasClients) return;
      int nextPage = (_discountPageController.page?.round() ?? 0) + 1;
      if (nextPage >= products.where((p) => p.discount > 0).length) {
        nextPage = 0;
      }
      _discountPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildHomeContent() {
    final discountedProducts = products.where((p) => p.discount > 0).toList();
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: _clearSearch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 16),
                      CustomizeSearchBar(
                        products: products,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 24),
                      _buildBanner(),
                      const SizedBox(height: 32),
                      _buildCategoriesSection(),
                      _buildProductsSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                  if (searchResults.isNotEmpty) _buildSearchResults(),
                ],
              ),
            ),
          );
  }

  Widget _buildBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscountedProductsPage(products: products),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Color(pkColor.value), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Color(pkColor.value).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  "assets/images/offer.avif",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                // gradient: LinearGradient(
                //   colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                //   begin: Alignment.bottomCenter,
                //   end: Alignment.topCenter,
                // ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "special_offers".tr(),
                    style: const TextStyle(
                      color: pTexColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Text(
                  "categories".tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : pTexColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(pkColor.value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "view_all".tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(pkColor.value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 4 : 8,
                  right: index == categories.length - 1 ? 4 : 8,
                ),
                child: CategoryView(
                  borderColor: isDark ? Colors.grey : Colors.black87,
                  category: categories[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryScreen(id: index),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discountedProducts = products.where((p) => p.discount > 0).toList();
    final installmentProducts =
        products.where((p) => p.installmentAvailable == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Text(
                "Products".tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : pTexColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(pkColor.value).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "view_all".tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(pkColor.value),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 550,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductPage(product: products[index]),
                    ),
                  );
                },
                product: products[index],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (discountedProducts.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "discounted_products".tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Color(pkColor.value),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DiscountedProductsPage(products: products),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(pkColor.value).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "view_all".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(pkColor.value),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DiscountedProduct(
                discountedProducts: discountedProducts,
                discountPageController: _discountPageController,
              ),
            ],
          ),
        const SizedBox(height: 24),
        if (installmentProducts.isNotEmpty)
          InstallmentSection(
            isDark: isDark,
            products: products,
            pkColor: Color(pkColor.value),
          ),
        _buildDeliveryAdSection(),
        Divider(
          height: 1,
          indent: 20,
          endIndent: 20,
          thickness: .4,
          color: Colors.black,
        ),
        // SizedBox(
        //   height: 8,
        // ),
        _buildFixSection(),
        SizedBox(
          height: 10,
        ),
        _buildFooterSection(),
      ],
    );
  }

  int _selectedSection = -1;

  Widget _buildDeliveryAdSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSection = 0;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedSection == 0 ? Colors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Work as Delivery".tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.motorcycle_outlined, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join our delivery team and earn extra income!".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (UserIdd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User ID not available".tr())),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DeliveryPersonRequestPage(userId: UserIdd!),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Apply for Delivery Job".tr())),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(pkColor.value),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Apply Now".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSection = 1;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedSection == 1 ? Colors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Fix Your Equip".tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.build, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "U Now Can Repair Your Equipment ".tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (UserIdd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User ID not available".tr())),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    FixProductScreen(),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Apply for Delivery Job".tr())),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(pkColor.value),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Contact With Us".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $url".tr())),
        );
      }
    }

    Future<void> _launchWhatsApp() async {
      const phoneNumber = "+201125411335";
      const message = "Hello, I have a question about Loolia Closet!";
      final whatsappUrl = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
      );
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch WhatsApp".tr())),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.grey[900]! : Colors.grey[100]!,
            isDark ? Colors.grey[850]! : Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Policies".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          _launchURL("https://looliacloset.com/about"),
                      child: Text(
                        "About Us".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.cyan[300] : Color(pkColor.value),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _launchURL("https://looliacloset.com/privacy"),
                      child: Text(
                        "Privacy Policy".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.cyan[300] : Color(pkColor.value),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _launchURL("https://looliacloset.com/refund"),
                      child: Text(
                        "Refund Policy".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.cyan[300] : Color(pkColor.value),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _launchURL("https://looliacloset.com/terms"),
                      child: Text(
                        "Terms of Service".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.cyan[300] : Color(pkColor.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Get in touch".tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _launchURL("tel:+01200777863"),
                      child: Text(
                        "+01200777863",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchURL("tel:+01228582843"),
                      child: Text(
                        "+01228582843",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.facebook,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () =>
                        _launchURL("https://facebook.com/looliacloset"),
                    tooltip: "Facebook",
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.camera_alt,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () =>
                        _launchURL("https://snapchat.com/looliacloset"),
                    tooltip: "Snapchat",
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.videocam,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () =>
                        _launchURL("https://tiktok.com/looliacloset"),
                    tooltip: "TikTok",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              Icon(Icons.payment,
                  color: isDark ? Colors.white : Colors.black, size: 20),
              Icon(Icons.apple,
                  color: isDark ? Colors.white : Colors.black, size: 20),
              Icon(Icons.credit_card,
                  color: isDark ? Colors.white : Colors.black, size: 20),
              Icon(Icons.payment,
                  color: isDark ? Colors.white : Colors.black, size: 20),
              Icon(Icons.credit_card,
                  color: isDark ? Colors.white : Colors.black, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "© 2025 Loolia Closet Egypt | LANCÔME".tr(),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Secure payments by ".tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Icon(Icons.payment,
                  color: isDark ? Colors.white : Colors.black, size: 16),
              Text(
                "VISA".tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: _launchWhatsApp,
                icon: Icon(Icons.chat, color: Color(pkColor.value), size: 16),
                label: Text(
                  "Chat With Us".tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(pkColor.value),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Positioned.fill(
      top: 60,
      child: Material(
        color: Colors.black54,
        child: ListView(
          children: searchResults.map((product) {
            return ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  product.images.isNotEmpty
                      ? product.images[0]
                      : 'default_image_url',
                ),
                radius: 25,
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                product.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              trailing: Text(
                "${product.price} EGP",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              tileColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(product: product),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _initApp() async {
    await _checkOfflineStatus();
    await _loadCategories();
    await getUserId();
    await _loadProducts();
  }

  Future<void> getUserId() async {
    final userId = await UserServicee().getUserId();
    if (userId != null) {
      UserIdd = int.parse(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user ID".tr())),
      );
    }
  }

  Future<void> _checkOfflineStatus() async {
    final serverStatusService = ServerStatusService();
    final online = await serverStatusService.checkAndUpdateServerStatus();
    if (mounted) {
      setState(() {
        isOffline = !online;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      if (isOffline) {
        if (mounted) {
          setState(() {
            categories = dummyCategories;
            isLoading = false;
          });
        }
      } else {
        final result = await Future.any([
          CategoryService().fetchAllCategories(),
          Future.delayed(const Duration(seconds: 100),
              () => throw TimeoutException('Timeout')),
        ]);
        if (mounted) {
          setState(() {
            categories = result;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          categories = dummyCategories;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (isOffline) {
        if (mounted) {
          setState(() {
            products = dummyProducts;
            isLoading = false;
          });
        }
      } else {
        final result = await Future.any([
          ProductService().fetchAllProducts(),
          Future.delayed(const Duration(seconds: 100),
              () => throw TimeoutException('Timeout')),
        ]);
        if (mounted) {
          setState(() {
            products = result;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = dummyProducts;
          isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (query.isEmpty) {
        setState(() {
          searchResults = [];
        });
      } else {
        List<ProductModel> filtered = products.where((product) {
          final nameMatch =
              product.name.toLowerCase().contains(query.toLowerCase());
          final descMatch =
              product.description.toLowerCase().contains(query.toLowerCase());
          return nameMatch || descMatch;
        }).toList();

        setState(() {
          searchResults = filtered;
        });
      }
    });
  }

  void _startChat() async {
    final email = await UserServicee().getEmail();
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('please_login_to_chat'.tr())),
      );
      return;
    }

    const contactEmail = 'abdulrhmanosama744@gmail.com';
    if (contactEmail == email) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cannot_chat_with_yourself'.tr())),
      );
      return;
    }

    try {
      final contactName = 'Support';
      final chatId = '${email}_$contactEmail';
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'contactName': contactName,
        'lastMessage': '',
        'lastMessageTime': DateTime.now(),
        'unreadCount': 0,
        'contactId': contactEmail,
        'isPinned': false,
        'participants': [email, contactEmail],
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chatId,
            contactId: contactEmail,
            contactName: contactName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_starting_chat'.tr())),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autoSlideTimer?.cancel();
    _discountPageController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    if (mounted) {
      setState(() {
        searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentScreens = [
      _buildHomeContent(),
      const CategoryScreen(),
      const FavouritePage(),
      const ShoppingCartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _selectedIndex == 0 ? _buildAppBar(isDark) : null,
      drawer: const DrawerHome(),
      body: SafeArea(child: currentScreens[_selectedIndex]),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.category_outlined, size: 30, color: Colors.white),
          Icon(Icons.favorite_border_outlined, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
        color: Color(pkColor.value),
        buttonBackgroundColor: Color(pkColor.value),
        backgroundColor: isDark ? Colors.black : Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      toolbarHeight: 40,
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        IconButton(
          onPressed: _startChat,
          icon: Icon(
            Icons.support_agent,
            color: isDark ? Colors.white : Colors.black,
          ),
          tooltip: 'chat_with_support'.tr(),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
            );
          },
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class InstallmentSection extends StatelessWidget {
  final bool isDark;
  final List<ProductModel> products;
  final Color pkColor;

  const InstallmentSection({
    super.key,
    required this.isDark,
    required this.products,
    required this.pkColor,
  });

  Widget _buildBankPromotionCard({
    required String logo,
    required String bankName,
    required String termsText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pkColor.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  logo,
                  height: 50,
                  width: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 24,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bankName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "0% Interest",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      termsText.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pkColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "installment_products".tr(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(pkColor.value),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "view_details".tr(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.blueAccent,
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.blueAccent,
                    size: 24,
                  ),
                  tooltip: "view_all_installment_products".tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InstallmentProductsPage(products: products),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                _buildBankPromotionCard(
                  logo: "assets/images/sapbank.png",
                  bankName: "SAB",
                  termsText: "when_using_sab_cards",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstallmentTermsPage(bank: "SAB"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildBankPromotionCard(
                  logo: "assets/images/Enbd.png",
                  bankName: "Emirates NBD",
                  termsText: "when_using_enbd_cards",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InstallmentTermsPage(bank: "Emirates NBD"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InstallmentProductsPage(products: products),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "View All Installments".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiscountedProduct extends StatelessWidget {
  final List<ProductModel> discountedProducts;
  final PageController discountPageController;

  const DiscountedProduct({
    super.key,
    required this.discountedProducts,
    required this.discountPageController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: discountPageController,
        itemCount: discountedProducts.length,
        itemBuilder: (context, index) {
          final product = discountedProducts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(product: product),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.images.isNotEmpty
                          ? Image.network(
                              product.images[0],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                              ),
                            )
                          : Container(color: Colors.grey[200]),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(pkColor.value),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "-${product.discount}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${product.price} EGP",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
