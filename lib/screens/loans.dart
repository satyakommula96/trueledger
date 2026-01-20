import 'package:flutter/material.dart';
import '../db/database.dart';
import '../theme/theme.dart';
import 'add_loan.dart';
import 'edit_loan.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Map<String, dynamic>> loans = [];

  Future<void> load() async {
    final db = await AppDatabase.db;
    final data = await db.query('loans');
    setState(() { loans = data; });
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("BORROWINGS & LOANS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLoanScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      body: loans.isEmpty 
        ? Center(child: Text("NO ACTIVE BORROWINGS.", style: TextStyle(color: semantic.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: loans.length,
            itemBuilder: (_, i) {
              final l = loans[i];
              final total = (l['total_amount'] as num).toDouble();
              final remaining = (l['remaining_amount'] as num).toDouble();
              final emi = (l['emi'] as num).toDouble();
              final progress = remaining / total;

              return InkWell(
                onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditLoanScreen(loan: l))); load(); },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: semantic.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: semantic.overspent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l['loan_type'].toString().toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: semantic.overspent)),
                          ),
                          Text(l['due_date'].toString().toUpperCase() + " DUE", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: semantic.secondaryText)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(l['name'].toString().toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("₹${remaining.toInt()}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              Text(l['loan_type'] == 'Person' ? "Borrowed Amount" : "Remaining Balance", style: TextStyle(fontSize: 10, color: semantic.secondaryText, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          if (l['loan_type'] != 'Person')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("₹${emi.toInt()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                Text("Monthly EMI", style: TextStyle(fontSize: 10, color: semantic.secondaryText, fontWeight: FontWeight.w500)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : 1 - progress, 
                          backgroundColor: semantic.divider,
                          color: semantic.overspent,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (l['loan_type'] != 'Person')
                            Text("${l['interest_rate']}% APR", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: semantic.secondaryText)),
                          Text("TOTAL: ₹${total.toInt()}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: semantic.secondaryText)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
