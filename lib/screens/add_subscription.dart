import 'package:flutter/material.dart';
import '../logic/financial_repository.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Subscription")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Service Name (e.g. Netflix)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Monthly Amount (₹)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: "Billing Date (e.g. 5th)"),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("SAVE SUBSCRIPTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
    final repo = FinancialRepository();
    await repo.addSubscription(
      nameCtrl.text,
      int.parse(amountCtrl.text),
      dateCtrl.text
    );
    if (mounted) Navigator.pop(context);
  }
}
