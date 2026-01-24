import 'package:flutter/material.dart';

import 'package:truecash/core/utils/currency_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Saving Goal")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: "Goal Name (e.g. Car)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Target Amount",
                prefixText: "${CurrencyHelper.symbol} ",
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("CREATE GOAL"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty || targetCtrl.text.isEmpty) return;
    final repo = ref.read(financialRepositoryProvider);
    await repo.addGoal(nameCtrl.text, int.parse(targetCtrl.text));
    if (mounted) Navigator.pop(context);
  }
}
