import 'package:flutter/material.dart';
import '../db/database.dart';
import '../theme/theme.dart';

class EditLoanScreen extends StatefulWidget {
  final Map<String, dynamic> loan;
  const EditLoanScreen({super.key, required this.loan});

  @override
  State<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends State<EditLoanScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController totalCtrl;
  late TextEditingController remainingCtrl;
  late TextEditingController emiCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController dueCtrl;
  late String selectedType;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.loan['name']);
    totalCtrl = TextEditingController(text: widget.loan['total_amount'].toString());
    remainingCtrl = TextEditingController(text: widget.loan['remaining_amount'].toString());
    emiCtrl = TextEditingController(text: widget.loan['emi'].toString());
    rateCtrl = TextEditingController(text: widget.loan['interest_rate'].toString());
    dueCtrl = TextEditingController(text: widget.loan['due_date']);
    selectedType = widget.loan['loan_type'];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("UPDATE LOAN"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _delete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("LOAN CLASSIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Gold', 'Car', 'Personal', 'Person', 'Home', 'Education'].map((t) {
                final active = selectedType == t;
                return ActionChip(
                  label: Text(t.toUpperCase()),
                  onPressed: () => setState(() => selectedType = t),
                  backgroundColor: active ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  side: BorderSide(color: active ? colorScheme.primary : semantic.divider),
                  labelStyle: TextStyle(color: active ? colorScheme.primary : colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildField("CREDITOR / LOAN NAME", nameCtrl, type: TextInputType.text),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildField("REMAINING BALANCE", remainingCtrl, type: TextInputType.number, prefix: "₹")),
                const SizedBox(width: 16),
                Expanded(child: _buildField("TOTAL LOAN", totalCtrl, type: TextInputType.number, prefix: "₹")),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Person') ...[
              Row(
                children: [
                  Expanded(child: _buildField("MONTHLY EMI", emiCtrl, type: TextInputType.number, prefix: "₹")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("INTEREST RATE", rateCtrl, type: TextInputType.number, prefix: "%")),
                ],
              ),
              const SizedBox(height: 24),
            ],
            _buildField(selectedType == 'Person' ? "EXPECTED REPAYMENT DATE" : "DUE DATE (DAY OF MONTH)", dueCtrl, type: TextInputType.text),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("UPDATE BORROWING", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text, String? prefix}) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: prefix != null ? "$prefix " : null,
            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: semantic.divider)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final db = await AppDatabase.db;
    await db.update('loans', {
      'name': nameCtrl.text,
      'loan_type': selectedType,
      'total_amount': int.tryParse(totalCtrl.text) ?? 0,
      'remaining_amount': int.tryParse(remainingCtrl.text) ?? 0,
      'emi': int.tryParse(emiCtrl.text) ?? 0,
      'interest_rate': double.tryParse(rateCtrl.text) ?? 0.0,
      'due_date': dueCtrl.text,
    }, where: 'id = ?', whereArgs: [widget.loan['id']]);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final db = await AppDatabase.db;
    await db.delete('loans', where: 'id = ?', whereArgs: [widget.loan['id']]);
    if (mounted) Navigator.pop(context);
  }
}
