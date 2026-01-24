import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:truecash/presentation/providers/dashboard_provider.dart';
import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/presentation/screens/dashboard_components/asset_liability_card.dart';
import 'package:truecash/presentation/screens/dashboard_components/dashboard_bottom_bar.dart';
import 'package:truecash/presentation/screens/dashboard_components/dashboard_header.dart';
import 'package:truecash/presentation/screens/dashboard_components/section_header.dart';
import 'package:truecash/presentation/screens/dashboard_components/summary_card.dart';
import 'package:truecash/presentation/screens/dashboard_components/payment_calendar.dart';
import 'package:truecash/presentation/screens/dashboard_components/wealth_hero.dart';
import 'package:truecash/presentation/screens/dashboard_components/smart_insights.dart';
import 'package:truecash/presentation/screens/dashboard_components/health_meter.dart';
import 'package:truecash/domain/services/intelligence_service.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return dashboardAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Error: $err")),
      ),
      data: (data) {
        final summary = data.summary;
        final budgets = data.budgets;
        final upcomingBills = data.upcomingBills;
        final trendData = data.trendData;

        Future<void> reload() async {
          ref.invalidate(dashboardProvider);
        }

        return ValueListenableBuilder<String>(
            valueListenable: CurrencyHelper.currencyNotifier,
            builder: (context, currency, _) {
              return Scaffold(
                extendBody: true,
                bottomNavigationBar: DashboardBottomBar(onLoad: reload),
                body: SafeArea(
                  child: RefreshIndicator(
                    onRefresh: reload,
                    color: colorScheme.primary,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        DashboardHeader(isDark: isDark, onLoad: reload),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              WealthHero(summary: summary)
                                  .animate()
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 24),
                              HealthMeter(
                                score: IntelligenceService.calculateHealthScore(
                                  summary: summary,
                                  budgets: budgets,
                                ),
                                semantic: semantic,
                              )
                                  .animate(delay: 100.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                      child: SummaryCard(
                                          label: "Income",
                                          value: CurrencyHelper.format(
                                              summary.totalIncome),
                                          valueColor: semantic.income,
                                          semantic: semantic,
                                          icon: Icons.arrow_downward)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: SummaryCard(
                                          label: "Expenses",
                                          value: CurrencyHelper.format(
                                              summary.totalFixed +
                                                  summary.totalVariable +
                                                  summary.totalSubscriptions),
                                          valueColor: semantic.overspent,
                                          semantic: semantic,
                                          icon: Icons.arrow_upward)),
                                ],
                              )
                                  .animate(delay: 200.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 32),
                              SectionHeader(
                                      title: "Financial Overview",
                                      sub: "Assets vs Liabilities",
                                      semantic: semantic)
                                  .animate(delay: 300.ms)
                                  .fade(duration: 600.ms),
                              const SizedBox(height: 16),
                              AssetLiabilityCard(
                                      summary: summary,
                                      semantic: semantic,
                                      onLoad: reload)
                                  .animate(delay: 400.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 32),
                              SectionHeader(
                                      title: "Payment Calendar",
                                      sub: "Month view",
                                      semantic: semantic)
                                  .animate(delay: 500.ms)
                                  .fade(duration: 600.ms),
                              const SizedBox(height: 16),
                              PaymentCalendar(
                                      bills: upcomingBills, semantic: semantic)
                                  .animate(delay: 600.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 32),
                              SmartInsightsCard(
                                insights: IntelligenceService.generateInsights(
                                  summary: summary,
                                  trendData: trendData,
                                  budgets: budgets,
                                ),
                                semantic: semantic,
                              )
                                  .animate(delay: 700.ms)
                                  .fade(duration: 600.ms)
                                  .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOutQuint),
                              const SizedBox(height: 120),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
