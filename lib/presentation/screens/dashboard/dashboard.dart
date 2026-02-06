import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/config/app_config.dart';

import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/insights_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
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
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_summary.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/weekly_summary.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_bottom_sheet.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/daily_closure_card.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/presentation/screens/dashboard/weekly_reflection.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail.dart';
import 'package:trueledger/presentation/screens/transactions/transactions_detail.dart';
import 'package:trueledger/presentation/screens/transactions/monthly_history.dart';
import 'package:trueledger/presentation/components/error_view.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/onboarding_cards.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';

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
        body: AppErrorView(
          error: err,
          stackTrace: stack,
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
      ),
      data: (data) {
        final summary = data.summary;
        final budgets = data.budgets;
        final upcomingBills = data.upcomingBills;
        // final trendData = data.trendData; // Unused

        Future<void> reload() async {
          debugPrint("Dashboard: Reloading data...");
          try {
            // Force refresh the provider
            final _ = await ref.refresh(dashboardProvider.future);
            ref.invalidate(pendingNotificationsProvider);
            ref.invalidate(pendingNotificationCountProvider);
            debugPrint("Dashboard: Data reloaded successfully.");
          } catch (e, stack) {
            debugPrint("Dashboard: Reload failed: $e");
            if (kDebugMode) {
              throw Exception("Dashboard reload failed: $e\n$stack");
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to refresh dashboard")),
              );
            }
          }
        }

        final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

        return ValueListenableBuilder<String>(
            valueListenable: CurrencyFormatter.currencyNotifier,
            builder: (context, currency, _) {
              return Scaffold(
                extendBody: true,
                backgroundColor: semantic.surfaceCombined,
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    final added = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const QuickAddBottomSheet(),
                    );
                    if (added == true) {
                      reload();
                    }
                  },
                  backgroundColor: semantic.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: const Icon(Icons.add_rounded, size: 32),
                ),
                bottomNavigationBar: DashboardBottomBar(onLoad: reload),
                body: Stack(
                  children: [
                    // Persistent Background Mesh Effects
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              semantic.primary.withValues(alpha: 0.05),
                              semantic.primary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ).animate(onPlay: (c) {
                        if (!AppConfig.isTest) c.repeat(reverse: true);
                      }).move(duration: 10.seconds, end: const Offset(-40, 40)),
                    ),
                    Positioned(
                      bottom: 100,
                      left: -150,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              colorScheme.secondary.withValues(alpha: 0.03),
                              colorScheme.secondary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ).animate(onPlay: (c) {
                        if (!AppConfig.isTest) c.repeat(reverse: true);
                      }).move(duration: 12.seconds, end: const Offset(50, -30)),
                    ),
                    SafeArea(
                      child: RefreshIndicator(
                        onRefresh: reload,
                        color: semantic.primary,
                        backgroundColor: semantic.surfaceCombined,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            DashboardHeader(isDark: isDark, onLoad: reload),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  if (data.billsDueToday.isNotEmpty)
                                    ...(() {
                                      final billsToday = data.billsDueToday;
                                      final total = billsToday.fold(
                                          0, (sum, b) => sum + b.amount);

                                      return [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: semantic.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: semantic.primary
                                                    .withValues(alpha: 0.2),
                                                width: 1.5),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .notification_important_rounded,
                                                  size: 20,
                                                  color: semantic.primary),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  "${billsToday.length} ${billsToday.length == 1 ? 'BILL' : 'BILLS'} DUE TODAY · ${CurrencyFormatter.format(total)}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w900,
                                                    color: semantic.primary,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ),
                                              Icon(Icons.chevron_right_rounded,
                                                  size: 18,
                                                  color: semantic.primary
                                                      .withValues(alpha: 0.5)),
                                            ],
                                          ),
                                        )
                                            .animate()
                                            .fadeIn()
                                            .slideY(begin: 0.1, end: 0),
                                        const SizedBox(height: 8),
                                      ];
                                    })(),
                                  WealthHero(
                                    summary: summary,
                                    activeStreak: data.activeStreak,
                                    hasLoggedToday: data.todaySpend > 0,
                                    onTapStreak: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const MonthlyHistoryScreen()));
                                    },
                                  ).animate().fade(duration: 800.ms).slideY(
                                      begin: 0.1,
                                      end: 0,
                                      curve: Curves.easeOutQuart),
                                  const SizedBox(height: 24),
                                  if (summary.totalIncome == 0 &&
                                      (summary.totalFixed +
                                              summary.totalVariable) ==
                                          0) ...[
                                    OnboardingActionCards(
                                      semantic: semantic,
                                      onAddTransaction: () async {
                                        final added =
                                            await showModalBottomSheet<bool>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              const QuickAddBottomSheet(),
                                        );
                                        if (added == true) reload();
                                      },
                                      onAddBudget: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AnalysisScreen()));
                                      },
                                      onCheckAnalysis: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AnalysisScreen()));
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                  DailyClosureCard(
                                    transactionCount:
                                        data.todayTransactionCount,
                                    todaySpend: data.todaySpend,
                                    dailyBudget: data.budgets.isEmpty
                                        ? 0
                                        : (data.budgets.fold(
                                                    0,
                                                    (sum, b) =>
                                                        sum + b.monthlyLimit) /
                                                30)
                                            .round(),
                                    semantic: semantic,
                                  )
                                      .animate(delay: 200.ms)
                                      .fadeIn()
                                      .slideY(begin: 0.1, end: 0),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DailySummary(
                                            todaySpend: data.todaySpend,
                                            totalBudgetRemaining: data
                                                    .budgets.isEmpty
                                                ? null
                                                : data.budgets.fold(
                                                        0,
                                                        (sum, b) =>
                                                            sum +
                                                            b.monthlyLimit) -
                                                    data.budgets.fold(
                                                        0,
                                                        (sum, b) =>
                                                            sum + b.spent),
                                            semantic: semantic,
                                            onTap: () {
                                              final now = DateTime.now();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          TransactionsDetailScreen(
                                                            title:
                                                                "Today's Ledger",
                                                            startDate: now,
                                                            endDate: now,
                                                          )));
                                            }),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: WeeklySummary(
                                            thisWeekSpend: data.thisWeekSpend,
                                            lastWeekSpend: data.lastWeekSpend,
                                            semantic: semantic,
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const WeeklyReflectionScreen()));
                                            }),
                                      ),
                                    ],
                                  )
                                      .animate(delay: 300.ms)
                                      .fade(duration: 800.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuart),
                                  const SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: SummaryCard(
                                              label: "Income",
                                              value: CurrencyFormatter.format(
                                                  summary.totalIncome,
                                                  isPrivate: ref
                                                      .watch(privacyProvider)),
                                              valueColor: semantic.income,
                                              semantic: semantic,
                                              icon: Icons.payments_rounded,
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            MonthDetailScreen(
                                                              month:
                                                                  currentMonth,
                                                              initialTypeFilter:
                                                                  'Income',
                                                              showFilters:
                                                                  false,
                                                            )));
                                              })),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: SummaryCard(
                                              label: "Expenses",
                                              value: CurrencyFormatter.format(
                                                  summary.totalFixed +
                                                      summary.totalVariable +
                                                      summary
                                                          .totalSubscriptions,
                                                  isPrivate: ref
                                                      .watch(privacyProvider)),
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
                                                              month:
                                                                  currentMonth,
                                                              initialTypeFilter:
                                                                  'Expenses',
                                                              showFilters:
                                                                  false,
                                                            )));
                                              })),
                                    ],
                                  )
                                      .animate(delay: 400.ms)
                                      .fade(duration: 800.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuart),
                                  const SizedBox(height: 32),
                                  SectionHeader(
                                          title: "Financial Overview",
                                          sub: "Assets vs Liabilities",
                                          semantic: semantic)
                                      .animate(delay: 500.ms)
                                      .fade(duration: 800.ms),
                                  const SizedBox(height: 16),
                                  AssetLiabilityCard(
                                          summary: summary,
                                          semantic: semantic,
                                          onLoad: reload)
                                      .animate(delay: 600.ms)
                                      .fade(duration: 800.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuart),
                                  const SizedBox(height: 32),
                                  SmartInsightsCard(
                                    insights: ref.watch(insightsProvider),
                                    score: IntelligenceService
                                        .calculateHealthScore(
                                      summary: summary,
                                      budgets: budgets,
                                    ),
                                    semantic: semantic,
                                  )
                                      .animate(delay: 700.ms)
                                      .fade(duration: 800.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuart),
                                  const SizedBox(height: 32),
                                  SectionHeader(
                                          title: "Payment Calendar",
                                          sub: "Month view",
                                          semantic: semantic)
                                      .animate(delay: 800.ms)
                                      .fade(duration: 800.ms),
                                  const SizedBox(height: 16),
                                  PaymentCalendar(
                                          bills: upcomingBills,
                                          semantic: semantic)
                                      .animate(delay: 900.ms)
                                      .fade(duration: 800.ms)
                                      .slideY(
                                          begin: 0.1,
                                          end: 0,
                                          curve: Curves.easeOutQuart),
                                  const SizedBox(height: 120),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}
