import 'package:flutter/material.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/constants/widget_keys.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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

  String _getTypeLabel(String t, AppLocalizations l10n) {
    switch (t) {
      case 'Variable':
        return l10n.variable;
      case 'Fixed':
        return l10n.fixed;
      case 'Income':
        return l10n.income;
      case 'Investment':
        return l10n.investments;
      case 'Subscription':
        return l10n.subscription;
      default:
        return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        title: Text(l10n.editTypeEntry(
            _getTypeLabel(widget.entry.type, l10n).toUpperCase())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            key: WidgetKeys.deleteButton,
            onPressed: () => _confirmDelete(l10n),
            icon: Icon(
              Icons.delete_outline,
              color: semantic.overspent.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAmountHeader(semantic, l10n),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.entry.type == 'Income'
                              ? l10n.sourceLabel
                              : l10n.labelLabel,
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
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: categories.map((cat) {
                                    final active = labelCtrl.text == cat.name;
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                          canvasColor: Colors.transparent),
                                      child: ChoiceChip(
                                        label: Text(cat.name.toUpperCase()),
                                        selected: active,
                                        onSelected: (_) => setState(() {
                                          labelCtrl.text = cat.name;
                                        }),
                                        backgroundColor: semantic
                                            .surfaceCombined
                                            .withValues(alpha: 0.3),
                                        selectedColor: semantic.primary
                                            .withValues(alpha: 0.1),
                                        side: BorderSide(
                                            color: active
                                                ? semantic.primary
                                                : semantic.divider,
                                            width: 1.5),
                                        labelStyle: TextStyle(
                                            color: active
                                                ? semantic.primary
                                                : semantic.secondaryText,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 0.5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        showCheckmark: false,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
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
                        Text(l10n.noteLabel,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.grey)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: noteCtrl,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: semantic.text),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: semantic.surfaceCombined
                                  .withValues(alpha: 0.5),
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
                          key: WidgetKeys.saveButton,
                          onPressed: () => _update(l10n),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: semantic.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Text(l10n.updateEntry,
                              style: const TextStyle(
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
        ),
      ),
    );
  }

  Widget _buildAmountHeader(AppColors semantic, AppLocalizations l10n) {
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
          Text(l10n.amountLabel,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.grey)),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Future<void> _update(AppLocalizations l10n) async {
    final repo = ref.read(financialRepositoryProvider);
    final Map<String, dynamic> updates = {};
    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.entryUpdated),
          behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(l10n.deleteItemTitle),
              content: Text(l10n.deleteItemContent),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.keep)),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.delete,
                        style: const TextStyle(color: Colors.grey))),
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
            content: Text(l10n.itemDeleted),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: l10n.undo,
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
