import 'package:flutter/material.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newBorrowing),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.loanClassification,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.grey)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: loanTypes.map((t) {
                    final active = selectedType == t;
                    return Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: Colors.transparent),
                      child: ChoiceChip(
                        label: Text(t.toUpperCase()),
                        selected: active,
                        onSelected: (_) => setState(() => selectedType = t),
                        backgroundColor:
                            semantic.surfaceCombined.withValues(alpha: 0.3),
                        selectedColor:
                            colorScheme.primary.withValues(alpha: 0.1),
                        side: BorderSide(
                            color:
                                active ? colorScheme.primary : semantic.divider,
                            width: 1.5),
                        labelStyle: TextStyle(
                            color: active
                                ? colorScheme.primary
                                : semantic.secondaryText,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                _buildField(
                    AppLocalizations.of(context)!.creditorLoanName, nameCtrl,
                    hint: "e.g. HDFC Gold Loan", type: TextInputType.text),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(
                            AppLocalizations.of(context)!.remainingBalance,
                            remainingCtrl,
                            hint: "0",
                            type: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefix: CurrencyFormatter.symbol)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildField(
                            AppLocalizations.of(context)!.totalLoan, totalCtrl,
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
                          child: _buildField(
                              AppLocalizations.of(context)!.monthlyEmi, emiCtrl,
                              hint: "0",
                              type: const TextInputType.numberWithOptions(
                                  decimal: true),
                              prefix: CurrencyFormatter.symbol)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildField(
                              AppLocalizations.of(context)!.interestRate,
                              rateCtrl,
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
                              ? AppLocalizations.of(context)!
                                  .expectedRepaymentDate
                              : AppLocalizations.of(context)!.dueDateDayOfMonth,
                          dueCtrl,
                          hint: selectedType == 'Individual'
                              ? AppLocalizations.of(context)!.selectDate
                              : AppLocalizations.of(context)!.selectDay,
                          type: TextInputType.text,
                          readOnly: true,
                          onTap: _pickDate),
                    ),
                    if (selectedType == 'Individual') ...[
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: TextButton(
                          onPressed: () =>
                              setState(() => dueCtrl.text = "Flexible"),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context)!.flexible,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 11)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: semantic.warning.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: semantic.warning.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: semantic.warning),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            "Engine: Reducing balance (daily)",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                    child: Text(AppLocalizations.of(context)!.commitBorrowing,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: semantic.secondaryText.withValues(alpha: 0.5),
                fontSize: 14,
                fontWeight: FontWeight.normal),
            prefixText: prefix != null ? "$prefix " : null,
            prefixStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: semantic.secondaryText),
            filled: true,
            fillColor: semantic.surfaceCombined.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: semantic.divider, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 2)),
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
          title: Text(AppLocalizations.of(context)!.selectDueDay),
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
          dueCtrl.text = "$picked${DateHelper.getOrdinal(picked)}";
        });
      }
    }
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty ||
        totalCtrl.text.isEmpty ||
        remainingCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.pleaseFillRequiredFields)));

      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    final total = double.tryParse(totalCtrl.text) ?? 0.0;
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;

    if (remaining > total) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.remainingCannotExceedTotal)));

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
