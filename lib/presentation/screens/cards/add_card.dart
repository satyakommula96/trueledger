import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';

class AddCreditCardScreen extends ConsumerStatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  ConsumerState<AddCreditCardScreen> createState() =>
      _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends ConsumerState<AddCreditCardScreen> {
  final bankCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final stmtCtrl = TextEditingController(); // Billed balance
  final currentCtrl = TextEditingController(); // Total outstanding balance
  final minDueCtrl = TextEditingController();
  final dueDateCtrl = TextEditingController();
  final genDateCtrl = TextEditingController();
  DateTime? _selectedGenDate;
  int? _dueDay;
  int? _genDay;

  Future<void> _pickDueDate() async {
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
        _dueDay = picked;
        final ordinal = DateHelper.getOrdinal(picked);
        dueDateCtrl.text = '$picked$ordinal of month';
      });
    }
  }

  Future<void> _pickGenDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedGenDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedGenDate = picked;
        _genDay = picked.day;
        genDateCtrl.text =
            '${picked.day}${DateHelper.getOrdinal(picked.day)} of month';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Credit Card")),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildField("Bank Name", bankCtrl, Icons.account_balance),
            _buildField("Credit Limit", limitCtrl, Icons.speed,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField(
                "Last Statement Balance (Billed)", stmtCtrl, Icons.receipt_long,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField("Current Outstanding Balance (Total Used)", currentCtrl,
                Icons.account_balance_wallet,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField("Minimum Due", minDueCtrl, Icons.low_priority,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField(
                "Statement Date (Every Month)", genDateCtrl, Icons.event,
                readOnly: true, onTap: _pickGenDate),
            _buildField("Payment Due Date", dueDateCtrl, Icons.calendar_today,
                readOnly: true, onTap: _pickDueDate),
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
      {bool isNumber = false,
      String? prefix,
      bool readOnly = false,
      VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixText: prefix != null ? "$prefix " : null,
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
    final repo = ref.read(financialRepositoryProvider);
    final limit = double.tryParse(limitCtrl.text) ?? 0.0;
    final stmtBalance = double.tryParse(stmtCtrl.text) ?? 0.0;
    final currentBalance = double.tryParse(currentCtrl.text) ??
        stmtBalance; // Default to stmt if empty? Or 0? Let's default to stmtBalance because usually Current >= Stmt

    if (currentBalance > limit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Current balance cannot exceed credit limit")));
      return;
    }

    await repo.addCreditCard(
        bankCtrl.text,
        limit,
        stmtBalance,
        double.tryParse(minDueCtrl.text) ?? 0.0,
        dueDateCtrl.text,
        genDateCtrl.text,
        currentBalance); // New param

    // Trigger notification
    // Trigger notification based on Due Date if available, else Gen Date
    final reminderDay = _dueDay ?? _genDay;
    if (reminderDay != null) {
      await ref
          .read(notificationServiceProvider)
          .scheduleCreditCardReminder(bankCtrl.text, reminderDay);
    }
    if (mounted) {
      ref.invalidate(dashboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Credit Card Added"),
          behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }
}
