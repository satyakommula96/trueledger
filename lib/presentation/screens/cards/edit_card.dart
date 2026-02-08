import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';

class EditCreditCardScreen extends ConsumerStatefulWidget {
  final CreditCard card;
  const EditCreditCardScreen({super.key, required this.card});

  @override
  ConsumerState<EditCreditCardScreen> createState() =>
      _EditCreditCardScreenState();
}

class _EditCreditCardScreenState extends ConsumerState<EditCreditCardScreen> {
  late TextEditingController bankCtrl;
  late TextEditingController limitCtrl;
  late TextEditingController stmtCtrl;
  late TextEditingController minDueCtrl;
  late TextEditingController dueDateCtrl;
  late TextEditingController genDateCtrl;
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
        dueDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
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
        genDateCtrl.text = 'Day ${picked.day}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    bankCtrl = TextEditingController(text: widget.card.bank);
    limitCtrl = TextEditingController(text: widget.card.creditLimit.toString());
    stmtCtrl =
        TextEditingController(text: widget.card.statementBalance.toString());
    minDueCtrl = TextEditingController(text: widget.card.minDue.toString());
    dueDateCtrl = TextEditingController(text: widget.card.dueDate);
    genDateCtrl = TextEditingController(text: widget.card.statementDate);
    try {
      _selectedDueDate = DateFormat('dd-MM-yyyy').parse(widget.card.dueDate);
    } catch (_) {
      try {
        _selectedDueDate = DateFormat('dd-MM-yy').parse(widget.card.dueDate);
      } catch (_) {}
    }
    if (widget.card.statementDate.isNotEmpty) {
      if (widget.card.statementDate.startsWith('Day ')) {
        final day = int.tryParse(widget.card.statementDate.split(' ')[1]);
        if (day != null) {
          final now = DateTime.now();
          _selectedGenDate = DateTime(now.year, now.month, day);
        }
      } else {
        // Fallback for old format
        try {
          _selectedGenDate =
              DateFormat('dd-MM-yyyy').parse(widget.card.statementDate);
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Credit Card"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildField("Bank Name", bankCtrl, Icons.account_balance),
            _buildField("Credit Limit", limitCtrl, Icons.speed,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField(
                "Statement Balance", stmtCtrl, Icons.account_balance_wallet,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField("Minimum Due", minDueCtrl, Icons.low_priority,
                isNumber: true, prefix: CurrencyFormatter.symbol),
            _buildField(
                "Statement Date (Every Month)", genDateCtrl, Icons.event,
                readOnly: true, onTap: _pickGenDate),
            _buildField("Payment Due Date", dueDateCtrl, Icons.calendar_today,
                readOnly: true, onTap: _pickDueDate),
            const SizedBox(height: 20),

            // New Bill Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text("NEW BILL GENERATED?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: colorScheme.primary,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                      "Update the statement details below for the new billing cycle.",
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("UPDATE CARD",
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

  Future<void> _update() async {
    if (bankCtrl.text.isEmpty || limitCtrl.text.isEmpty) return;
    final repo = ref.read(financialRepositoryProvider);
    final limit = double.tryParse(limitCtrl.text) ?? 0.0;
    final balance = double.tryParse(stmtCtrl.text) ?? 0.0;

    if (balance > limit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Statement balance cannot exceed credit limit")));
      return;
    }

    await repo.updateCreditCard(
        widget.card.id,
        bankCtrl.text,
        limit,
        balance,
        double.tryParse(minDueCtrl.text) ?? 0.0,
        dueDateCtrl.text,
        genDateCtrl.text);

    // Trigger notification
    final reminderDate = _selectedGenDate ?? _selectedDueDate;
    if (reminderDate != null) {
      await ref
          .read(notificationServiceProvider)
          .scheduleCreditCardReminder(bankCtrl.text, reminderDate.day);
      ref.invalidate(pendingNotificationsProvider);
      ref.invalidate(pendingNotificationCountProvider);
    }
    if (mounted) {
      ref.invalidate(dashboardProvider);
      ref.invalidate(pendingNotificationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Card Details Updated"),
          behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card?"),
        content: const Text(
            "This will permanently remove this card from your list."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(financialRepositoryProvider);
      await repo.deleteItem('credit_cards', widget.card.id);
      if (mounted) {
        ref.invalidate(dashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Card Deleted"),
            behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    }
  }
}
