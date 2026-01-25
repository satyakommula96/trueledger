import 'package:flutter/material.dart';
import 'package:truecash/domain/models/models.dart';

import 'package:truecash/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final LedgerItem entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late TextEditingController amountCtrl;
  late TextEditingController labelCtrl;
  late TextEditingController noteCtrl;
  late String category;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.entry.amount.toString());
    labelCtrl = TextEditingController(text: widget.entry.label);
    noteCtrl = TextEditingController(text: widget.entry.note ?? '');
    category = widget.entry.type == 'Variable'
        ? widget.entry.label
        : widget.entry.type; // category is barely used or unused?
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT ${widget.entry.type.toUpperCase()}"),
        actions: [
          IconButton(
              onPressed: _confirmDelete,
              icon: Icon(Icons.delete_outline,
                  color: colorScheme.onSurface.withValues(alpha: 0.3))),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AMOUNT",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 48, letterSpacing: -2),
              decoration: InputDecoration(
                  prefixText: "${CurrencyFormatter.symbol} ",
                  border: InputBorder.none),
            ),
            const SizedBox(height: 48),
            Text(widget.entry.type == 'Income' ? "SOURCE" : "LABEL",
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.entry.type == 'Variable') ...[
              const SizedBox(height: 48),
              const Text("NOTE",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.grey)),
              TextField(
                controller: noteCtrl,
                decoration:
                    const InputDecoration(border: UnderlineInputBorder()),
              ),
            ],
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("UPDATE ENTRY",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    final repo = ref.read(financialRepositoryProvider);
    final Map<String, dynamic> updates = {};
    final amount = int.tryParse(amountCtrl.text) ?? 0;
    if (widget.entry.type == 'Variable') {
      updates['amount'] = amount;
      updates['category'] = labelCtrl.text;
      updates['note'] = noteCtrl.text;
    } else if (widget.entry.type == 'Income') {
      updates['amount'] = amount;
      updates['source'] = labelCtrl.text;
    } else {
      updates['amount'] = amount;
      updates['name'] = labelCtrl.text;
    }

    await repo.updateEntry(widget.entry.type, widget.entry.id, updates);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Entry updated"), behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("DELETE ITEM?"),
              content: const Text("This action cannot be undone."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("KEEP")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("DELETE",
                        style: TextStyle(color: Colors.grey))),
              ],
            ));
    if (confirmed == true) {
      final repo = ref.read(financialRepositoryProvider);
      String table = "";
      switch (widget.entry.type) {
        case 'Variable':
          table = 'variable_expenses';
          break;
        case 'Income':
          table = 'income_sources';
          break;
        case 'Fixed':
          table = 'fixed_expenses';
          break;
        case 'Investment':
          table = 'investments';
          break;
        case 'Subscription':
          table = 'subscriptions';
          break;
      }
      await repo.deleteItem(table, widget.entry.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
