import 'package:flutter/material.dart';

import '../logic/financial_repository.dart';
import '../logic/currency_helper.dart';
import '../theme/theme.dart';

class AddExpense extends StatefulWidget {
  final String? initialType;
  const AddExpense({super.key, this.initialType});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String selectedCategory = 'General';
  String type = 'Variable';

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null &&
        categoryMap.containsKey(widget.initialType)) {
      type = widget.initialType!;
      selectedCategory = categoryMap[type]!.first;
    }
  }

  final Map<String, List<String>> categoryMap = {
    'Variable': ['Food', 'Transport', 'Shopping', 'Entertainment', 'Others'],
    'Fixed': ['Rent', 'Utility', 'Insurance', 'EMI'],
    'Investment': [
      'Stocks',
      'Mutual Funds',
      'SIP',
      'Crypto',
      'Gold',
      'Lending'
    ],
    'Income': ['Salary', 'Freelance', 'Dividends'],
    'Subscription': ['OTT', 'Software', 'Gym'],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("NEW LEDGER ENTRY")),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ENTRY TYPE",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryMap.keys.map((t) {
                  final active = type == t;
                  final isIncome = t == 'Income';
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(t.toUpperCase()),
                      selected: active,
                      onSelected: (_) => setState(() {
                        type = t;
                        selectedCategory = categoryMap[t]![0];
                      }),
                      selectedColor:
                          isIncome ? semantic.income : colorScheme.onSurface,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                          color: active
                              ? (isIncome
                                  ? semantic.income
                                  : colorScheme.onSurface)
                              : colorScheme.onSurface.withValues(alpha: 0.1)),
                      labelStyle: TextStyle(
                          color: active
                              ? colorScheme.surface
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 48),
            const Text("TRANSACTION AMOUNT",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: -2,
                  color: type == 'Income'
                      ? semantic.income
                      : colorScheme.onSurface),
              decoration: InputDecoration(
                  prefixText: "${CurrencyHelper.symbol} ",
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
            const SizedBox(height: 48),
            const Text("CATEGORY CLASSIFICATION",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryMap[type]!.map((cat) {
                final active = selectedCategory == cat;
                return ActionChip(
                  label: Text(cat.toUpperCase()),
                  onPressed: () => setState(() => selectedCategory = cat),
                  backgroundColor: active
                      ? colorScheme.onSurface.withValues(alpha: 0.05)
                      : Colors.transparent,
                  side: BorderSide(
                      color: active
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.05)),
                  labelStyle: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            const Text("AUDIT NOTES",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                hintText: "Optional details...",
                filled: true,
                fillColor: colorScheme.onSurface.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'Income'
                      ? semantic.income
                      : colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("COMMIT TO LEDGER",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (amountCtrl.text.isEmpty) return;
    final repo = FinancialRepository();
    await repo.addEntry(type, int.parse(amountCtrl.text), selectedCategory,
        noteCtrl.text, DateTime.now().toIso8601String());
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
