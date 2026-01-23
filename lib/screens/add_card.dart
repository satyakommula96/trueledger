import 'package:flutter/material.dart';
import '../logic/financial_repository.dart';

class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final bankCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final stmtCtrl = TextEditingController();
  final minDueCtrl = TextEditingController();
  final dueDateCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Credit Card")),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildField("Bank Name", bankCtrl, Icons.account_balance),
            _buildField("Credit Limit", limitCtrl, Icons.speed, isNumber: true),
            _buildField(
                "Statement Balance", stmtCtrl, Icons.account_balance_wallet,
                isNumber: true),
            _buildField("Minimum Due", minDueCtrl, Icons.low_priority,
                isNumber: true),
            _buildField(
                "Due Date (e.g. 15th)", dueDateCtrl, Icons.calendar_today),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("ADD CARD",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool isNumber = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (bankCtrl.text.isEmpty || limitCtrl.text.isEmpty) return;
    final repo = FinancialRepository();
    await repo.addCreditCard(
        bankCtrl.text,
        int.tryParse(limitCtrl.text) ?? 0,
        int.tryParse(stmtCtrl.text) ?? 0,
        int.tryParse(minDueCtrl.text) ?? 0,
        dueDateCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Credit Card Added"),
          behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }
}
