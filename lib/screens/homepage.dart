import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/home_page/drawer.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/home_page/searchbar.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/screens/favourite_page.dart';
import 'package:graduation_project/screens/cart.dart';
import 'package:graduation_project/screens/categories_page.dart';
import 'package:graduation_project/screens/chat_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

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

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initApp();
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
      final contactName = 'Support'; // Hardcoded for simplicity
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

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: _startChat,
            icon: Icon(Icons.support_agent,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
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
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShoppingCartPage()),
              );
            },
            icon: Icon(Icons.shopping_cart_outlined,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
            icon: Icon(Icons.notifications_none,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
          ),
        ],
      ),
      drawer: const DrawerHome(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        CustomizeSearchBar(
                          products: products,
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(width: 1.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset("assets/images/offer.avif",
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoryScreen()),
                                );
                              },
                              child: Text(
                                "Categories".tr(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoryScreen()),
                                );
                              },
                              child: Text(
                                "View all".tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return CategoryView(
                                borderColor: isDark
                                    ? Colors.white
                                    : const Color(0xFF3B8FDA),
                                category: categories[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryScreen(id: index),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Products".tr(),
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 550,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return ProductCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ProductPage(
                                              product: products[index]);
                                        },
                                      ),
                                    );
                                  },
                                  product: products[index],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (searchResults.isNotEmpty)
                      Positioned.fill(
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
                                  product.description ?? '',
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
                                      builder: (context) =>
                                          ProductPage(product: product),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
