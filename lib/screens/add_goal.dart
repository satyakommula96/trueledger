import 'package:flutter/material.dart';
import '../db/database.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Saving Goal")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Goal Name (e.g. Car)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Target Amount (₹)"),
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
    final db = await AppDatabase.db;
    await db.insert('saving_goals', {
      'name': nameCtrl.text,
      'target_amount': int.parse(targetCtrl.text),
      'current_amount': 0,
    });
    if (mounted) Navigator.pop(context);
  }
}
