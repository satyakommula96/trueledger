import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';

class AddExpense extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialCategory;
  final List<String>? allowedTypes;
  const AddExpense(
      {super.key, this.initialType, this.initialCategory, this.allowedTypes});

  @override
  ConsumerState<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends ConsumerState<AddExpense> {
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String selectedCategory = 'General';
  String type = 'Variable';
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final allowed = widget.allowedTypes ?? categoryMap.keys.toList();
    if (widget.initialType != null &&
        categoryMap.containsKey(widget.initialType) &&
        allowed.contains(widget.initialType)) {
      type = widget.initialType!;
    } else {
      type = allowed.first;
    }

    // Set initial category if valid for selected type
    if (widget.initialCategory != null &&
        categoryMap[type]!.contains(widget.initialCategory)) {
      selectedCategory = widget.initialCategory!;
    } else {
      selectedCategory = categoryMap[type]!.first;
    }
  }

  final Map<String, List<String>> categoryMap = {
    'Variable': ['Food', 'Transport', 'Shopping', 'Entertainment', 'Others'],
    'Fixed': ['Rent', 'Utility', 'Insurance', 'EMI'],
    'Investment': [
      'Stocks',
      'Mutual Funds',
      'SIP',
      'Crypto',
      'Gold',
      'Lending',
      'Retirement',
      'Other'
    ],
    'Income': ['Salary', 'Freelance', 'Dividends'],
    'Subscription': ['OTT', 'Software', 'Gym'],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final displayedTypes = widget.allowedTypes ?? categoryMap.keys.toList();
    final bool isLocked = displayedTypes.length <= 1;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              isLocked ? "NEW ${type.toUpperCase()}" : "NEW LEDGER ENTRY")),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            32, 32, 32, 32 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLocked) ...[
              const Text("ENTRY TYPE",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.grey)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: displayedTypes.map((t) {
                    final active = type == t;
                    final isIncome = t == 'Income';
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(t.toUpperCase()),
                        selected: active,
                        onSelected: (_) => setState(() {
                          type = t;
                          selectedCategory = categoryMap[t]![0];
                        }),
                        selectedColor:
                            isIncome ? semantic.income : colorScheme.onSurface,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                            color: active
                                ? (isIncome
                                    ? semantic.income
                                    : colorScheme.onSurface)
                                : colorScheme.onSurface.withValues(alpha: 0.1)),
                        labelStyle: TextStyle(
                            color: active
                                ? colorScheme.surface
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 48),
            ],
            const Text("TRANSACTION AMOUNT",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 48,
                  letterSpacing: -2,
                  color: type == 'Income'
                      ? semantic.income
                      : colorScheme.onSurface),
              decoration: InputDecoration(
                  prefixText: "${CurrencyFormatter.symbol} ",
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.1))),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate.day == DateTime.now().day &&
                              _selectedDate.month == DateTime.now().month &&
                              _selectedDate.year == DateTime.now().year
                          ? "Today"
                          : "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Text("CATEGORY CLASSIFICATION",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryMap[type]!.map((cat) {
                final active = selectedCategory == cat;
                return ActionChip(
                  label: Text(cat.toUpperCase()),
                  onPressed: () => setState(() => selectedCategory = cat),
                  backgroundColor: active
                      ? colorScheme.onSurface.withValues(alpha: 0.05)
                      : Colors.transparent,
                  side: BorderSide(
                      color: active
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.05)),
                  labelStyle: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            const Text("AUDIT NOTES",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                hintText: "Optional details...",
                filled: true,
                fillColor: colorScheme.onSurface.withValues(alpha: 0.02),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.1)),
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'Income'
                      ? semantic.income
                      : colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("COMMIT TO LEDGER",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amountText = amountCtrl.text;
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter an amount")));
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid positive amount")));
      return;
    }

    final addTransaction = ref.read(addTransactionUseCaseProvider);
    final result = await addTransaction(AddTransactionParams(
      type: type,
      amount: amount,
      category: selectedCategory,
      note: noteCtrl.text,
      date: _selectedDate.toIso8601String(),
    ));

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }
}
