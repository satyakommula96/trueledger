import 'package:flutter/material.dart';
import '../models/models.dart';
import '../logic/financial_repository.dart';
import '../theme/theme.dart';

class EditLoanScreen extends StatefulWidget {
  final Loan loan;
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
    nameCtrl = TextEditingController(text: widget.loan.name);
    totalCtrl = TextEditingController(text: widget.loan.totalAmount.toString());
    remainingCtrl =
        TextEditingController(text: widget.loan.remainingAmount.toString());
    emiCtrl = TextEditingController(text: widget.loan.emi.toString());
    rateCtrl = TextEditingController(text: widget.loan.interestRate.toString());
    dueCtrl = TextEditingController(text: widget.loan.dueDate);
    selectedType = widget.loan.loanType;
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
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("LOAN CLASSIFICATION",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Gold',
                'Car',
                'Personal',
                'Person',
                'Home',
                'Education'
              ].map((t) {
                final active = selectedType == t;
                return ActionChip(
                  label: Text(t.toUpperCase()),
                  onPressed: () => setState(() => selectedType = t),
                  backgroundColor: active
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  side: BorderSide(
                      color: active ? colorScheme.primary : semantic.divider),
                  labelStyle: TextStyle(
                      color:
                          active ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildField("CREDITOR / LOAN NAME", nameCtrl,
                type: TextInputType.text),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _buildField("REMAINING BALANCE", remainingCtrl,
                        type: TextInputType.number, prefix: "₹")),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildField("TOTAL LOAN", totalCtrl,
                        type: TextInputType.number, prefix: "₹")),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Person') ...[
              Row(
                children: [
                  Expanded(
                      child: _buildField("MONTHLY EMI", emiCtrl,
                          type: TextInputType.number, prefix: "₹")),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("INTEREST RATE", rateCtrl,
                          type: TextInputType.number, prefix: "%")),
                ],
              ),
              const SizedBox(height: 24),
            ],
            _buildField(
                selectedType == 'Person'
                    ? "EXPECTED REPAYMENT DATE"
                    : "DUE DATE (DAY OF MONTH)",
                dueCtrl,
                type: TextInputType.text),
            const SizedBox(height: 48),
            if (selectedType != 'Person') ...[
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _payEmi,
                  icon: const Icon(Icons.payment),
                  label: const Text("RECORD EMI PAYMENT",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("UPDATE BORROWING",
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

  Future<void> _payEmi() async {
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;
    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
    final emi = double.tryParse(emiCtrl.text) ?? 0.0;

    // Simple Interest for 1 month
    final interestFn = (remaining * rate / 100) / 12;
    final interest = interestFn.round();
    final principalComp = (emi - interest).round();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("RECORD EMI PAYMENT"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Emi Amount: ₹${emi.toInt()}"),
            const SizedBox(height: 8),
            Text("Interest Component: ₹$interest",
                style: const TextStyle(color: Colors.red)),
            Text("Principal Reduction: ₹$principalComp",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
                "This will reduce the loan balance and record an expense.",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("CONFIRM")),
        ],
      ),
    );

    if (confirmed == true) {
      final newBalance = (remaining - principalComp).toInt();
      setState(() {
        remainingCtrl.text = newBalance.toString();
      });
      // Record expense first to avoid context issues if _save pops
      final repo = FinancialRepository();
      await repo.addEntry('Fixed', emi.toInt(), 'EMI',
          'EMI Payment for ${nameCtrl.text}', DateTime.now().toIso8601String());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("EMI Recorded: Loan adjusted & Expense added.")));
      }

      // Save loan update (this pops the screen)
      await _save();
    }
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, String? prefix}) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: prefix != null ? "$prefix " : null,
            prefixStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: semantic.divider)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final repo = FinancialRepository();
    await repo.updateLoan(
      widget.loan.id,
      nameCtrl.text,
      selectedType,
      int.tryParse(totalCtrl.text) ?? 0,
      int.tryParse(remainingCtrl.text) ?? 0,
      int.tryParse(emiCtrl.text) ?? 0,
      double.tryParse(rateCtrl.text) ?? 0.0,
      dueCtrl.text,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final repo = FinancialRepository();
    await repo.deleteItem('loans', widget.loan.id);
    if (mounted) Navigator.pop(context);
  }
}
