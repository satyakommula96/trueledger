import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:truecash/core/theme/theme.dart';

class TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final AppColors semantic;

  const TrendChart({
    super.key,
    required this.trendData,
    required this.semantic,
  });

  double _forecastNext(List<double> values) {
    if (values.isEmpty) return 0;
    if (values.length == 1) return values.first;
    int n = values.length;
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;
    double result = slope * n + intercept;
    return double.parse(result.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final maxVal = (trendData
        .map((e) => e['total'] as num)
        .reduce((a, b) => a > b ? a : b)).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        height: 180,
        padding: const EdgeInsets.only(right: 12),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (trendData.length).toDouble(),
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
                        if (index == trendData.length) {
                          return const Text("FCST",
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.bold));
                        }
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
              LineChartBarData(
                spots: [
                  FlSpot((trendData.length - 1).toDouble(),
                      (trendData.last['total'] as num).toDouble()),
                  FlSpot(
                      trendData.length.toDouble(),
                      _forecastNext(trendData
                          .map((e) => (e['total'] as num).toDouble())
                          .toList()))
                ],
                isCurved: true,
                color: semantic.warning,
                barWidth: 3,
                dashArray: [5, 5],
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
          duration:
              const Duration(milliseconds: 1000), // Built-in FL Chart animation
          curve: Curves.easeOutQuart,
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        curve: Curves.easeOutBack);
  }
}
