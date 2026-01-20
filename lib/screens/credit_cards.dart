import 'package:flutter/material.dart';
import '../db/database.dart';
import '../theme/theme.dart';
import 'add_card.dart';
import 'edit_card.dart';

class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  List<Map<String, dynamic>> cards = [];

  Future<void> load() async {
    final db = await AppDatabase.db;
    final data = await db.query('credit_cards');
    setState(() { cards = data.map((e) => Map<String, dynamic>.from(e)).toList(); });
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("CARDS & LIMITS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCreditCardScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      body: cards.isEmpty 
        ? Center(child: Text("NO CARDS REGISTERED.", style: TextStyle(color: semantic.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)))
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: cards.length,
            itemBuilder: (_, i) {
              final c = cards[i];
              final limit = (c['credit_limit'] as num?)?.toDouble() ?? 0;
              final stmt = (c['statement_balance'] as num?)?.toDouble() ?? 0;
              final minDue = (c['min_due'] as num?)?.toDouble() ?? 0;
              final util = limit == 0 ? 0 : (stmt / limit) * 100;
              final isHighUtil = util > 30;

              return InkWell(
                onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCreditCardScreen(card: c))); load(); },
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
                          Text(c['bank'].toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: semantic.secondaryText)),
                          if (isHighUtil) Icon(Icons.warning_amber_rounded, color: semantic.warning, size: 18),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("₹${stmt.toInt()}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colorScheme.onSurface, letterSpacing: -1)),
                              Text("Statement balance", style: TextStyle(fontSize: 11, color: semantic.secondaryText, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("₹${minDue.toInt()}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isHighUtil ? semantic.warning : colorScheme.onSurface)),
                              Text("Min. due", style: TextStyle(fontSize: 10, color: semantic.secondaryText, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: util / 100,
                          backgroundColor: semantic.divider,
                          color: isHighUtil ? semantic.warning : colorScheme.primary,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("LIMIT: ₹${limit.toInt()}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: semantic.secondaryText, letterSpacing: 0.5)),
                          Text("${util.toStringAsFixed(1)}% UTILIZED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isHighUtil ? semantic.warning : semantic.secondaryText)),
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