import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

class TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final AppColors semantic;
  final bool isPrivate;

  const TrendChart({
    super.key,
    required this.trendData,
    required this.semantic,
    required this.isPrivate,
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final maxValSpend = (trendData
        .map((e) => (e['spending'] ?? e['total']) as num)
        .reduce((a, b) => a > b ? a : b)).toDouble();
    final maxValIncome = (trendData
        .map((e) => (e['income'] ?? 0) as num)
        .reduce((a, b) => a > b ? a : b)).toDouble();
    final maxVal =
        (maxValSpend > maxValIncome ? maxValSpend : maxValIncome) * 1.2;

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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(semantic.income, "INCOME"),
              const SizedBox(width: 16),
              _buildLegendItem(semantic.overspent, "SPENDING"),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            padding: const EdgeInsets.only(right: 12),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxY: maxVal,
                maxX: (trendData.length - 1).toDouble(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isIncome = barSpot.barIndex == 0;
                        return LineTooltipItem(
                          "${isIncome ? 'Income' : 'Spend'}: ${CurrencyFormatter.format(barSpot.y, isPrivate: isPrivate)}",
                          TextStyle(
                              color: isIncome
                                  ? semantic.income
                                  : semantic.overspent,
                              fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxVal / 3,
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
                            String month = trendData[index]['month']
                                .toString()
                                .split('-')[1];
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
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: trendData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(),
                          (e.value['income'] as num? ?? 0).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: semantic.income,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Spending Line
                  LineChartBarData(
                    spots: trendData.asMap().entries.map((e) {
                      return FlSpot(
                          e.key.toDouble(),
                          (e.value['spending'] ?? e.value['total'] as num)
                              .toDouble());
                    }).toList(),
                    isCurved: true,
                    color: semantic.overspent,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          semantic.overspent.withValues(alpha: 0.2),
                          semantic.overspent.withValues(alpha: 0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutQuart,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        curve: Curves.easeOutBack);
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.8),
                letterSpacing: 1)),
      ],
    );
  }
}
