import 'package:flutter/material.dart';

import 'package:truecash/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> goal;
  const EditGoalScreen({super.key, required this.goal});

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController targetCtrl;
  late TextEditingController currentCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.goal['name']);
    targetCtrl =
        TextEditingController(text: widget.goal['target_amount'].toString());
    currentCtrl =
        TextEditingController(text: widget.goal['current_amount'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Goal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _delete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildField("Goal Name", nameCtrl),
            _buildField("Target Amount", targetCtrl,
                isNum: true, prefix: CurrencyFormatter.symbol),
            _buildField("Current Saved", currentCtrl,
                isNum: true, prefix: CurrencyFormatter.symbol),
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
                child: const Text("UPDATE GOAL",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool isNum = false, String? prefix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix != null ? "$prefix " : null,
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _update() async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.updateGoal(
      widget.goal['id'],
      nameCtrl.text,
      int.parse(targetCtrl.text),
      int.parse(currentCtrl.text),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.deleteItem('saving_goals', widget.goal['id']);
    if (mounted) Navigator.pop(context);
  }
}
