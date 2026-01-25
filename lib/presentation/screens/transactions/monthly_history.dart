import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/presentation/screens/transactions/month_detail.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    // Lazy load years if empty
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
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text("LEDGER HISTORY")),
      body: Column(
        children: [
          // Modern Year Selector
          if (availableYears.isNotEmpty)
            SizedBox(
              height: 68,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuint,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : semantic.divider),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$year",
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : monthSummaries.isEmpty
                    ? Center(
                        child: Text("NO PERIODS TRACKED.",
                            style: TextStyle(
                                color: semantic.secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(24, 8, 24,
                            24 + MediaQuery.of(context).padding.bottom),
                        itemCount: monthSummaries.length,
                        itemBuilder: (_, i) {
                          final s = monthSummaries[i];
                          final positive = s['net'] >= 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: semantic.divider)),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MonthDetailScreen(
                                            month: s['month'])));
                                load();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_formatMonth(s['month']),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                  letterSpacing: -0.5,
                                                  color:
                                                      colorScheme.onSurface)),
                                          Text(
                                              CurrencyFormatter.format(
                                                  s['net']),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: positive
                                                      ? semantic.income
                                                      : semantic.warning,
                                                  fontSize: 16)),
                                        ]),
                                    const SizedBox(height: 20),
                                    Divider(height: 1, color: semantic.divider),
                                    const SizedBox(height: 20),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildStatItem(
                                              "INCOME",
                                              CurrencyFormatter.format(
                                                  s['income']),
                                              semantic),
                                          _buildStatItem(
                                              "EXPENDITURE",
                                              CurrencyFormatter.format(
                                                  s['expenses']),
                                              semantic),
                                          _buildStatItem(
                                              "INVESTED",
                                              CurrencyFormatter.format(
                                                  s['invested']),
                                              semantic),
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                  delay: (100 * i).clamp(0, 500).ms,
                                  duration: 600.ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  curve: Curves.easeOutQuint);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, AppColors semantic) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: semantic.secondaryText,
              letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    ]);
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
