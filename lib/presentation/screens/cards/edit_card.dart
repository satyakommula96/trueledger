import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';

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
  late TextEditingController currentCtrl;
  late TextEditingController minDueCtrl;
  late TextEditingController dueDateCtrl;
  late TextEditingController genDateCtrl;
  DateTime? _selectedDueDate;
  DateTime? _selectedGenDate;
  int? _dueDay;
  int? _genDay;
  List<LedgerItem> _history = [];
  bool _isLoadingHistory = true;
  bool _showAllHistory = false;

  Future<void> _updateTag(LedgerItem item, TransactionTag tag) async {
    final repo = ref.read(financialRepositoryProvider);
    final newTags = Set<TransactionTag>.from(item.tags);

    if (tag == TransactionTag.transfer) {
      newTags.remove(TransactionTag.creditCardPayment);
      if (newTags.isEmpty) newTags.add(TransactionTag.transfer);
    } else {
      if (newTags.contains(tag)) {
        newTags.remove(tag);
      } else {
        newTags.add(tag);
        newTags.remove(TransactionTag.transfer);
      }
    }

    await repo.updateEntryTags(item.type, item.id, newTags);
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    final repo = ref.read(financialRepositoryProvider);

    final all = await repo.getTransactionsForRange(
        DateTime.now().subtract(const Duration(days: 365)), DateTime.now());

    final filtered = all.where((item) {
      if (item.tags.contains(TransactionTag.income)) return false;

      final text = "${item.label} ${item.note ?? ''}".toLowerCase();
      final bank = widget.card.bank.toLowerCase();

      final hasTag = item.tags.contains(TransactionTag.creditCardPayment);

      if (hasTag) {
        return text.contains(bank);
      }

      if (!text.contains(bank)) return false;

      bool containsAny(List<String> keywords) => keywords.any(text.contains);

      final isExplicitPayment = containsAny([
        'payment',
        'cc bill',
        'card payment',
        'settle',
      ]);

      return isExplicitPayment;
    }).toList();

    if (mounted) {
      setState(() {
        _history = filtered;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _recordPayment() async {
    final controller = TextEditingController(
        text: widget.card.statementBalance > 0
            ? widget.card.statementBalance.toString()
            : "");

    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("RECORD PAYMENT"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Amount",
                prefixText: "${CurrencyFormatter.symbol} ",
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
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text("RECORD"),
          ),
        ],
      ),
    );

    if (amount != null) {
      final repo = ref.read(financialRepositoryProvider);
      await repo.payCreditCardBill(widget.card.id, amount);
      _fetchHistory();
      ref.invalidate(dashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment recorded successfully.")));
      }
    }
  }

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
  void initState() {
    super.initState();
    bankCtrl = TextEditingController(text: widget.card.bank);
    limitCtrl = TextEditingController(text: widget.card.creditLimit.toString());
    stmtCtrl =
        TextEditingController(text: widget.card.statementBalance.toString());
    currentCtrl =
        TextEditingController(text: widget.card.currentBalance.toString());
    minDueCtrl = TextEditingController(text: widget.card.minDue.toString());
    dueDateCtrl = TextEditingController(text: widget.card.dueDate);
    genDateCtrl = TextEditingController(text: widget.card.statementDate);
    if (widget.card.dueDate.isNotEmpty) {
      if (widget.card.dueDate.contains(' ')) {
        final parts = widget.card.dueDate.split(' ');
        final dayStr = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        final day = int.tryParse(dayStr);
        if (day != null) {
          final now = DateTime.now();
          _selectedDueDate = DateTime(now.year, now.month, day);
          _dueDay = day;
        }
      } else {
        try {
          _selectedDueDate =
              DateFormat('dd-MM-yyyy').parse(widget.card.dueDate);
          // Auto-convert old full date to new "Xth of month" format in the field
          final day = _selectedDueDate!.day;
          _dueDay = day;
          dueDateCtrl.text = '$day${DateHelper.getOrdinal(day)} of month';
        } catch (_) {
          try {
            _selectedDueDate =
                DateFormat('dd-MM-yy').parse(widget.card.dueDate);
            final day = _selectedDueDate!.day;
            _dueDay = day;
            dueDateCtrl.text = '$day${DateHelper.getOrdinal(day)} of month';
          } catch (_) {}
        }
      }
    }
    if (widget.card.statementDate.isNotEmpty) {
      if (widget.card.statementDate.contains(' ')) {
        final parts = widget.card.statementDate.split(' ');
        String rawDay =
            widget.card.statementDate.startsWith('Day ') ? parts[1] : parts[0];
        final day = int.tryParse(rawDay.replaceAll(RegExp(r'[^0-9]'), ''));
        if (day != null) {
          final now = DateTime.now();
          _selectedGenDate = DateTime(now.year, now.month, day);
          _genDay = day;
          // Set text properly for the field if it was in the old format
          if (widget.card.statementDate.startsWith('Day ')) {
            genDateCtrl.text = '$day${DateHelper.getOrdinal(day)} of month';
          }
        }
      } else {
        // Fallback for old format
        try {
          _selectedGenDate =
              DateFormat('dd-MM-yyyy').parse(widget.card.statementDate);
        } catch (_) {}
      }
    }
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Credit Card", style: TextStyle(fontSize: 16)),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: stmtCtrl,
              builder: (context, value, _) {
                final balance = double.tryParse(value.text) ?? 0;
                final isPaid = balance <= 0;
                return Text(
                  isPaid ? "STATUS: PAID" : "STATUS: PENDING PAYMENT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Column(
              children: [
                _buildField("Bank Name", bankCtrl, Icons.account_balance),
                _buildField("Credit Limit", limitCtrl, Icons.speed,
                    isNumber: true, prefix: CurrencyFormatter.symbol),
                _buildField("Last Statement Balance (Billed)", stmtCtrl,
                    Icons.receipt_long,
                    isNumber: true, prefix: CurrencyFormatter.symbol),
                _buildField("Current Outstanding Balance (Total Used)",
                    currentCtrl, Icons.account_balance_wallet,
                    isNumber: true, prefix: CurrencyFormatter.symbol),
                _buildField("Minimum Due", minDueCtrl, Icons.low_priority,
                    isNumber: true, prefix: CurrencyFormatter.symbol),
                _buildField(
                    "Statement Date (Every Month)", genDateCtrl, Icons.event,
                    readOnly: true, onTap: _pickGenDate),
                _buildField(
                    "Payment Due Date", dueDateCtrl, Icons.calendar_today,
                    readOnly: true, onTap: _pickDueDate),
                const SizedBox(height: 20),
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    onPressed: _recordPayment,
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text("RECORD CARD PAYMENT",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("PAYMENT HISTORY",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.grey)),
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
                    itemCount: _showAllHistory
                        ? _history.length
                        : (_history.length > 10 ? 10 : _history.length),
                    separatorBuilder: (context, index) =>
                        Divider(color: semantic.divider, height: 1),
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final isCardPayment =
                          item.tags.contains(TransactionTag.creditCardPayment);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  if (item.tags.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 4,
                                      children: item.tags.map((t) {
                                        final isCc = t ==
                                            TransactionTag.creditCardPayment;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isCc
                                                ? Colors.blue
                                                    .withValues(alpha: 0.1)
                                                : Colors.grey
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isCc
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            t.name.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: isCc
                                                    ? Colors.blue
                                                    : Colors.grey),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(item.amount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.redAccent),
                                ),
                                const SizedBox(height: 8),
                                if (!isCardPayment)
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => _updateTag(
                                        item, TransactionTag.creditCardPayment),
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 14, color: Colors.blue),
                                    label: const Text("MARK AS PAYMENT",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900)),
                                  )
                                else
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: () => _updateTag(
                                        item, TransactionTag.transfer),
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        size: 14,
                                        color: Colors.grey),
                                    label: const Text("NOT A PAYMENT",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (_history.length > 10 && !_showAllHistory)
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showAllHistory = true),
                      child: Text("SHOW ALL (${_history.length} PAYMENTS)",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.primary)),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool isNumber = false,
      String? prefix,
      bool readOnly = false,
      VoidCallback? onTap}) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: semantic.text),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: semantic.secondaryText),
              prefixText: prefix != null ? "$prefix " : null,
              prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: semantic.text),
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
      ),
    );
  }

  Future<void> _update() async {
    if (bankCtrl.text.isEmpty || limitCtrl.text.isEmpty) return;
    final repo = ref.read(financialRepositoryProvider);
    final limit = double.tryParse(limitCtrl.text) ?? 0.0;
    final stmtBalance = double.tryParse(stmtCtrl.text) ?? 0.0;
    final currentBalance = double.tryParse(currentCtrl.text) ?? stmtBalance;

    if (currentBalance > limit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Current balance cannot exceed credit limit")));
      return;
    }

    await repo.updateCreditCard(
        widget.card.id,
        bankCtrl.text,
        limit,
        stmtBalance,
        double.tryParse(minDueCtrl.text) ?? 0.0,
        dueDateCtrl.text,
        genDateCtrl.text,
        currentBalance);

    // Trigger notification
    final reminderDay = _dueDay ?? _genDay;
    if (reminderDay != null) {
      await ref
          .read(notificationServiceProvider)
          .scheduleCreditCardReminder(bankCtrl.text, reminderDay);
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
