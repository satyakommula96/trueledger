import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/budget_section.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/trend_chart.dart';
import 'package:trueledger/presentation/screens/budget/add_budget.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/presentation/screens/analysis/annual_reflection_screen.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(analysisProvider);
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;

    return analysisAsync.when(
      loading: () => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: Center(child: CircularProgressIndicator(color: semantic.primary)),
      ),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (data) {
        final budgets = data.budgets;
        final trendData = data.trendData;
        final categoryData = data.categoryData;

        void reload() {
          ref.invalidate(analysisProvider);
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("ANALYSIS"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddBudgetScreen()));
              reload();
            },
            backgroundColor: semantic.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            child: const Icon(Icons.add_rounded, size: 28),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 80, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trendData.length >= 2) ...[
                  _buildInsightCard(context, trendData, semantic, isPrivate)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 32),
                ],
                _buildAnnualReflectionBanner(context, semantic)
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 48),
                _buildSectionHeader(
                    semantic, "MONTHLY TREND", "SPENDING & INCOME"),
                const SizedBox(height: 20),
                TrendChart(
                        trendData: trendData,
                        semantic: semantic,
                        isPrivate: isPrivate)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 48),
                _buildSectionHeader(semantic, "DISTRIBUTION", "BY CATEGORY"),
                const SizedBox(height: 24),
                _buildCategoryBreakdown(
                    context, categoryData, semantic, isPrivate),
                const SizedBox(height: 48),
                _buildSectionHeader(semantic, "BUDGETS", "LIVE TRACKING"),
                const SizedBox(height: 24),
                BudgetSection(
                        budgets: budgets, semantic: semantic, onLoad: reload)
                    .animate()
                    .fadeIn(delay: 600.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(AppColors semantic, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sub.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              color: semantic.secondaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context,
      List<Map<String, dynamic>> data, AppColors semantic, bool isPrivate) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text("No spending data yet",
              style: TextStyle(
                  color: semantic.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );
    }

    final maxVal = data.fold<double>(
        0.0,
        (prev, e) => (e['total'] as num).toDouble() > prev
            ? (e['total'] as num).toDouble()
            : prev);

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final total = (item['total'] as num).toDouble();
        final progress = maxVal == 0 ? 0.0 : total / maxVal;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['category'].toString().toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: semantic.text,
                          letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.format(total, isPrivate: isPrivate),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: semantic.text),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: 800.ms,
                      curve: Curves.easeOutQuint,
                      height: 8,
                      width: constraints.maxWidth * progress.clamp(0.02, 1.0),
                      decoration: BoxDecoration(
                        color: semantic.primary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: semantic.primary.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ).animate().shimmer(
                        duration: 2.seconds,
                        color: semantic.primary.withValues(alpha: 0.2)),
                  ],
                );
              })
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (40 * index).ms)
            .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuint);
      }).toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context,
      List<Map<String, dynamic>> data, AppColors semantic, bool isPrivate) {
    if (data.length < 2) return const SizedBox();
    final current = (data.last['total'] as num).toDouble();
    final last = (data[data.length - 2]['total'] as num).toDouble();
    final diff = current - last;
    final isIncrease = diff > 0;

    return HoverWrapper(
      borderRadius: 24,
      glowColor: isIncrease ? semantic.overspent : semantic.income,
      glowOpacity: 0.1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (isIncrease ? semantic.overspent : semantic.income)
              .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: (isIncrease ? semantic.overspent : semantic.income)
                  .withValues(alpha: 0.2),
              width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isIncrease ? semantic.overspent : semantic.income)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIncrease
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: isIncrease ? semantic.overspent : semantic.income,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "INSIGHT",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: semantic.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: semantic.text,
                    height: 1.5),
                children: [
                  TextSpan(
                      text: isIncrease
                          ? "Spending is up by "
                          : "Great job! Spending decreased by "),
                  TextSpan(
                    text: CurrencyFormatter.format(diff.abs(),
                        isPrivate: isPrivate),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color:
                            isIncrease ? semantic.overspent : semantic.income),
                  ),
                  const TextSpan(text: " compared to last month."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnualReflectionBanner(
      BuildContext context, AppColors semantic) {
    return HoverWrapper(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AnnualReflectionScreen(year: DateTime.now().year)),
      ),
      borderRadius: 24,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  color: semantic.primary, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YEAR-IN-REVIEW",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: semantic.secondaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View your ${DateTime.now().year} reflection",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: semantic.text,
                        letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: semantic.secondaryText),
          ],
        ),
      ),
    ).animate().shimmer(
        delay: 1.seconds,
        duration: 2.seconds,
        color: semantic.primary.withValues(alpha: 0.15));
  }
}
