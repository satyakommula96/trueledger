import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../theme/theme.dart';
import 'month_detail.dart';

class MonthlyHistoryScreen extends StatefulWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  List<Map<String, dynamic>> monthSummaries = [];

  Future<void> load() async {
    final db = await AppDatabase.db;
    final monthsQuery = await db.rawQuery('''
      SELECT DISTINCT substr(date, 1, 7) as month FROM variable_expenses
      UNION SELECT DISTINCT substr(date, 1, 7) as month FROM income_sources
      UNION SELECT DISTINCT substr(date, 1, 7) as month FROM fixed_expenses
      UNION SELECT DISTINCT substr(date, 1, 7) as month FROM investments
      ORDER BY month DESC
    ''');

    List<Map<String, dynamic>> summaries = [];
    for (var m in monthsQuery) {
      final month = m['month'].toString();
      final income = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM income_sources WHERE substr(date, 1, 7) = ?', [month])) ?? 0;
      final variable = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM variable_expenses WHERE substr(date, 1, 7) = ?', [month])) ?? 0;
      final fixed = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM fixed_expenses WHERE substr(date, 1, 7) = ?', [month])) ?? 0;
      final invested = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(amount) FROM investments WHERE substr(date, 1, 7) = ?', [month])) ?? 0;
      summaries.add({'month': month, 'income': income, 'expenses': variable + fixed, 'invested': invested, 'net': income - (variable + fixed + invested)});
    }
    setState(() { monthSummaries = summaries; });
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text("LEDGER HISTORY")),
      body: monthSummaries.isEmpty
        ? Center(child: Text("NO PERIODS TRACKED.", style: TextStyle(color: semantic.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: monthSummaries.length,
            itemBuilder: (_, i) {
              final s = monthSummaries[i];
              final positive = s['net'] >= 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: semantic.divider)
                ),
                child: InkWell(
                  onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => MonthDetailScreen(month: s['month']))); load(); },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(_formatMonth(s['month']), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5, color: colorScheme.onSurface)),
                          Text("₹${s['net']}", style: TextStyle(fontWeight: FontWeight.w800, color: positive ? semantic.income : semantic.warning, fontSize: 16)),
                        ]),
                        const SizedBox(height: 20),
                        Divider(height: 1, color: semantic.divider),
                        const SizedBox(height: 20),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _buildStatItem("INCOME", "₹${s['income']}", semantic),
                          _buildStatItem("EXPENDITURE", "₹${s['expenses']}", semantic),
                          _buildStatItem("INVESTED", "₹${s['invested']}", semantic),
                        ]),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildStatItem(String label, String value, AppColors semantic) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: semantic.secondaryText, letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    ]);
  }

  String _formatMonth(String yyyyMm) {
    try {
      final parts = yyyyMm.split('-');
      const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
      return "${months[int.parse(parts[1]) - 1]} ${parts[0]}";
    } catch (e) { return yyyyMm; }
  }
}