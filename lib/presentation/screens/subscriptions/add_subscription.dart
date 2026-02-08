import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final Subscription? subscription;
  const AddSubscriptionScreen({super.key, this.subscription});

  @override
  ConsumerState<AddSubscriptionScreen> createState() =>
      _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.subscription != null) {
      nameCtrl.text = widget.subscription!.name;
      amountCtrl.text = widget.subscription!.amount.toString();

      // Try parsing ISO date, fallback to raw text if legacy
      try {
        final date = DateTime.parse(widget.subscription!.billingDate);
        _selectedDate = date;
        dateCtrl.text = DateFormat('dd-MM-yyyy').format(date);
      } catch (e) {
        // Fallback for legacy "5th" etc
        dateCtrl.text = widget.subscription!.billingDate;
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
        dateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.subscription == null
              ? "New Subscription"
              : "Edit Subscription")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: "Service Name (e.g. Netflix)"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Monthly Amount",
                prefixText: "${CurrencyFormatter.symbol} ",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: "Billing Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(widget.subscription == null
                    ? "SAVE SUBSCRIPTION"
                    : "UPDATE SUBSCRIPTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (nameCtrl.text.isEmpty ||
        amountCtrl.text.isEmpty ||
        dateCtrl.text.isEmpty) {
      return;
    }
    final repo = ref.read(financialRepositoryProvider);
    final amount = double.parse(amountCtrl.text);

    // Store ISO string if date selected, else raw text (legacy fallback)
    final billingDate = _selectedDate?.toIso8601String() ?? dateCtrl.text;

    if (widget.subscription == null) {
      await repo.addSubscription(nameCtrl.text, amount, billingDate);
    } else {
      await repo.updateEntry('Subscription', widget.subscription!.id, {
        'name': nameCtrl.text,
        'amount': amount,
        'billing_date': billingDate
      });
    }

    if (mounted) Navigator.pop(context);
  }
}
