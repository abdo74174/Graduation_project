import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> stats = [
    {
      "title": "Products",
      "value": 120,
      "icon": Icons.shopping_bag,
      "color": Colors.blue,
    },
    {
      "title": "Orders",
      "value": 75,
      "icon": Icons.shopping_cart,
      "color": Colors.green,
    },
    {
      "title": "Revenue",
      "value": "\$12.5K",
      "icon": Icons.attach_money,
      "color": Colors.orange,
    },
    {
      "title": "Customers",
      "value": 50,
      "icon": Icons.people,
      "color": Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StatsCard(stats: stats),
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1, // Fixed ratio to avoid overflow
      ),
      itemBuilder: (context, index) {
        final item = stats[index];

        return GestureDetector(
          onTap: () {
            switch (item['title']) {
              case 'Products':
                Navigator.pushNamed(context, '/products');
                break;
              case 'Orders':
                Navigator.pushNamed(context, '/orders');
                break;
              case 'Revenue':
                Navigator.pushNamed(context, '/revenue');
                break;
              case 'Customers':
                Navigator.pushNamed(context, '/customers');
                break;
            }
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"], color: item["color"], size: 36),
                  const SizedBox(height: 10),
                  Text(
                    item["title"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${item['value']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
