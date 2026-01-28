import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/asset_liability_card.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/dashboard_bottom_bar.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/dashboard_header.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/section_header.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/summary_card.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/payment_calendar.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/wealth_hero.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/smart_insights.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail.dart';

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

        final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

        return ValueListenableBuilder<String>(
            valueListenable: CurrencyFormatter.currencyNotifier,
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
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                      child: SummaryCard(
                                          label: "Income",
                                          value: CurrencyFormatter.format(
                                              summary.totalIncome,
                                              isPrivate:
                                                  ref.watch(privacyProvider)),
                                          valueColor: semantic.income,
                                          semantic: semantic,
                                          icon: Icons.payments_rounded,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        MonthDetailScreen(
                                                          month: currentMonth,
                                                          initialTypeFilter:
                                                              'Income',
                                                          showFilters: false,
                                                        )));
                                          })),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: SummaryCard(
                                          label: "Expenses",
                                          value: CurrencyFormatter.format(
                                              summary.totalFixed +
                                                  summary.totalVariable +
                                                  summary.totalSubscriptions,
                                              isPrivate:
                                                  ref.watch(privacyProvider)),
                                          valueColor: semantic.overspent,
                                          semantic: semantic,
                                          icon: Icons
                                              .shopping_cart_checkout_rounded,
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        MonthDetailScreen(
                                                          month: currentMonth,
                                                          initialTypeFilter:
                                                              'Expenses',
                                                          showFilters: false,
                                                        )));
                                          })),
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
                                score: IntelligenceService.calculateHealthScore(
                                  summary: summary,
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
