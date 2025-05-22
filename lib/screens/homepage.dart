import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:graduation_project/components/home_page/notched_navigation_bar.dart';
import 'package:graduation_project/components/home_page/searchbar.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/home_page/drawer.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/screens/cart.dart';
import 'package:graduation_project/screens/categories_page.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/favourite_page.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:easy_localization/easy_localization.dart';

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

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Widget _buildHomeContent() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: _clearSearch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      const SizedBox(
                          height: 100), // Extra padding for bottom nav bar
                    ],
                  ),
                  if (searchResults.isNotEmpty) _buildSearchResults(),
                ],
              ),
            ),
          );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Color(pkColor.value), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Color(pkColor.value).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                "assets/images/offer.avif",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
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
                  "Categories".tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(pkColor.value),
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
                    "View all".tr(),
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
                  borderColor: isDark ? Colors.white : const Color(0xFF3B8FDA),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "Products".tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(pkColor.value),
            ),
          ),
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
      ],
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
                "\$${product.price.toStringAsFixed(2)}",
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
    await _loadProducts();
  }

  Future<void> _checkOfflineStatus() async {
    final serverStatusService = ServerStatusService();
    final online = await serverStatusService.checkAndUpdateServerStatus();
    setState(() {
      isOffline = !online;
    });
  }

  Future<void> _loadCategories() async {
    try {
      if (isOffline) {
        setState(() {
          categories = dummyCategories;
          isLoading = false;
        });
      } else {
        final result = await Future.any([
          CategoryService().fetchAllCategories(),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException('Timeout')),
        ]);
        setState(() {
          categories = result;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        categories = dummyCategories;
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (isOffline) {
        setState(() {
          products = dummyProducts;
          isLoading = false;
        });
      } else {
        final result = await Future.any([
          ProductService().fetchAllProducts(),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException('Timeout')),
        ]);
        setState(() {
          products = result;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        products = dummyProducts;
        isLoading = false;
      });
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
        const SnackBar(content: Text('Please log in to start a chat')),
      );
      return;
    }

    const contactEmail = 'abdulrhmanosama744@gmail.com';
    if (contactEmail == email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot chat with yourself')),
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
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _clearSearch() {
    setState(() {
      searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentScreens = [
      _buildHomeContent(),
      const CategoryScreen(),
      const ShoppingCartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _selectedIndex == 0 ? _buildAppBar(isDark) : null,
      drawer: const DrawerHome(),
      body: currentScreens[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
          Icon(
            Icons.home_outlined,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.category_outlined,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_cart_outlined,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.person_outline,
            size: 30,
            color: Colors.white,
          ),
        ],
        color: Color(pkColor.value),
        buttonBackgroundColor: Color(pkColor.value),
        backgroundColor: isDark ? Colors.black : Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
          tooltip: 'Chat with Support',
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavouritePage()),
            );
          },
          icon: Icon(Icons.favorite_border_outlined,
              color: isDark ? Colors.white : Colors.black),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
            );
          },
          icon: Icon(Icons.shopping_cart_outlined,
              color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }
}
