import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/services/notification_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class AddCreditCardScreen extends ConsumerStatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  ConsumerState<AddCreditCardScreen> createState() =>
      _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends ConsumerState<AddCreditCardScreen> {
  final bankCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final stmtCtrl = TextEditingController();
  final minDueCtrl = TextEditingController();
  final dueDateCtrl = TextEditingController();
  final genDateCtrl = TextEditingController();
  DateTime? _selectedDueDate;
  DateTime? _selectedGenDate;

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        dueDateCtrl.text = DateFormat('dd MMM yyyy').format(picked);
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
        genDateCtrl.text = DateFormat('dd MMM yyyy').format(picked);
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
                isNumber: true, prefix: CurrencyHelper.symbol),
            _buildField(
                "Statement Balance", stmtCtrl, Icons.account_balance_wallet,
                isNumber: true, prefix: CurrencyHelper.symbol),
            _buildField("Minimum Due", minDueCtrl, Icons.low_priority,
                isNumber: true, prefix: CurrencyHelper.symbol),
            _buildField("Statement Generation Date", genDateCtrl, Icons.event,
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
    await repo.addCreditCard(
        bankCtrl.text,
        int.tryParse(limitCtrl.text) ?? 0,
        int.tryParse(stmtCtrl.text) ?? 0,
        int.tryParse(minDueCtrl.text) ?? 0,
        dueDateCtrl.text,
        genDateCtrl.text);

    // Trigger notification
    if (_selectedGenDate != null) {
      await NotificationService()
          .scheduleCreditCardReminder(bankCtrl.text, _selectedGenDate!.day);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Credit Card Added"),
          behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }
}
