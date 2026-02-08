import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/domain/models/models.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/logic/loan_engine.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

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
  List<LedgerItem> _history = [];
  bool _isLoadingHistory = true;

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
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    final repo = ref.read(financialRepositoryProvider);
    // Find matching transactions in Fixed and Variable expenses
    // Heuristic: Search for loan name in the note/label
    final all = await repo.getTransactionsForRange(
        DateTime.now().subtract(const Duration(days: 365)), DateTime.now());

    final filtered = all.where((item) {
      final text = "${item.label} ${item.note ?? ''}".toLowerCase();
      return text.contains(widget.loan.name.toLowerCase()) ||
          (item.label == 'EMI' &&
              text.contains(widget.loan.name.toLowerCase()));
    }).toList();

    setState(() {
      _history = filtered;
      _isLoadingHistory = false;
    });
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
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefix: CurrencyFormatter.symbol)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildField("TOTAL LOAN", totalCtrl,
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
                          type: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefix: CurrencyFormatter.symbol)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField("INTEREST RATE", rateCtrl,
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
            const SizedBox(height: 24),
            _buildPayoffCard(),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: _prepay,
                  icon: const Icon(Icons.speed),
                  label: const Text("RECORD PREPAYMENT",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("RECONCILIATION / PAYMENT HISTORY",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.grey)),
                TextButton.icon(
                  onPressed: _exportStatement,
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text("EXPORT STATEMENT",
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text("No recorded payment history found.",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (context, index) =>
                    Divider(color: semantic.divider, height: 1),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.date.substring(0, 10),
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(item.note ?? item.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  double _calculateAccruedInterest() {
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;
    final rate = double.tryParse(rateCtrl.text) ?? 0.0;

    final lastDateStr = widget.loan.lastPaymentDate ??
        widget.loan.date ??
        DateTime.now().toIso8601String();

    DateTime lastDate;
    try {
      lastDate = DateTime.parse(lastDateStr);
    } catch (_) {
      lastDate = DateTime.now().subtract(const Duration(days: 30));
    }

    final now = DateTime.now();
    int days = now.difference(lastDate).inDays;
    if (days < 0) days = 0;

    // Engine Version 1 Logic
    if (widget.loan.interestEngineVersion == 1) {
      if (days == 0 && widget.loan.lastPaymentDate == null) {
        days = 30;
      }
    }

    return LoanEngine.calculateInterest(
      balance: remaining,
      annualRate: rate,
      days: days,
      engineVersion: widget.loan.interestEngineVersion,
    );
  }

  Widget _buildPayoffCard() {
    if (selectedType == 'Individual') return const SizedBox.shrink();

    final interest = _calculateAccruedInterest();
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;
    final payoffAmount = remaining + interest;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("FORECLOSURE / PAYOFF QUOTE",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("ESTIMATE",
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Valid until today",
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(CurrencyFormatter.format(payoffAmount, compact: false),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        _reconcileWithBank(payoffAmount, remaining, interest),
                    child: const Text("RECONCILE WITH BANK",
                        style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: const Text("PAYOFF BREAKDOWN"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _row("Principal Outstanding", remaining),
                                      const Divider(),
                                      _row("Interest Accrued", interest),
                                      const Divider(),
                                      _row("Total Quote", payoffAmount,
                                          isBold: true),
                                      const SizedBox(height: 16),
                                      const Text(
                                          "Calculation based on Reducing Balance (Daily). Engine v${1}",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ));
                      },
                      icon: const Icon(Icons.info_outline,
                          size: 20, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(CurrencyFormatter.format(value, compact: false),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _rowSmall(String label, double value,
      {bool isBold = false, bool isCount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.grey)),
          Text(
              isCount
                  ? value.toInt().toString()
                  : CurrencyFormatter.format(value, compact: false),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? null : Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _payEmi() async {
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;
    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
    final emi = double.tryParse(emiCtrl.text) ?? 0.0;

    // Daily Interest Calculation (Tier 1 Model)
    final lastDateStr = widget.loan.lastPaymentDate ??
        widget.loan.date ??
        DateTime.now().toIso8601String();
    DateTime lastDate;
    try {
      lastDate = DateTime.parse(lastDateStr);
    } catch (_) {
      lastDate = DateTime.now().subtract(const Duration(days: 30));
    }

    final now = DateTime.now();
    int days = now.difference(lastDate).inDays;
    if (days < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Error: Payment date cannot be before last payment date.")));
      return;
    }

    if (widget.loan.interestEngineVersion == 1) {
      if (days == 0 && widget.loan.lastPaymentDate == null) {
        days = 30;
      }
    }

    final interest = LoanEngine.calculateInterest(
      balance: remaining,
      annualRate: rate,
      days: days,
      engineVersion: widget.loan.interestEngineVersion,
    );

    // Support Partial Payments
    final paymentCtrl = TextEditingController(text: emi.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentPay = double.tryParse(paymentCtrl.text) ?? 0.0;
          final pComp = currentPay - interest;
          final cBalance = remaining - pComp;

          return AlertDialog(
            title: const Text("RECORD LOAN PAYMENT"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowSmall("Opening Balance", remaining),
                  _rowSmall("Days Accrued", days.toDouble(), isCount: true),
                  const Divider(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: paymentCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: "PAYMENT AMOUNT",
                      labelStyle: const TextStyle(fontSize: 10),
                      prefixText: "${CurrencyFormatter.symbol} ",
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      "Interest Component: ${CurrencyFormatter.format(interest, compact: false)}",
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                  Text(
                      "Principal Reduction: ${CurrencyFormatter.format(pComp, compact: false)}",
                      style: TextStyle(
                          color: pComp < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const Divider(),
                  _rowSmall("Closing Balance", cBalance, isBold: true),
                  const SizedBox(height: 12),
                  if (interest > currentPay) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "NEGATIVE AMORTIZATION: Interest exceeds payment. Loan balance will increase.",
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (days > 45) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_toggle_off,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "MISSED PAYMENT DETECTED: $days days since last payment. Overdue interest is being accrued.",
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                      "Calculated using reducing-balance daily interest.",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("CANCEL")),
              TextButton(
                  onPressed: () {
                    final val = double.tryParse(paymentCtrl.text) ?? 0.0;
                    if (val <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content:
                              Text("Payment amount must be greater than 0.")));
                      return;
                    }
                    Navigator.pop(ctx, true);
                  },
                  child: const Text("CONFIRM")),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      final actualPayment = double.tryParse(paymentCtrl.text) ?? 0.0;
      final actualPrincipal = actualPayment - interest;
      final newBalance = remaining - actualPrincipal;

      setState(() {
        remainingCtrl.text = newBalance.toString();
      });

      final repo = ref.read(financialRepositoryProvider);
      final nowIso = DateTime.now().toIso8601String();

      // Record as Variable Expense (Lump sum or partial)
      await repo.addEntry('Fixed', actualPayment, 'EMI / Loan Payment',
          'Loan payment for ${nameCtrl.text}', nowIso);

      // Forensic Audit Log
      await repo.recordLoanAudit(
        loanId: widget.loan.id,
        date: nowIso,
        openingBalance: remaining,
        interestRate: rate,
        paymentAmount: actualPayment,
        daysAccrued: days,
        interestAccrued: interest,
        principalApplied: actualPrincipal,
        closingBalance: newBalance,
        engineVersion: widget.loan.interestEngineVersion,
        type: 'PAYMENT',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Payment Recorded: Ledger audit updated.")));
      }

      // Save loan update
      await repo.updateLoan(
        widget.loan.id,
        nameCtrl.text,
        selectedType,
        double.tryParse(totalCtrl.text) ?? 0.0,
        newBalance,
        emi,
        rate,
        dueCtrl.text,
        nowIso,
      );

      if (mounted) {
        ref.invalidate(dashboardProvider);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _prepay() async {
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;
    final prepayCtrl = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("RECORD PREPAYMENT"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter amount to pay towards principal.",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: prepayCtrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "${CurrencyFormatter.symbol} ",
                labelText: "PREPAYMENT AMOUNT",
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              final val = double.tryParse(prepayCtrl.text);
              if (val != null && val > 0 && val <= remaining) {
                Navigator.pop(ctx, val);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text("Invalid amount. Cannot exceed balance.")));
              }
            },
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );

    if (result != null) {
      final newBalance = remaining - result;
      setState(() {
        remainingCtrl.text = newBalance.toString();
      });

      final repo = ref.read(financialRepositoryProvider);
      final nowIso = DateTime.now().toIso8601String();

      // Record as Variable Expense (Lump sum)
      await repo.addEntry('Variable', result, 'EMI / Debt Repayment',
          'Prepayment for ${nameCtrl.text}', nowIso);

      // Prepayment Forensic Audit Log
      await repo.recordLoanAudit(
        loanId: widget.loan.id,
        date: nowIso,
        openingBalance: remaining,
        interestRate: double.tryParse(rateCtrl.text) ?? 0.0,
        paymentAmount: result,
        daysAccrued:
            0, // Prepayments don't accrue interest in this simple model, just principal
        interestAccrued: 0,
        principalApplied: result,
        closingBalance: newBalance,
        engineVersion: widget.loan.interestEngineVersion,
        type: 'PREPAYMENT',
      );

      // Save loan update
      await repo.updateLoan(
        widget.loan.id,
        nameCtrl.text,
        selectedType,
        double.tryParse(totalCtrl.text) ?? 0.0,
        newBalance,
        double.tryParse(emiCtrl.text) ?? 0.0,
        double.tryParse(rateCtrl.text) ?? 0.0,
        dueCtrl.text,
      );

      if (mounted) {
        ref.invalidate(dashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Prepayment of ${CurrencyFormatter.format(result)} recorded.")));
        Navigator.pop(context);
      }
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

  Future<void> _reconcileWithBank(
      double appTotal, double appPrincipal, double appInterest) async {
    final bankPrincipalCtrl = TextEditingController();
    final bankInterestCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bankP = double.tryParse(bankPrincipalCtrl.text) ?? 0.0;
          final bankI = double.tryParse(bankInterestCtrl.text) ?? 0.0;
          final bankTotal = bankP + bankI;
          final diff = appTotal - bankTotal;

          return AlertDialog(
            title: const Text("RECONCILE WITH BANK"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    "Enter the figures from your bank statement to see the difference.",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildField("BANK'S PRINCIPAL", bankPrincipalCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    prefix: CurrencyFormatter.symbol),
                const SizedBox(height: 12),
                _buildField("BANK'S INTEREST", bankInterestCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true),
                    prefix: CurrencyFormatter.symbol),
                const Divider(height: 32),
                _rowSmall("TrueLedger Total", appTotal),
                _rowSmall("Bank Reported Total", bankTotal),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Difference",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(CurrencyFormatter.format(diff, compact: false),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: diff.abs() < 1 ? Colors.green : Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                if (diff.abs() > 0)
                  Text(
                      "Reason: ${diff.abs() < 2 ? 'Likely rounding difference or daily accrual time mismatch.' : 'Check if bank interest rate or payment dates match exactly.'}",
                      style: const TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CLOSE")),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportStatement() async {
    final repo = ref.read(financialRepositoryProvider);
    final logs = await repo.getLoanAuditLog(widget.loan.id);

    if (!mounted) return;

    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No audit logs found to export.")));
      return;
    }

    List<List<dynamic>> rows = [];
    // Header
    rows.add([
      "Date",
      "Type",
      "Opening Balance",
      "Interest Rate (%)",
      "Payment Amount",
      "Days Accrued",
      "Interest Accrued",
      "Principal Applied",
      "Closing Balance",
      "Engine Version"
    ]);

    for (var log in logs) {
      rows.add([
        log['date'],
        log['type'],
        log['opening_balance'],
        log['interest_rate'],
        log['payment_amount'],
        log['days_accrued'],
        log['interest_accrued'],
        log['principal_applied'],
        log['closing_balance'],
        log['engine_version'],
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final String fileName =
        "TrueLedger_${widget.loan.name.replaceAll(' ', '_')}_Statement.csv";

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(csv.codeUnits),
            name: fileName,
            mimeType: 'text/csv',
          )
        ],
        subject: "Amortization Statement for ${widget.loan.name}",
      ),
    );
  }

  Future<void> _save() async {
    final emi = double.tryParse(emiCtrl.text) ?? 0.0;
    final rate = double.tryParse(rateCtrl.text) ?? 0.0;
    final total = double.tryParse(totalCtrl.text) ?? 0.0;
    final remaining = double.tryParse(remainingCtrl.text) ?? 0.0;

    // Phase 5 Invariants
    if (emi <= 0 && selectedType != 'Individual') {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("EMI amount must be greater than 0")));
      return;
    }
    if (rate < 0 || rate > 60) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Interest rate must be between 0% and 60%")));
      return;
    }
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
      emi,
      rate,
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
