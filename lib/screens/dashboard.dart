import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../logic/financial_repository.dart';
import '../logic/monthly_calc.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'add_budget.dart';
import 'dashboard_components/asset_liability_card.dart';
import 'dashboard_components/borrowing_summary.dart';
import 'dashboard_components/budget_section.dart';
import 'dashboard_components/dashboard_bottom_bar.dart';
import 'dashboard_components/dashboard_header.dart';
import 'dashboard_components/section_header.dart';
import 'dashboard_components/summary_card.dart';
import 'dashboard_components/trend_chart.dart';
import 'dashboard_components/upcoming_bills.dart';
import 'dashboard_components/wealth_hero.dart';
import 'loans.dart';
import 'subscriptions.dart';

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
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    WealthHero(summary: summary!),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: SummaryCard(
                          label: "Income",
                          value: "₹${NumberFormat.compact(locale: 'en_IN').format(summary!.totalIncome)}",
                          valueColor: semantic.income,
                          semantic: semantic,
                          icon: Icons.arrow_downward
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: SummaryCard(
                          label: "Expenses",
                          value: "₹${NumberFormat.compact(locale: 'en_IN').format(summary!.totalFixed + summary!.totalVariable + summary!.totalSubscriptions)}",
                          valueColor: semantic.overspent,
                          semantic: semantic,
                          icon: Icons.arrow_upward
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FullWidthSummaryCard(
                      label: "Net Balance",
                      value: "₹${summary!.net}",
                      valueColor: summary!.net >= 0 ? semantic.income : semantic.warning,
                      semantic: semantic
                    ),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: "Financial Overview",
                      sub: "Assets vs Liabilities",
                      semantic: semantic
                    ),
                    const SizedBox(height: 16),
                    AssetLiabilityCard(summary: summary!, semantic: semantic),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: "Borrowings",
                      sub: "Active loans & debts",
                      semantic: semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())); load(); }
                    ),
                    const SizedBox(height: 16),
                    BorrowingSummary(summary: summary!, semantic: semantic, onLoad: load),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: "Spending Trend",
                      sub: "6-month activity",
                      semantic: semantic
                    ),
                    const SizedBox(height: 24),
                    TrendChart(trendData: trendData, semantic: semantic),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: "Active Budgets",
                      sub: "Target monitoring",
                      semantic: semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen())); load(); }
                    ),
                    const SizedBox(height: 16),
                    BudgetSection(budgets: budgets, semantic: semantic, onLoad: load),
                    const SizedBox(height: 32),
                    SectionHeader(
                      title: "Obligations",
                      sub: "Bills and recurring",
                      semantic: semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())); load(); }
                    ),
                    const SizedBox(height: 16),
                    UpcomingBills(bills: upcomingBills, semantic: semantic),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}