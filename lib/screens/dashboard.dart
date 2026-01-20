import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../db/database.dart';
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
  List<Map<String, dynamic>> budgets = [];
  List<Map<String, dynamic>> savingGoals = [];
  List<Map<String, dynamic>> trendData = [];
  List<Map<String, dynamic>> upcomingBills = [];
  int npsTotal = 0;
  int pfTotal = 0;
  int investmentsTotal = 0;
  int creditCardDebt = 0;
  int loansTotal = 0;
  int netWorth = 0;

  Future<void> load() async {
    final db = await AppDatabase.db;
    final income = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM income_sources')) ?? 0;
    final fixed = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM fixed_expenses')) ?? 0;
    final variable = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM variable_expenses')) ?? 0;
    final subs = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM subscriptions WHERE active=1')) ?? 0;
    investmentsTotal = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM investments WHERE active=1')) ?? 0;
    npsTotal = Sqflite.firstIntValue(await db.rawQuery("SELECT SUM(amount) FROM retirement_contributions WHERE type = 'NPS'")) ?? 0;
    pfTotal = Sqflite.firstIntValue(await db.rawQuery("SELECT SUM(amount) FROM retirement_contributions WHERE type = 'EPF'")) ?? 0;
    final otherRetirement = Sqflite.firstIntValue(await db.rawQuery("SELECT SUM(amount) FROM retirement_contributions WHERE type NOT IN ('NPS', 'EPF')")) ?? 0;
    creditCardDebt = Sqflite.firstIntValue(await db.rawQuery("SELECT SUM(statement_balance) FROM credit_cards")) ?? 0;
    loansTotal = Sqflite.firstIntValue(await db.rawQuery("SELECT SUM(remaining_amount) FROM loans")) ?? 0;
    netWorth = (investmentsTotal + npsTotal + pfTotal + otherRetirement) - (creditCardDebt + loansTotal);

    final trendRaw = await db.rawQuery('SELECT substr(date, 1, 7) as month, SUM(amount) as total FROM variable_expenses GROUP BY month ORDER BY month DESC LIMIT 6');
    trendData = trendRaw.reversed.toList();

    final subBills = await db.query('subscriptions', where: 'active = 1');
    final ccBills = await db.query('credit_cards');
    final loanBills = await db.query('loans');
    upcomingBills = [
      ...subBills.map((s) => {'title': s['name'], 'amount': s['amount'], 'type': 'SUBSCRIPTION', 'due': 'RECURRING'}),
      ...ccBills.map((c) => {'title': c['bank'], 'amount': c['min_due'], 'type': 'CREDIT DUE', 'due': c['due_date']}),
      ...loanBills.map((l) => {'title': l['name'], 'amount': l['emi'], 'type': 'LOAN EMI', 'due': l['due_date']}),
    ];

    final budgetData = await db.query('budgets');
    List<Map<String, dynamic>> processedBudgets = [];
    for (var b in budgetData) {
      final spent = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM variable_expenses WHERE category = ?', [b['category']])) ?? 0;
      processedBudgets.add({...b, 'spent': spent});
    }
    
    final goals = await db.query('saving_goals');
    final groupData = await db.rawQuery('SELECT category, SUM(amount) as total FROM variable_expenses GROUP BY category ORDER BY total DESC');

    setState(() {
      summary = MonthlySummary(totalIncome: income, totalFixed: fixed, totalVariable: variable, totalSubscriptions: subs, totalInvestments: investmentsTotal);
      categorySpending = groupData; budgets = processedBudgets; savingGoals = goals;
    });
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
                        Expanded(child: _buildSummaryCard("Income", "₹${summary!.totalIncome}", semantic.income, semantic)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSummaryCard("Expenses", "₹${summary!.totalFixed + summary!.totalVariable + summary!.totalSubscriptions}", semantic.overspent, semantic)),
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

  Widget _buildSummaryCard(String label, String value, Color valueColor, AppColors semantic) {
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
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: semantic.secondaryText, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primary, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL NET WORTH", style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
              Icon(Icons.account_balance_wallet_outlined, color: colorScheme.onPrimary.withOpacity(0.3), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text("₹$netWorth", style: TextStyle(color: colorScheme.onPrimary, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: colorScheme.onPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text("AFTER LIABILITIES", style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.8), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          )
        ],
      ),
    );
  }

  Widget _buildAssetLiabilityCard(ColorScheme colorScheme, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: semantic.divider)),
      child: Row(
        children: [
          _buildMiniStat("TOTAL ASSETS", "₹${netWorth + creditCardDebt + loansTotal}", semantic.income, semantic),
          const Spacer(),
          Container(width: 1, height: 40, color: semantic.divider),
          const Spacer(),
          _buildMiniStat("LIABILITIES", "₹${creditCardDebt + loansTotal}", semantic.overspent, semantic),
        ],
      ),
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
                Text("₹$loansTotal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: semantic.overspent)),
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
              belowBarData: BarAreaData(show: true, color: colorScheme.primary.withOpacity(0.05)),
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
      final util = (b['spent'] as num) / (b['monthly_limit'] as num == 0 ? 1 : b['monthly_limit'] as num);
      final overspent = util > 1.0;
      return InkWell(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditBudgetScreen(budget: b))); load(); }, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: semantic.divider)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(b['category'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text("₹${(b['spent'] as num).toInt()} / ₹${(b['monthly_limit'] as num).toInt()}", style: TextStyle(fontSize: 12, color: overspent ? semantic.overspent : semantic.secondaryText, fontWeight: FontWeight.w700))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: util, minHeight: 6, backgroundColor: semantic.divider, color: overspent ? semantic.overspent : colorScheme.primary))])));
    }).toList());
  }

  Widget _buildSectionHeader(String title, String sub, AppColors semantic, {VoidCallback? onAdd}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text(sub, style: TextStyle(fontSize: 11, color: semantic.secondaryText, fontWeight: FontWeight.w500))]), if (onAdd != null) IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.grey), onPressed: onAdd)]);
  }

  Widget _buildBottomBar(BuildContext context, AppColors semantic) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), decoration: BoxDecoration(color: colorScheme.surface, border: Border(top: BorderSide(color: semantic.divider))), child: Row(children: [Expanded(child: InkWell(onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpense())); load(); }, child: Container(height: 52, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text("Add Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)))))), const SizedBox(width: 12), _buildActionIcon(Icons.handshake_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen())), semantic), const SizedBox(width: 12), _buildActionIcon(Icons.credit_card_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditCardsScreen())), semantic), const SizedBox(width: 12), _buildActionIcon(Icons.history_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MonthlyHistoryScreen())), semantic)]));
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, AppColors semantic) {
    return InkWell(onTap: onTap, child: Container(width: 52, height: 52, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: semantic.divider)), child: Icon(icon, size: 22, color: semantic.secondaryText)));
  }
}