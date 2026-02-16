import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/presentation/providers/analysis_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/trend_chart.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/screens/analysis/annual_reflection_screen.dart';
import 'package:trueledger/presentation/screens/retirement/retirement_dashboard.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/domain/models/models.dart';

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
      error: (err, stack) => Scaffold(
          body: Center(
              child:
                  Text(AppLocalizations.of(context)?.reset ?? "Error: $err"))),
      data: (data) {
        final l10n = AppLocalizations.of(context)!;
        final trendData = data.trendData;
        final categoryData = data.categoryData;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.analysis.toUpperCase()),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 80, 20, 100),
              child: isWide
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (trendData.length >= 2)
                              Expanded(
                                child: _buildInsightCard(
                                        context, trendData, semantic, isPrivate)
                                    .animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideY(
                                        begin: 0.1,
                                        end: 0,
                                        curve: Curves.easeOutQuint),
                              ),
                            if (trendData.length >= 2)
                              const SizedBox(width: 20),
                            Expanded(
                              child: _buildAnnualReflectionBanner(
                                      context, semantic, l10n)
                                  .animate()
                                  .fadeIn(delay: 200.ms),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildRetirementBanner(
                                      context, semantic, l10n)
                                  .animate()
                                  .fadeIn(delay: 300.ms),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      semantic,
                                      AppLocalizations.of(context)!
                                          .monthlyTrend,
                                      AppLocalizations.of(context)!
                                          .spendingAndIncome),
                                  const SizedBox(height: 20),
                                  TrendChart(
                                          trendData: trendData,
                                          semantic: semantic,
                                          isPrivate: isPrivate)
                                      .animate()
                                      .fadeIn(delay: 400.ms, duration: 600.ms)
                                      .slideY(
                                          begin: 0.05,
                                          end: 0,
                                          curve: Curves.easeOutQuint),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      semantic,
                                      AppLocalizations.of(context)!
                                          .distribution,
                                      AppLocalizations.of(context)!.byCategory),
                                  const SizedBox(height: 24),
                                  _buildCategoryBreakdown(context, categoryData,
                                      semantic, isPrivate, l10n),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trendData.length >= 2) ...[
                          _buildInsightCard(
                                  context, trendData, semantic, isPrivate)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                  begin: 0.1,
                                  end: 0,
                                  curve: Curves.easeOutQuint),
                          const SizedBox(height: 32),
                        ],
                        _buildAnnualReflectionBanner(context, semantic, l10n)
                            .animate()
                            .fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        _buildRetirementBanner(context, semantic, l10n)
                            .animate()
                            .fadeIn(delay: 300.ms),
                        const SizedBox(height: 48),
                        _buildSectionHeader(
                            semantic,
                            AppLocalizations.of(context)!.monthlyTrend,
                            AppLocalizations.of(context)!.spendingAndIncome),
                        const SizedBox(height: 20),
                        TrendChart(
                                trendData: trendData,
                                semantic: semantic,
                                isPrivate: isPrivate)
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideY(
                                begin: 0.05,
                                end: 0,
                                curve: Curves.easeOutQuint),
                        const SizedBox(height: 48),
                        _buildSectionHeader(
                            semantic,
                            AppLocalizations.of(context)!.distribution,
                            AppLocalizations.of(context)!.byCategory),
                        const SizedBox(height: 24),
                        _buildCategoryBreakdown(
                            context, categoryData, semantic, isPrivate, l10n),
                      ],
                    ),
            );
          }),
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
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: -1,
              height: 1),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context,
      List<CategorySpending> data,
      AppColors semantic,
      bool isPrivate,
      AppLocalizations l10n) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        alignment: Alignment.center,
        child: Text(l10n.noDataAvailable,
            style: TextStyle(
                color: semantic.secondaryText.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2)),
      );
    }

    final maxVal =
        data.fold<double>(0.0, (prev, e) => e.total > prev ? e.total : prev);

    return Column(
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final total = item.total;
        final progress = maxVal == 0 ? 0.0 : total / maxVal;

        return Container(
          margin: const EdgeInsets.only(bottom: 28),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: semantic.divider, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.category.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: semantic.text,
                          letterSpacing: 1),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.format(total, isPrivate: isPrivate),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: semantic.text,
                        letterSpacing: -0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: 1.seconds,
                      curve: Curves.easeOutExpo,
                      height: 10,
                      width: constraints.maxWidth * progress.clamp(0.02, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            semantic.primary,
                            semantic.primary.withValues(alpha: 0.6)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: semantic.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                    ).animate().shimmer(
                        duration: 3.seconds,
                        color: Colors.white.withValues(alpha: 0.1)),
                  ],
                );
              })
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (60 * index).ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
      }).toList(),
    );
  }

  Widget _buildInsightCard(BuildContext context, List<FinancialTrend> data,
      AppColors semantic, bool isPrivate) {
    if (data.length < 2) return const SizedBox();
    final current = data.last.total;
    final last = data[data.length - 2].total;
    final diff = current - last;
    final isIncrease = diff > 0;
    final color = isIncrease ? semantic.overspent : semantic.income;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isIncrease
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context)!.momentum.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: semantic.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: semantic.text,
                  height: 1.5,
                  letterSpacing: -0.3),
              children: [
                TextSpan(
                    text: isIncrease
                        ? AppLocalizations.of(context)!.velocityIncreased
                        : AppLocalizations.of(context)!.spendingDecreased),
                TextSpan(
                  text: CurrencyFormatter.format(diff.abs(),
                      isPrivate: isPrivate),
                  style: TextStyle(fontWeight: FontWeight.w900, color: color),
                ),
                TextSpan(
                    text: AppLocalizations.of(context)!.relativeToLastPeriod),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnualReflectionBanner(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AnnualReflectionScreen(year: DateTime.now().year)),
          ),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(28),
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
                        l10n.archiveLabel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: semantic.secondaryText),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.reflectionLabel(DateTime.now().year),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: semantic.text,
                            letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: semantic.divider, size: 20),
              ],
            ),
          ),
        ),
      ),
    ).animate().shimmer(
        delay: 2.seconds,
        duration: 2.seconds,
        color: semantic.primary.withValues(alpha: 0.1));
  }

  Widget _buildRetirementBanner(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: semantic.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: semantic.primary.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RetirementDashboard()),
          ),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.security_rounded,
                      color: semantic.primary, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.goalTracking,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: semantic.secondaryText),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.retirementHealth,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: semantic.text,
                            letterSpacing: -0.5),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: semantic.divider, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
