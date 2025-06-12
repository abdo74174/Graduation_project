import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SalesOverviewCard extends StatelessWidget {
  final double totalRevenue;
  final List<MonthlyRevenue> monthlyData; // Unused but kept for compatibility

  const SalesOverviewCard({
    required this.totalRevenue,
    required this.monthlyData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: 'EGP');
    final theme = Theme.of(context);

    // Calculate financial metrics for the current month
    final commission = totalRevenue * 0.04; // 4% commission rate
    final grossProfit = totalRevenue - commission;
    final currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    // Data for the bar chart as List<Map<String, Object>>
    final List<Map<String, Object>> barData = [
      {'title': 'Revenue'.tr(), 'value': totalRevenue, 'color': Colors.blue},
      {'title': 'Commission'.tr(), 'value': commission, 'color': Colors.orange},
      {
        'title': 'Gross Profit'.tr(),
        'value': grossProfit,
        'color': Colors.green
      },
    ];

    // Debug print to verify data
    print('Bar Data: $barData');

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Total Revenue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Overview - $currentMonth'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Revenue'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(totalRevenue),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Bar Chart
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.black87,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipBorder: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${barData[groupIndex]['title'] as String}\n${formatter.format(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < barData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                barData[value.toInt()]['title']
                                    as String, // Cast to String
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateYAxisInterval(barData),
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              formatter
                                  .format(value)
                                  .replaceAll('.00', '')
                                  .replaceAll('EGP', ''),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateYAxisInterval(barData),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  minY: 0,
                  maxY: _calculateMaxY(barData),
                  barGroups: barData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['value'] as double,
                          color: data['color'] as Color,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: _calculateMaxY(barData),
                            color: Colors.grey[100]!,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<Map<String, Object>> data) {
    final maxValue =
        data.map((d) => d['value'] as double).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.3)
        .ceilToDouble(); // Add 30% padding for better visuals
  }

  double _calculateYAxisInterval(List<Map<String, Object>> data) {
    final maxY = _calculateMaxY(data);
    return (maxY / 5).ceilToDouble(); // Show 5 intervals
  }
}

class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue(this.month, this.revenue);
}
