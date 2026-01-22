import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/theme.dart';

class TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final AppColors semantic;

  const TrendChart({
    super.key,
    required this.trendData,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final maxVal = (trendData
        .map((e) => e['total'] as num)
        .reduce((a, b) => a > b ? a : b)).toDouble();
    return Container(
      height: 160,
      padding: const EdgeInsets.only(right: 12),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (trendData.length - 1).toDouble(),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal / 2,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: semantic.divider, strokeWidth: 1)),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= trendData.length) {
                        return const SizedBox();
                      }
                      String month =
                          trendData[index]['month'].toString().split('-')[1];
                      const months = [
                        'JAN',
                        'FEB',
                        'MAR',
                        'APR',
                        'MAY',
                        'JUN',
                        'JUL',
                        'AUG',
                        'SEP',
                        'OCT',
                        'NOV',
                        'DEC'
                      ];
                      return Text(months[int.parse(month) - 1],
                          style: TextStyle(
                              color: semantic.secondaryText,
                              fontSize: 9,
                              fontWeight: FontWeight.bold));
                    })),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trendData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                      e.key.toDouble(), (e.value['total'] as num).toDouble()))
                  .toList(),
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.primary.withValues(alpha: 0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
