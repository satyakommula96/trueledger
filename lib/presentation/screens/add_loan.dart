import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/theme/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  const AddLoanScreen({super.key});

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final nameCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final remainingCtrl = TextEditingController();
  final emiCtrl = TextEditingController();
  final rateCtrl = TextEditingController();
  final dueCtrl = TextEditingController();
  String selectedType = 'Bank';
  DateTime? _selectedDate;

  final List<String> loanTypes = [
    'Bank',
    'Individual',
    'Gold',
    'Car',
    'Home',
    'Education'
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("NEW BORROWING")),
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
              children: loanTypes.map((t) {
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
                hint: "e.g. HDFC Gold Loan", type: TextInputType.text),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _buildField("REMAINING BALANCE", remainingCtrl,
                        hint: "0",
                        type: TextInputType.number,
                        prefix: CurrencyHelper.symbol)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildField("TOTAL LOAN", totalCtrl,
                        hint: "0",
                        type: TextInputType.number,
                        prefix: CurrencyHelper.symbol)),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Individual') ...[
              Row(
                children: [
                  Expanded(
                      child: _buildField("MONTHLY EMI", emiCtrl,
                          hint: "0",
                          type: TextInputType.number,
                          prefix: CurrencyHelper.symbol)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("INTEREST RATE", rateCtrl,
                          hint: "0.0",
                          type: TextInputType.number,
                          prefix: "%")),
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
                      hint: selectedType == 'Individual'
                          ? "Select Date"
                          : "Select Day",
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
                child: const Text("COMMIT BORROWING",
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

  Widget _buildField(String label, TextEditingController ctrl,
      {String hint = "",
      TextInputType type = TextInputType.text,
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
            hintText: hint,
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
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty) return;

    final total = int.tryParse(totalCtrl.text) ?? 0;
    // If remaining is left empty, assume it's a new loan equal to the total amount
    final remaining = remainingCtrl.text.isEmpty
        ? total
        : (int.tryParse(remainingCtrl.text) ?? 0);

    final repo = ref.read(financialRepositoryProvider);
    await repo.addLoan(
      nameCtrl.text,
      selectedType,
      total,
      remaining,
      int.tryParse(emiCtrl.text) ?? 0,
      double.tryParse(rateCtrl.text) ?? 0.0,
      dueCtrl.text,
      DateTime.now().toIso8601String(),
    );
    if (mounted) Navigator.pop(context);
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
        dueCtrl.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }
}
