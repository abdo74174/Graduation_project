import 'package:flutter/material.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/screens/userInfo/profile.dart';
import 'package:graduation_project/screens/user_products_page.dart';
import 'package:graduation_project/Models/product_model.dart';
// Import other screens as needed

class AppRoutes {
  static const String productPage = '/product';
  static const String userProfile = '/userProfile';
  static const String userProducts = '/userProducts';
  // Define other routes

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productPage:
        final args = settings.arguments as ProductPageArguments;
        return MaterialPageRoute(
          builder: (_) => ProductPage(product: args.product),
        );
      case userProfile:
        return MaterialPageRoute(
          builder: (_) => ProfilePage(),
        );
      case userProducts:
        return MaterialPageRoute(
          builder: (_) => UserProductsPage(),
        );
      // Add other cases for different routes
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class ProductPageArguments {
  final ProductModel product;
  ProductPageArguments({required this.product});
}
