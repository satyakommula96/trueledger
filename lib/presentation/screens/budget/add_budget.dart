import 'package:flutter/material.dart';

import 'package:truecash/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final categoryCtrl = TextEditingController();
  final limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Budget")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: categoryCtrl,
              decoration:
                  const InputDecoration(labelText: "Category (e.g. Food)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "${CurrencyFormatter.symbol} ",
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("CREATE BUDGET"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (categoryCtrl.text.isEmpty || limitCtrl.text.isEmpty) return;
    final repo = ref.read(financialRepositoryProvider);
    await repo.addBudget(categoryCtrl.text, int.parse(limitCtrl.text));
    if (mounted) Navigator.pop(context);
  }
}
