import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> items = [
    {
      'name': 'magnetic resonance imaging',
      'price': 330,
      'image': 'assets/images/equip1.png',
      'isFavorite': true,
    },
    {
      'name': 'Anesthesia Machine',
      'price': 200,
      'image': 'assets/images/equip2.png',
      'isFavorite': true,
    },
    {
      'name': 'AutoClave',
      'price': 100,
      'image': 'assets/images/equip3.png',
      'isFavorite': true,
    },
    {
      'name': 'Air Compressing Therapy Device',
      'price': 300,
      'image': 'assets/images/equip4.png',
      'isFavorite': true,
    },
  ];

  void _toggleFavorite(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _sortItems(bool ascending) {
    setState(() {
      items.sort((a, b) => ascending
          ? a['price'].compareTo(b['price'])
          : b['price'].compareTo(a['price']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF134FAF),
        title: const Text(
          "Favorites",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.white),
          onSelected: (value) {
            if (value == 'low_to_high') {
              _sortItems(true);
            } else {
              _sortItems(false);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'low_to_high',
              child: Text('Price: Low to High'),
            ),
            const PopupMenuItem(
              value: 'high_to_low',
              child: Text('Price: High to Low'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: items.isEmpty
            ? const Center(
                child: Text(
                  'No favorites available.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                      0.75, // Adjusted to allow more vertical space
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    item['image'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _toggleFavorite(index),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "₹${item['price']}.00",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
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
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}
