import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/domain/models/models.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class EditLoanScreen extends ConsumerStatefulWidget {
  final Loan loan;
  const EditLoanScreen({super.key, required this.loan});

  @override
  ConsumerState<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends ConsumerState<EditLoanScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController totalCtrl;
  late TextEditingController remainingCtrl;
  late TextEditingController emiCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController dueCtrl;
  late String selectedType;
  DateTime? _selectedDate;

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

    // Try to parse existing date if it looks like a full date (e.g. 15 Feb 2026)
    try {
      _selectedDate = DateFormat('dd-MM-yyyy').parse(widget.loan.dueDate);
    } catch (_) {
      // Ignore if parsing fails (e.g. just Day number)
    }
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
                'Bank',
                'Individual',
                'Gold',
                'Car',
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
                        type: TextInputType.number,
                        prefix: CurrencyFormatter.symbol)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildField("TOTAL LOAN", totalCtrl,
                        type: TextInputType.number,
                        prefix: CurrencyFormatter.symbol)),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Individual') ...[
              Row(
                children: [
                  Expanded(
                      child: _buildField("MONTHLY EMI", emiCtrl,
                          type: TextInputType.number,
                          prefix: CurrencyFormatter.symbol)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("INTEREST RATE", rateCtrl,
                          type: TextInputType.number, prefix: "%")),
                ],
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildField(
                      selectedType == 'Individual'
                          ? "EXPECTED REPAYMENT DATE"
                          : "DUE DATE (DAY OF MONTH)",
                      dueCtrl,
                      type: TextInputType.text,
                      readOnly: true,
                      onTap: _pickDate),
                ),
                if (selectedType == 'Individual') ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextButton(
                      onPressed: () =>
                          setState(() => dueCtrl.text = "Flexible"),
                      child: const Text("FLEXIBLE"),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 48),
            if (selectedType != 'Individual') ...[
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
            Text("Emi Amount: ${CurrencyFormatter.format(emi.toInt())}"),
            const SizedBox(height: 8),
            Text("Interest Component: ${CurrencyFormatter.format(interest)}",
                style: const TextStyle(color: Colors.red)),
            Text(
                "Principal Reduction: ${CurrencyFormatter.format(principalComp)}",
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
      final repo = ref.read(financialRepositoryProvider);
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
      {TextInputType type = TextInputType.text,
      String? prefix,
      bool readOnly = false,
      VoidCallback? onTap}) {
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
          readOnly: readOnly,
          onTap: onTap,
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
    final total = int.tryParse(totalCtrl.text) ?? 0;
    final remaining = int.tryParse(remainingCtrl.text) ?? 0;

    if (remaining > total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Remaining balance cannot exceed total loan")));
      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    await repo.updateLoan(
      widget.loan.id,
      nameCtrl.text,
      selectedType,
      total,
      remaining,
      int.tryParse(emiCtrl.text) ?? 0,
      double.tryParse(rateCtrl.text) ?? 0.0,
      dueCtrl.text,
    );
    if (mounted) {
      ref.invalidate(dashboardProvider);
      Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("DELETE LOAN?"),
        content: const Text("This will permanently remove this borrowing."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(financialRepositoryProvider);
      await repo.deleteItem('loans', widget.loan.id);
      if (mounted) {
        ref.invalidate(dashboardProvider);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dueCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }
}
