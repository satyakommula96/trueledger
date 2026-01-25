import 'package:flutter/material.dart';

import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/usecase_providers.dart';
import 'package:truecash/domain/usecases/budget_usecases.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  final Budget budget;
  const EditBudgetScreen({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  late TextEditingController limitCtrl;

  @override
  void initState() {
    super.initState();
    limitCtrl =
        TextEditingController(text: widget.budget.monthlyLimit.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${widget.budget.category} Budget"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _delete,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "${CurrencyFormatter.symbol} ",
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("UPDATE BUDGET",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    final limit = int.tryParse(limitCtrl.text);
    if (limit == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid limit format")));
      return;
    }

    final updateBudget = ref.read(updateBudgetUseCaseProvider);
    final result = await updateBudget(UpdateBudgetParams(
      id: widget.budget.id,
      monthlyLimit: limit,
    ));

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }

  Future<void> _delete() async {
    final deleteBudget = ref.read(deleteBudgetUseCaseProvider);
    final result = await deleteBudget(widget.budget.id);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }
}
