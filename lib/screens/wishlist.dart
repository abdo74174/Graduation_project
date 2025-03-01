import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  String? selectedCategory;
  String? selectedSort;

  final List<String> categories = [
    "Furniture",
    "Physical Therapy Equipment",
    "Specialties"
  ];

  final List<String> sortOptions = ["Price: Low to High", "Price: High to Low"];

  List<Map<String, dynamic>> wishlistItems = [
    {
      'image': 'assets/images/equip1.png',
      'price': 500,
      'discountedPrice': null,
    },
    {
      'image': 'assets/images/equip1.png',
      'price': 450,
      'discountedPrice': 300,
    },
    {
      'image': 'assets/images/equip1.png',
      'price': 350,
      'discountedPrice': null,
    },
    {
      'image': 'assets/images/equip1.png',
      'price': 150,
      'discountedPrice': null,
    },
  ];

  void _sortItems(String? sortOption) {
    setState(() {
      selectedSort = sortOption;

      wishlistItems.sort((a, b) {
        int priceA = a['discountedPrice'] ?? a['price'];
        int priceB = b['discountedPrice'] ?? b['price'];

        if (sortOption == "Price: Low to High") {
          return priceA.compareTo(priceB);
        } else if (sortOption == "Price: High to Low") {
          return priceB.compareTo(priceA);
        }
        return 0;
      });
    });
  }

  void _openFilterDialog() {
    //print("Filter tapped!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Wishlist",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Sort Dropdown
                Expanded(
                  child: _buildDropdown(
                    hintText: "Sort",
                    value: selectedSort,
                    items: sortOptions,
                    onChanged: _sortItems,
                  ),
                ),

                // Category Dropdown
                Expanded(
                  child: _buildDropdown(
                    hintText: "Category",
                    value: selectedCategory,
                    items: categories,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _openFilterDialog,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Filter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        Icon(
                          Icons.filter_alt_outlined,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistItems[index];
                  return Card(
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          item['image'],
                          height: 150,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: item['discountedPrice'] != null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${item['discountedPrice']}\$",
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${item['price']}\$",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "${item['price']}\$",
                                          style: const TextStyle(
                                            fontSize: 18, // Bigger Price
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 8.0), // Space after cart icon
                                child: IconButton(
                                  icon: const Icon(Icons.shopping_cart,
                                      size: 28), // Bigger Cart Icon
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<String>(
          hint: Text(
            hintText,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          value: value,
          isExpanded: true, // Expands the dropdown
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        ),
      ),
    );
  }
}
