import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class MonthlyHistoryScreen extends ConsumerStatefulWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  ConsumerState<MonthlyHistoryScreen> createState() =>
      _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends ConsumerState<MonthlyHistoryScreen> {
  List<Map<String, dynamic>> monthSummaries = [];
  List<int> availableYears = [];
  int selectedYear = DateTime.now().year;
  bool _isLoading = true;

  Future<void> load() async {
    final repo = ref.read(financialRepositoryProvider);

    if (availableYears.isEmpty) {
      final years = await repo.getAvailableYears();
      if (mounted) {
        setState(() {
          availableYears = years;
          if (years.isNotEmpty && !years.contains(selectedYear)) {
            selectedYear = years.first;
          }
        });
      }
    }

    final summaries = await repo.getMonthlyHistory(selectedYear);
    if (mounted) {
      setState(() {
        monthSummaries = summaries;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isPrivate = ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("LEDGER HISTORY"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (availableYears.isNotEmpty) _buildYearSelector(semantic),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: semantic.primary))
                : _buildHistoryList(semantic, isPrivate),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(AppColors semantic) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        scrollDirection: Axis.horizontal,
        itemCount: availableYears.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final year = availableYears[index];
          final isSelected = year == selectedYear;
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() {
                  selectedYear = year;
                  _isLoading = true;
                });
                load();
              }
            },
            child: AnimatedContainer(
              duration: 400.ms,
              curve: Curves.easeOutQuart,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? semantic.primary
                    : semantic.surfaceCombined.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.transparent : semantic.divider,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: semantic.primary.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                "$year",
                style: TextStyle(
                  color: isSelected ? Colors.white : semantic.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(AppColors semantic, bool isPrivate) {
    if (monthSummaries.isEmpty) {
      return Center(
        child: Text(
          "NO PERIODS TRACKED.",
          style: TextStyle(
            color: semantic.secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 24 + MediaQuery.of(context).padding.bottom),
      itemCount: monthSummaries.length,
      itemBuilder: (_, i) {
        final s = monthSummaries[i];
        final netValue = (s['net'] as num? ?? 0).toInt();
        final income = (s['income'] as num? ?? 0).toInt();
        final expenses = (s['expenses'] as num? ?? 0).toInt();
        final invested = (s['invested'] as num? ?? 0).toInt();
        final positive = netValue >= 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HoverWrapper(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthDetailScreen(month: s['month']),
                ),
              );
              load();
            },
            borderRadius: 28,
            glowColor: positive ? semantic.income : semantic.overspent,
            glowOpacity: 0.05,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: semantic.divider, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              (positive ? semantic.income : semantic.overspent)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          positive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color:
                              positive ? semantic.income : semantic.overspent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatMonth(s['month']),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: semantic.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              positive ? "SURPLUS PERIOD" : "DEFICIT PERIOD",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: (positive
                                        ? semantic.income
                                        : semantic.overspent)
                                    .withValues(alpha: 0.7),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(netValue,
                              isPrivate: isPrivate),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color:
                                positive ? semantic.income : semantic.overspent,
                            fontSize: 22,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          semantic.divider.withValues(alpha: 0),
                          semantic.divider,
                          semantic.divider.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          "INCOME",
                          CurrencyFormatter.format(income,
                              isPrivate: isPrivate),
                          Icons.arrow_downward_rounded,
                          semantic.income,
                          semantic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatItem(
                          "SPENDING",
                          CurrencyFormatter.format(expenses,
                              isPrivate: isPrivate),
                          Icons.arrow_upward_rounded,
                          semantic.overspent,
                          semantic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatItem(
                          "INVESTED",
                          CurrencyFormatter.format(invested,
                              isPrivate: isPrivate),
                          Icons.account_balance_rounded,
                          semantic.primary,
                          semantic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: (80 * i).clamp(0, 400).ms,
              duration: 600.ms,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              curve: Curves.easeOutQuart,
            );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color,
      AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: semantic.secondaryText,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: semantic.text,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  String _formatMonth(String yyyyMm) {
    try {
      final date = DateTime.parse('$yyyyMm-01');
      return DateFormat('MMMM yyyy').format(date).toUpperCase();
    } catch (e) {
      return yyyyMm;
    }
  }
}
