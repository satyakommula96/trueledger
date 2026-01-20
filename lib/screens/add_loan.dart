import 'package:flutter/material.dart';
import '../logic/financial_repository.dart';
import '../theme/theme.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final nameCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final remainingCtrl = TextEditingController();
  final emiCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final dueCtrl = TextEditingController();
  String selectedType = 'Personal';

  final List<String> loanTypes = ['Gold', 'Car', 'Personal', 'Person', 'Home', 'Education'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("NEW BORROWING")),
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
              children: loanTypes.map((t) {
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
            _buildField("CREDITOR / LOAN NAME", nameCtrl, hint: "e.g. HDFC Gold Loan", type: TextInputType.text),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildField("REMAINING BALANCE", remainingCtrl, hint: "0", type: TextInputType.number, prefix: "₹")),
                const SizedBox(width: 16),
                Expanded(child: _buildField("TOTAL LOAN", totalCtrl, hint: "0", type: TextInputType.number, prefix: "₹")),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Person') ...[
              Row(
                children: [
                  Expanded(child: _buildField("MONTHLY EMI", emiCtrl, hint: "0", type: TextInputType.number, prefix: "₹")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField("INTEREST RATE", rateCtrl, hint: "0.0", type: TextInputType.number, prefix: "%")),
                ],
              ),
              const SizedBox(height: 24),
            ],
            _buildField(selectedType == 'Person' ? "EXPECTED REPAYMENT DATE" : "DUE DATE (DAY OF MONTH)", dueCtrl, hint: selectedType == 'Person' ? "e.g. Next Month" : "e.g. 5th", type: TextInputType.text),
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
                child: const Text("COMMIT BORROWING", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String hint = "", TextInputType type = TextInputType.text, String? prefix}) {
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
            hintText: hint,
            prefixText: prefix != null ? "$prefix " : null,
            prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: semantic.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty || remainingCtrl.text.isEmpty) return;
    final repo = FinancialRepository();
    await repo.addLoan(
      nameCtrl.text,
      selectedType,
      int.tryParse(totalCtrl.text) ?? 0,
      int.tryParse(remainingCtrl.text) ?? 0,
      int.tryParse(emiCtrl.text) ?? 0,
      double.tryParse(rateCtrl.text) ?? 0.0,
      dueCtrl.text,
      DateTime.now().toIso8601String(),
    );
    if (mounted) Navigator.pop(context);
  }
}
