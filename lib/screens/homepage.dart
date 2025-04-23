import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/home_page/drawer.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/home_page/searchbar.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/screens/favourite_page.dart';
import 'package:graduation_project/screens/cart.dart';
import 'package:graduation_project/screens/categories_page.dart';
import 'package:graduation_project/screens/chat_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];

  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  // Fetch categories from the API
  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await CategoryService().fetchAllCategories();
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
        print("-------------------------------------------------------");
        print("Fetched categories: ${categories.length}");
      });
    } catch (e) {
      print("Failed to fetch categories from API, using dummy data. Error: $e");
      setState(() {
        categories = dummyCategories; // Using dummy data here
        isLoading = false;
        print("-------------------------------------------------------");
        print("Using dummy categories: ${categories.length}");
      });
    }
  }

  // Fetch products from the API
  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await ProductService().fetchAllProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
        print("-------------------------------------------------------");
        print("Fetched products: ${products.length}");
      });
    } catch (e) {
      print("Failed to fetch products from API, using dummy data. Error: $e");
      setState(() {
        products = dummyProducts; // Using dummy data here
        isLoading = false;
        print("-------------------------------------------------------");
        print("Using dummy products: ${products.length}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Color(0xFFF5F5F5),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: isDark ? Colors.white : Color(0xFF1A1A1A)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritePage()),
              );
            },
            icon: Icon(Icons.favorite_border_outlined,
                color: isDark ? Colors.white : Color(0xFF1A1A1A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
            },
            icon: Icon(Icons.shopping_cart_outlined,
                color: isDark ? Colors.white : Color(0xFF1A1A1A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatScreen()));
            },
            icon: Icon(Icons.notifications_none,
                color: isDark ? Colors.white : Color(0xFF1A1A1A)),
          ),
        ],
      ),
      drawer: const DrawerHome(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  const CustomizeSearchBar(),
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
                                builder: (context) => CategoryScreen()),
                          );
                        },
                        child: Text(
                          "Categories",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF1A1A1A)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryScreen()),
                          );
                        },
                        child: Text(
                          "View all",
                          style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white : Color(0xFF1A1A1A)),
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
                          borderColor:
                              isDark ? Colors.white : Color(0xFF3B8FDA),
                          category: categories[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CategoryScreen(id: index)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF1A1A1A)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 550,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            ),
    );
  }
}
