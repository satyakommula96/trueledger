import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class TrendChart extends StatelessWidget {
  final List<FinancialTrend> trendData;
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

    final maxValSpend =
        (trendData.map((e) => e.spending).reduce((a, b) => a > b ? a : b));
    final maxValIncome =
        (trendData.map((e) => e.income).reduce((a, b) => a > b ? a : b));
    final maxVal =
        (maxValSpend > maxValIncome ? maxValSpend : maxValIncome) * 1.2;

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.trends,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: semantic.secondaryText,
                  letterSpacing: 1.5,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    _buildLegendItem(
                        semantic.income, l10n.income.toUpperCase()),
                    const SizedBox(width: 16),
                    _buildLegendItem(semantic.overspent, l10n.spending),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            padding: const EdgeInsets.only(right: 0),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxY: maxVal,
                maxX: (trendData.length - 1).toDouble(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => semantic.surfaceCombined,
                    tooltipBorderRadius: BorderRadius.circular(12),
                    tooltipBorder: BorderSide(color: semantic.divider),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isIncome = barSpot.barIndex == 0;
                        return LineTooltipItem(
                          CurrencyFormatter.format(barSpot.y,
                              isPrivate: isPrivate),
                          TextStyle(
                            color:
                                isIncome ? semantic.income : semantic.overspent,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 3,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: semantic.divider.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
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
                        String monthStr = trendData[index].month.split('-')[1];
                        final months = [
                          l10n.janShort,
                          l10n.febShort,
                          l10n.marShort,
                          l10n.aprShort,
                          l10n.mayShort,
                          l10n.junShort,
                          l10n.julShort,
                          l10n.augShort,
                          l10n.sepShort,
                          l10n.octShort,
                          l10n.novShort,
                          l10n.decShort
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[int.parse(monthStr) - 1],
                            style: TextStyle(
                              color: semantic.secondaryText,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trendData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.income);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: semantic.income,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: semantic.income,
                        strokeWidth: 2,
                        strokeColor: semantic.surfaceCombined,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: trendData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.spending);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: semantic.overspent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: semantic.overspent,
                        strokeWidth: 2,
                        strokeColor: semantic.surfaceCombined,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          semantic.overspent.withValues(alpha: 0.15),
                          semantic.overspent.withValues(alpha: 0.0),
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
        begin: const Offset(0.98, 0.98),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: semantic.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
