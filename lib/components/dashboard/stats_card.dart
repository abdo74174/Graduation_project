import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';

class StatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const StatsCard({required this.stats, super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final VoidCallback? onTap = stat['onTap'];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(stat['icon'], size: 40, color: stat['color']),
                  const SizedBox(height: 8),
                  Text(
                    stat['title'],
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: pkColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['value'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
