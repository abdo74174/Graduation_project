import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/Category_view.dart';
import 'package:graduation_project/components/drawer.dart';
import 'package:graduation_project/components/product.dart';
import 'package:graduation_project/components/searchbar.dart';
import 'package:graduation_project/components/test.dart';
import 'package:graduation_project/screens/cart.dart';
import 'package:graduation_project/screens/categories_page.dart';

import 'package:graduation_project/screens/wishlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> categories = [
    Category(id: 1, name: "Furniture"),
    Category(id: 2, name: "Physical Therapy Equipment"),
    Category(id: 3, name: "Specialties"),
    Category(id: 4, name: "Medical Devices"),
    Category(id: 5, name: "Home Care Equipment"),
  ];
  List<Product> products = [
    // Furniture - Patients Room
    Product(
        id: 1,
        subCategoryId: 1,
        name: "Adjustable Hospital Bed",
        price: 1200.00),
    Product(id: 2, subCategoryId: 1, name: "Bedside Cabinet", price: 299.99),
    Product(
        id: 3, subCategoryId: 1, name: "Patient Overbed Table", price: 199.99),

    // Furniture - Surgical Operating Room
    Product(id: 4, subCategoryId: 2, name: "Surgical Table", price: 3500.00),
    Product(
        id: 5,
        subCategoryId: 2,
        name: "Surgical Instrument Trolley",
        price: 799.99),
    Product(
        id: 6, subCategoryId: 2, name: "LED Surgical Light", price: 2500.00),

    // Furniture - Intensive Care Room
    Product(id: 7, subCategoryId: 3, name: "ICU Ventilator", price: 5000.00),
    Product(
        id: 8,
        subCategoryId: 3,
        name: "Multi-Parameter ICU Monitor",
        price: 4200.00),

    // Furniture - Reception Area
    Product(
        id: 9,
        subCategoryId: 4,
        name: "Medical Reception Desk",
        price: 1500.00),
    Product(
        id: 10, subCategoryId: 4, name: "Waiting Room Chairs", price: 500.00),

    // Physical Therapy - Massage Devices
    Product(id: 11, subCategoryId: 5, name: "Handheld Massager", price: 99.99),
    Product(
        id: 12, subCategoryId: 5, name: "Shiatsu Back Massager", price: 149.99),
    Product(
        id: 13,
        subCategoryId: 5,
        name: "Foot Reflexology Machine",
        price: 199.99),

    // Physical Therapy - Exercise Equipment
    Product(id: 14, subCategoryId: 6, name: "Resistance Bands", price: 29.99),
    Product(
        id: 15, subCategoryId: 6, name: "Treadmill for Rehab", price: 1500.00),
    Product(id: 16, subCategoryId: 6, name: "Balance Board", price: 59.99),

    // Physical Therapy - Electrotherapy
    Product(id: 17, subCategoryId: 7, name: "TENS Machine", price: 150.00),
    Product(
        id: 18,
        subCategoryId: 7,
        name: "Ultrasound Therapy Device",
        price: 300.00),

    // Specialties - Orthopedic Equipment
    Product(id: 19, subCategoryId: 9, name: "Knee Brace", price: 79.99),
    Product(
        id: 20,
        subCategoryId: 9,
        name: "Adjustable Back Support",
        price: 129.99),

    // Specialties - Cardiology Equipment
    Product(id: 21, subCategoryId: 10, name: "ECG Machine", price: 1500.00),
    Product(
        id: 22,
        subCategoryId: 10,
        name: "Portable Defibrillator",
        price: 2000.00),

    // Medical Devices - Blood Pressure Monitors
    Product(
        id: 23,
        subCategoryId: 12,
        name: "Automatic Blood Pressure Monitor",
        price: 69.99),
    Product(
        id: 24,
        subCategoryId: 12,
        name: "Manual Sphygmomanometer",
        price: 49.99),

    // Medical Devices - Blood Sugar Monitors
    Product(
        id: 25, subCategoryId: 13, name: "Digital Glucometer", price: 49.99),
    Product(
        id: 26,
        subCategoryId: 13,
        name: "Continuous Glucose Monitor",
        price: 249.99),

    // Medical Devices - Thermometers
    Product(
        id: 27, subCategoryId: 14, name: "Infrared Thermometer", price: 39.99),
    Product(
        id: 28,
        subCategoryId: 14,
        name: "Digital Ear Thermometer",
        price: 29.99),

    // Home Care - Wheelchairs
    Product(
        id: 29, subCategoryId: 16, name: "Foldable Wheelchair", price: 800.00),
    Product(
        id: 30, subCategoryId: 16, name: "Electric Wheelchair", price: 2500.00),

    // Home Care - Oxygen Concentrators
    Product(
        id: 31,
        subCategoryId: 17,
        name: "Portable Oxygen Concentrator",
        price: 1800.00),
    Product(
        id: 32,
        subCategoryId: 17,
        name: "Stationary Oxygen Concentrator",
        price: 2200.00),

    // Home Care - First Aid Kits
    Product(
        id: 33, subCategoryId: 18, name: "Basic First Aid Kit", price: 49.99),
    Product(
        id: 34, subCategoryId: 18, name: "Advanced Trauma Kit", price: 129.99),

    // Home Care - Mobility Aids
    Product(
        id: 35,
        subCategoryId: 19,
        name: "Adjustable Walking Cane",
        price: 39.99),
    Product(
        id: 36, subCategoryId: 19, name: "Walker with Wheels", price: 150.00),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WishlistPage();
              }));
            },
            icon: Icon(Icons.favorite_border_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CartPage();
              }));
            },
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      drawer: const DrawerHome(),
      body: Padding(
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
                      child: Image.asset(
                        "assets/images/offer.avif",
                        fit: BoxFit.cover,
                      ),
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CategoryScreen();
                    }));
                  },
                  child: Text(
                    "Categories",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CategoryScreen();
                    }));
                  },
                  child: Text(
                    "View all",
                    style: TextStyle(fontSize: 18),
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
                    borderColor: Color(0x00ffffff),
                    category: categories[index],
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CategoryScreen(
                          id: index,
                        );
                      }));
                    },
                  );
                },
              ),
            ),

            //     CategoryView(  category: categories,),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Products",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ProductPage();
                            }));
                          },
                          product: products[index]);
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
