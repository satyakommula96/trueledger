import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class MonthlyHistoryScreen extends ConsumerStatefulWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  ConsumerState<MonthlyHistoryScreen> createState() =>
      _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends ConsumerState<MonthlyHistoryScreen> {
  List<FinancialTrend> monthSummaries = [];
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
    final l10n = AppLocalizations.of(context)!;

    return AppleScaffold(
      title: l10n.monthlyHistory,
      subtitle: "$selectedYear ARCHIVE",
      slivers: [
        if (availableYears.isNotEmpty)
          SliverToBoxAdapter(child: _buildYearSelector(semantic)),
        if (_isLoading)
          SliverFillRemaining(
            child: Center(
                child: CircularProgressIndicator(color: semantic.primary)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildHistoryListSliver(semantic, isPrivate, l10n),
          ),
      ],
    );
  }

  Widget _buildYearSelector(AppColors semantic) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        scrollDirection: Axis.horizontal,
        itemCount: availableYears.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? semantic.primary
                    : semantic.surfaceCombined.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : semantic.divider.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "$year",
                style: TextStyle(
                  color: isSelected ? Colors.white : semantic.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryListSliver(
      AppColors semantic, bool isPrivate, AppLocalizations l10n) {
    if (monthSummaries.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            "NO PERIODS TRACKED.",
            style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final s = monthSummaries[i];
          final positive = s.net >= 0;

          return AppleGlassCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MonthDetailScreen(month: s.month)),
                    );
                    load();
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              (positive ? semantic.income : semantic.overspent)
                                  .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          positive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color:
                              positive ? semantic.income : semantic.overspent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatMonth(s.month),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: semantic.text,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              positive ? "SURPLUS" : "DEFICIT",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: (positive
                                        ? semantic.income
                                        : semantic.overspent)
                                    .withValues(alpha: 0.7),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(s.net, isPrivate: isPrivate),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color:
                              positive ? semantic.income : semantic.overspent,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                    height: 1, color: semantic.divider.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(l10n.income.toUpperCase(), s.income,
                        semantic.income, isPrivate, semantic),
                    _buildStatItem(l10n.spending.toUpperCase(), s.spending,
                        semantic.overspent, isPrivate, semantic),
                    _buildStatItem(l10n.invested.toUpperCase(), s.invested,
                        semantic.primary, isPrivate, semantic),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (20 * i).ms).slideY(begin: 0.1, end: 0);
        },
        childCount: monthSummaries.length,
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color, bool isPrivate,
      AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: semantic.secondaryText,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(value, isPrivate: isPrivate),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: semantic.text,
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
