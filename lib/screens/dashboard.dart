import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../logic/financial_repository.dart';
import '../logic/monthly_calc.dart';
import '../main.dart'; 
import '../theme/theme.dart';
import 'add_expense.dart';
import 'credit_cards.dart';
import 'monthly_history.dart';
import 'settings.dart';
import 'edit_budget.dart';
import 'add_budget.dart';
import 'subscriptions.dart';
import 'loans.dart';

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
      bottomNavigationBar: _buildBottomBar(context, semantic),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(isDark, colorScheme, semantic),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWealthHero(colorScheme, semantic),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildSummaryCard("Income", "₹${NumberFormat.compact().format(summary!.totalIncome)}", semantic.income, semantic, Icons.arrow_downward)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard("Expenses", "₹${NumberFormat.compact().format(summary!.totalFixed + summary!.totalVariable + summary!.totalSubscriptions)}", semantic.overspent, semantic, Icons.arrow_upward)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFullWidthSummaryCard("Net Balance", "₹${summary!.net}", summary!.net >= 0 ? semantic.income : semantic.warning, semantic),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Financial Overview", "Assets vs Liabilities", semantic),
                    const SizedBox(height: 16),
                    _buildAssetLiabilityCard(colorScheme, semantic),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Borrowings", "Active loans & debts", semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())); load(); }),
                    const SizedBox(height: 16),
                    _buildBorrowingSummary(colorScheme, semantic),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Spending Trend", "6-month activity", semantic),
                    const SizedBox(height: 24),
                    _buildTrendChart(colorScheme, semantic),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Active Budgets", "Target monitoring", semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBudgetScreen())); load(); }),
                    const SizedBox(height: 16),
                    _buildBudgetSection(colorScheme, semantic),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Obligations", "Bills and recurring", semantic, 
                      onAdd: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())); load(); }),
                    const SizedBox(height: 16),
                    _buildUpcomingBills(colorScheme, semantic),
                    const SizedBox(height: 64),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color valueColor, AppColors semantic, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: semantic.secondaryText, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Icon(icon, size: 16, color: semantic.secondaryText.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildFullWidthSummaryCard(String label, String value, Color valueColor, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: semantic.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 12, color: semantic.secondaryText, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildWealthHero(ColorScheme colorScheme, AppColors semantic) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.account_balance_wallet, size: 200, color: Colors.white.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 14, color: colorScheme.onPrimary.withOpacity(0.8)),
                          const SizedBox(width: 6),
                          Text("TOTAL NET WORTH", style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.9), fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz, color: colorScheme.onPrimary.withOpacity(0.6)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("₹${NumberFormat('#,##,##0').format(summary!.netWorth)}", style: TextStyle(color: colorScheme.onPrimary, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.0)),
                    const SizedBox(height: 8),
                    Text("AFTER LIABILITIES", style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetLiabilityCard(ColorScheme colorScheme, AppColors semantic) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: semantic.income.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: semantic.income.withOpacity(0.2))),
            child: _buildMiniStat("TOTAL ASSETS", "₹${NumberFormat.compact().format(summary!.netWorth + summary!.creditCardDebt + summary!.loansTotal)}", semantic.income, semantic),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: semantic.overspent.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: semantic.overspent.withOpacity(0.2))),
            child: _buildMiniStat("LIABILITIES", "₹${NumberFormat.compact().format(summary!.creditCardDebt + summary!.loansTotal)}", semantic.overspent, semantic),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String val, Color color, AppColors semantic) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: semantic.secondaryText, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    ]);
  }

  Widget _buildBorrowingSummary(ColorScheme colorScheme, AppColors semantic) {
    return InkWell(
      onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())); load(); },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: semantic.divider)),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("REMAINING DEBT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: semantic.secondaryText, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text("₹${summary!.loansTotal}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: semantic.overspent)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(ColorScheme colorScheme, AppColors semantic) {
    if (trendData.isEmpty) return const SizedBox.shrink();
    final maxVal = (trendData.map((e) => e['total'] as num).reduce((a, b) => a > b ? a : b)).toDouble();
    return Container(
      height: 160,
      padding: const EdgeInsets.only(right: 12),
      child: LineChart(
        LineChartData(
          minX: 0, maxX: (trendData.length - 1).toDouble(),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxVal / 2, getDrawingHorizontalLine: (v) => FlLine(color: semantic.divider, strokeWidth: 1)),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24, interval: 1, getTitlesWidget: (value, meta) {
              int index = value.toInt(); if (index < 0 || index >= trendData.length) return const SizedBox();
              String month = trendData[index]['month'].toString().split('-')[1];
              const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
              return Text(months[int.parse(month) - 1], style: TextStyle(color: semantic.secondaryText, fontSize: 9, fontWeight: FontWeight.bold));
            })),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trendData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['total'] as num).toDouble())).toList(),
              isCurved: true,
              color: colorScheme.primary, barWidth: 3, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withOpacity(0.3), colorScheme.primary.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBills(ColorScheme colorScheme, AppColors semantic) {
    if (upcomingBills.isEmpty) return const Text("Clean slate", style: TextStyle(color: Colors.grey, fontSize: 12));
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: upcomingBills.map((b) => Container(width: 150, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: semantic.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b['type'].toString(), style: TextStyle(fontSize: 8, color: semantic.secondaryText, fontWeight: FontWeight.w900, letterSpacing: 0.5)), const SizedBox(height: 4), Text(b['title'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis), const SizedBox(height: 12), Text("₹${b['amount']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), Text(b['due'].toString(), style: TextStyle(fontSize: 9, color: semantic.secondaryText))]))).toList()));
  }

  Widget _buildHeader(bool isDark, ColorScheme colorScheme, AppColors semantic) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TrueCash", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                    Text("Your Financial Outlook", style: TextStyle(fontSize: 12, color: semantic.secondaryText, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 22, color: colorScheme.onSurface),
                  onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined, size: 22, color: colorScheme.onSurface),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    load();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection(ColorScheme colorScheme, AppColors semantic) {
    return Column(children: budgets.map((b) {
      final double progress = (b.spent / b.monthlyLimit).clamp(0.0, 1.0);
      final bool isOver = b.spent > b.monthlyLimit;
      
      return InkWell(
        onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditBudgetScreen(budget: b))); load(); },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: semantic.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b.category.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("₹${b.spent} / ₹${b.monthlyLimit}", style: TextStyle(fontSize: 12, color: isOver ? semantic.overspent : semantic.secondaryText, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: semantic.divider,
                  color: isOver ? semantic.overspent : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList());
  }

  Widget _buildSectionHeader(String title, String sub, AppColors semantic, {VoidCallback? onAdd}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text(sub, style: TextStyle(fontSize: 11, color: semantic.secondaryText, fontWeight: FontWeight.w500))]), if (onAdd != null) IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.grey), onPressed: onAdd)]);
  }

  Widget _buildBottomBar(BuildContext context, AppColors semantic) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionIcon(Icons.handshake_outlined, "LOANS", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())), semantic),
            _buildActionIcon(Icons.credit_card_outlined, "CARDS", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditCardsScreen())), semantic),
            
            InkWell(
              onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpense())); load(); },
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
            
            _buildActionIcon(Icons.event_repeat, "SUBS", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())), semantic),
            _buildActionIcon(Icons.history_outlined, "HISTORY", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyHistoryScreen())), semantic),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60, 
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: semantic.secondaryText),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: semantic.secondaryText, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}