import 'package:flutter/material.dart';

class RevenuePage extends StatelessWidget {
  final List<Map<String, dynamic>> revenueData = [
    {"month": "Jan", "revenue": 3200},
    {"month": "Feb", "revenue": 2800},
    {"month": "Mar", "revenue": 3500},
    {"month": "Apr", "revenue": 4000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Revenue")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Revenue Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: revenueData.length,
              itemBuilder: (context, index) {
                final revenue = revenueData[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    title: Text("${revenue["month"]}"),
                    trailing: Text("\$${revenue["revenue"]}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
