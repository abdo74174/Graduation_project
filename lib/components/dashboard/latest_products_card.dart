import 'package:flutter/material.dart';

class LatestProductsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Latest Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/equip4.png'),
              ),
              title: Text("Air Compressing Therapy Device"),
              subtitle: Text("Price: \$300"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/equip3.png'),
              ),
              title: Text("AutoClave"),
              subtitle: Text("Price: \$100"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ],
    );
  }
}
