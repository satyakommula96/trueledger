import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../logic/financial_repository.dart';
import '../logic/monthly_calc.dart';
import '../logic/currency_helper.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'dashboard_components/asset_liability_card.dart';
import 'dashboard_components/dashboard_bottom_bar.dart';
import 'dashboard_components/dashboard_header.dart';
import 'dashboard_components/section_header.dart';
import 'dashboard_components/summary_card.dart';
import 'dashboard_components/payment_calendar.dart';
import 'dashboard_components/wealth_hero.dart';
import 'dashboard_components/smart_insights.dart';
import 'dashboard_components/health_meter.dart';
import '../logic/intelligence_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  MonthlySummary? summary;
  List<Map<String, dynamic>> categorySpending = [];
  List<Budget> budgets = [];
  List<SavingGoal> savingGoals = [];
  List<Map<String, dynamic>> trendData = [];
  List<Map<String, dynamic>> upcomingBills = [];

  final _repo = FinancialRepository();

  Future<void> load() async {
    try {
      final results = await Future.wait([
        _repo.getMonthlySummary(),
        _repo.getCategorySpending(),
        _repo.getBudgets(),
        _repo.getSavingGoals(),
        _repo.getSpendingTrend(),
        _repo.getUpcomingBills(),
      ]);

      if (mounted) {
        setState(() {
          summary = results[0] as MonthlySummary;
          categorySpending = results[1] as List<Map<String, dynamic>>;
          budgets = results[2] as List<Budget>;
          savingGoals = results[3] as List<SavingGoal>;
          trendData = results[4] as List<Map<String, dynamic>>;
          upcomingBills = results[5] as List<Map<String, dynamic>>;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint("Error loading dashboard data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load data: $e")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
        valueListenable: CurrencyHelper.currencyNotifier,
        builder: (context, currency, _) {
          return Scaffold(
            extendBody: true,
            bottomNavigationBar: DashboardBottomBar(onLoad: load),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: load,
                color: colorScheme.primary,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    DashboardHeader(isDark: isDark, onLoad: load),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          WealthHero(summary: summary!)
                              .animate()
                              .fade(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                          const SizedBox(height: 24),
                          HealthMeter(
                            score: IntelligenceService.calculateHealthScore(
                              summary: summary!,
                              budgets: budgets,
                            ),
                            semantic: semantic,
                          )
                              .animate(delay: 100.ms)
                              .fade(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                  child: SummaryCard(
                                      label: "Income",
                                      value: CurrencyHelper.format(
                                          summary!.totalIncome),
                                      valueColor: semantic.income,
                                      semantic: semantic,
                                      icon: Icons.arrow_downward)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: SummaryCard(
                                      label: "Expenses",
                                      value: CurrencyHelper.format(
                                          summary!.totalFixed +
                                              summary!.totalVariable +
                                              summary!.totalSubscriptions),
                                      valueColor: semantic.overspent,
                                      semantic: semantic,
                                      icon: Icons.arrow_upward)),
                            ],
                          )
                              .animate(delay: 200.ms)
                              .fade(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                          const SizedBox(height: 32),
                          SectionHeader(
                                  title: "Financial Overview",
                                  sub: "Assets vs Liabilities",
                                  semantic: semantic)
                              .animate(delay: 300.ms)
                              .fade(duration: 600.ms),
                          const SizedBox(height: 16),
                          AssetLiabilityCard(
                                  summary: summary!,
                                  semantic: semantic,
                                  onLoad: load)
                              .animate(delay: 400.ms)
                              .fade(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                          const SizedBox(height: 32),
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
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                          const SizedBox(height: 32),
                          SmartInsightsCard(
                            insights: IntelligenceService.generateInsights(
                              summary: summary!,
                              trendData: trendData,
                              budgets: budgets,
                            ),
                            semantic: semantic,
                          )
                              .animate(delay: 700.ms)
                              .fade(duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
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
  }
}
