import 'package:flutter/material.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  final String? initialType;
  const AddLoanScreen({super.key, this.initialType});

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
  late String selectedType;
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
  void initState() {
    super.initState();
    selectedType =
        (widget.initialType != null && loanTypes.contains(widget.initialType))
            ? widget.initialType!
            : 'Bank';
  }

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
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefix: CurrencyFormatter.symbol)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildField("TOTAL LOAN", totalCtrl,
                        hint: "0",
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefix: CurrencyFormatter.symbol)),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedType != 'Individual') ...[
              Row(
                children: [
                  Expanded(
                      child: _buildField("MONTHLY EMI", emiCtrl,
                          hint: "0",
                          type: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefix: CurrencyFormatter.symbol)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("INTEREST RATE", rateCtrl,
                          hint: "0.0",
                          type: const TextInputType.numberWithOptions(
                              decimal: true),
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
            const SizedBox(height: 16),
            const Center(
              child: Text(
                "Interest calculation: Reducing balance (daily)",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic),
              ),
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
      {String? hint,
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
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    if (selectedType == 'Individual') {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 5),
      );

      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          dueCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
        });
      }
    } else {
      // Pick day of month
      final picked = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("SELECT DUE DAY"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                return InkWell(
                  onTap: () => Navigator.pop(context, day),
                  child: Center(
                    child: Text(day.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
        ),
      );

      if (picked != null) {
        setState(() {
          dueCtrl.text = picked == 1
              ? "1st"
              : picked == 2
                  ? "2nd"
                  : picked == 3
                      ? "3rd"
                      : "${picked}th";
        });
      }
    }
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty ||
        totalCtrl.text.isEmpty ||
        remainingCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill required fields")));
      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    final total = double.tryParse(totalCtrl.text) ?? 0.0;
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;

    if (remaining > total) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Remaining balance cannot exceed total loan")));
      return;
    }

    await repo.addLoan(
      nameCtrl.text,
      selectedType,
      total,
      remaining,
      double.tryParse(emiCtrl.text) ?? 0.0,
      double.tryParse(rateCtrl.text) ?? 0.0,
      dueCtrl.text,
      DateTime.now().toIso8601String(),
    );

    if (mounted) {
      ref.invalidate(dashboardProvider);
      Navigator.pop(context);
    }
  }
}
