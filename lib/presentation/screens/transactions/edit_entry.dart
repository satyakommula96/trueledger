import 'package:flutter/material.dart';
import 'package:trueledger/domain/models/models.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        title: Text("EDIT ${widget.entry.type.toUpperCase()}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: Icon(
              Icons.delete_outline,
              color: semantic.overspent.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAmountHeader(semantic),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.entry.type == 'Income' ? "SOURCE" : "LABEL",
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelCtrl,
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: semantic.text),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            semantic.surfaceCombined.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: semantic.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: semantic.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: semantic.primary),
                        )),
                  ),
                  if (widget.entry.type == 'Variable') ...[
                    const SizedBox(height: 20),
                    Consumer(
                      builder: (context, ref, child) {
                        final categoriesAsync =
                            ref.watch(categoriesProvider('Variable'));
                        return categoriesAsync.when(
                          data: (categories) {
                            if (categories.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categories.map((cat) {
                                final active = labelCtrl.text == cat.name;
                                return ActionChip(
                                  label: Text(cat.name.toUpperCase()),
                                  onPressed: () => setState(() {
                                    labelCtrl.text = cat.name;
                                  }),
                                  backgroundColor: active
                                      ? semantic.primary
                                      : Colors.transparent,
                                  side: BorderSide(
                                      color: active
                                          ? semantic.primary
                                          : semantic.divider),
                                  labelStyle: TextStyle(
                                      color:
                                          active ? Colors.black : semantic.text,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9,
                                      letterSpacing: 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (err, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    const Text("NOTE",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteCtrl,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: semantic.text),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              semantic.surfaceCombined.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: semantic.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: semantic.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: semantic.primary),
                          )),
                    ),
                  ],
                  const SizedBox(height: 64),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _update,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: semantic.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader(AppColors semantic) {
    final isIncome = widget.entry.type == 'Income';
    final displayColor = isIncome ? semantic.income : semantic.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        border: Border(bottom: BorderSide(color: semantic.divider)),
      ),
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
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 56,
                letterSpacing: -3,
                color: displayColor),
            decoration: InputDecoration(
                prefixText: "${CurrencyFormatter.symbol} ",
                prefixStyle: TextStyle(
                    color: displayColor.withValues(alpha: 0.3),
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
                border: InputBorder.none),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
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
      ref.invalidate(dashboardProvider);
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
      if (mounted) {
        ref.invalidate(dashboardProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Item deleted"),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "UNDO",
              onPressed: () async {
                // Re-add the item using repository methods
                // Since IFinancialRepository doesn't have a 'restore' method,
                // we'll just handle it as a new entry for now.
                // NOTE: This might assign a NEW ID, but for variable expenses it's fine.
                await repo.addEntry(
                  widget.entry.type,
                  widget.entry.amount,
                  widget.entry.label,
                  widget.entry.note ?? '',
                  widget.entry.date,
                );
                ref.invalidate(dashboardProvider);
              },
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}
