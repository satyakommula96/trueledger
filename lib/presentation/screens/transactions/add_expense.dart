import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/core/utils/hash_utils.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';

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
    final allowed = widget.allowedTypes ??
        ['Variable', 'Fixed', 'Income', 'Investment', 'Subscription'];
    if (widget.initialType != null && allowed.contains(widget.initialType)) {
      type = widget.initialType!;
    } else {
      type = allowed.first;
    }

    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    } else {
      selectedCategory = ''; // Will be set when categories load
    }

    amountCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final displayedTypes = widget.allowedTypes ??
        ['Variable', 'Fixed', 'Income', 'Investment', 'Subscription'];
    final bool isLocked = displayedTypes.length <= 1;

    final categoriesAsync = ref.watch(categoriesProvider(type));

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isLocked ? "NEW ${type.toUpperCase()}" : "NEW LEDGER ENTRY",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            32, 24, 32, 32 + MediaQuery.of(context).padding.bottom),
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
                physics: const BouncingScrollPhysics(),
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
                          selectedCategory = ''; // Reset when type changes
                        }),
                        selectedColor:
                            isIncome ? semantic.income : semantic.primary,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        showCheckmark: false,
                        side: BorderSide(
                            color: active
                                ? (isIncome
                                    ? semantic.income
                                    : semantic.primary)
                                : semantic.divider),
                        labelStyle: TextStyle(
                            color: active ? Colors.black : semantic.text,
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 56,
                  letterSpacing: -3,
                  color: type == 'Income' ? semantic.income : semantic.text),
              decoration: InputDecoration(
                  prefixText: "${CurrencyFormatter.symbol} ",
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: TextStyle(
                      color: semantic.secondaryText.withValues(alpha: 0.1))),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

            // Optimistic Budget Overlay
            Consumer(builder: (context, ref, _) {
              if (type != 'Variable') return const SizedBox.shrink();
              final dashboardAsync = ref.watch(dashboardProvider);
              return dashboardAsync.maybeWhen(
                  data: (data) {
                    final budget = data.budgets.firstWhere(
                        (b) => b.category == selectedCategory,
                        orElse: () => Budget(
                            id: -1, category: '', monthlyLimit: 0, spent: 0));

                    if (budget.id == -1) return const SizedBox.shrink();

                    final currentSpent = budget.spent;
                    final addedAmount = double.tryParse(amountCtrl.text) ?? 0.0;
                    final totalAfter = currentSpent + addedAmount;
                    final limit = budget.monthlyLimit;
                    final progress =
                        limit > 0 ? (totalAfter / limit).clamp(0.0, 1.0) : 0.0;
                    final isExceeded = totalAfter > limit;
                    final color =
                        isExceeded ? semantic.overspent : semantic.income;

                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: color.withValues(alpha: 0.2),
                                width: 1.5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("BUDGET IMPACT",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: semantic.secondaryText)),
                                Text(
                                    "${((totalAfter / limit) * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: color)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                    semantic.divider.withValues(alpha: 0.1),
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isExceeded
                                  ? "EXCEEDS BUDGET BY ${CurrencyFormatter.format(totalAfter - limit)}"
                                  : "REMAINING: ${CurrencyFormatter.format(limit - totalAfter)}",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: color),
                            )
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.98, 0.98)),
                    );
                  },
                  orElse: () => const SizedBox.shrink());
            }),
            const SizedBox(height: 24),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.divider.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: semantic.secondaryText),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate.day == DateTime.now().day &&
                              _selectedDate.month == DateTime.now().month &&
                              _selectedDate.year == DateTime.now().year
                          ? "TODAY"
                          : "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          fontSize: 10),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 48),
            const Text("CATEGORY CLASSIFICATION",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.grey)),
            const SizedBox(height: 20),
            categoriesAsync
                .when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return TextButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ManageCategoriesScreen())),
                        icon: const Icon(Icons.add),
                        label: const Text("MANAGE CATEGORIES"),
                      );
                    }

                    if (selectedCategory.isEmpty ||
                        !categories.any((c) => c.name == selectedCategory)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && categories.isNotEmpty) {
                          setState(() {
                            selectedCategory = categories.first.name;
                          });
                        }
                      });
                    }

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...categories.map((cat) {
                          final active = selectedCategory == cat.name;
                          return ActionChip(
                            label: Text(cat.name.toUpperCase()),
                            onPressed: () =>
                                setState(() => selectedCategory = cat.name),
                            backgroundColor:
                                active ? semantic.primary : Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(
                                color: active
                                    ? semantic.primary
                                    : semantic.divider),
                            labelStyle: TextStyle(
                                color: active ? Colors.black : semantic.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 1),
                          );
                        }),
                        ActionChip(
                          label: const Icon(Icons.add, size: 16),
                          onPressed: () async {
                            final newCat = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ManageCategoriesScreen(initialType: type),
                              ),
                            );
                            if (newCat != null && mounted) {
                              setState(() => selectedCategory = newCat);
                            }
                          },
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: semantic.divider),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text("Error loading categories: $err"),
                )
                .animate(delay: 300.ms)
                .fadeIn(),
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
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: semantic.text),
              decoration: InputDecoration(
                hintText: "Optional details...",
                filled: true,
                fillColor: semantic.surfaceCombined.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: semantic.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: semantic.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: semantic.primary, width: 2)),
                hintStyle: TextStyle(
                    color: semantic.secondaryText.withValues(alpha: 0.1)),
              ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      type == 'Income' ? semantic.income : semantic.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("COMMIT TO LEDGER",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
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

    final amount = double.tryParse(amountText);
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
      final transactionResult = (result as Success<AddTransactionResult>).value;
      final notificationService = ref.read(notificationServiceProvider);

      if (transactionResult.cancelDailyReminder) {
        await notificationService
            .cancelNotification(NotificationService.dailyReminderId);
      }

      final warning = transactionResult.budgetWarning;
      if (warning != null) {
        final title = warning.type == NotificationType.budgetExceeded
            ? 'Budget Exceeded: ${warning.category}'
            : 'Budget Warning: ${warning.category}';
        final body = warning.type == NotificationType.budgetExceeded
            ? 'You have spent 100% of your ${warning.category} budget.'
            : 'You have reached ${warning.percentage.round()}% of your ${warning.category} budget.';

        // Generate a stable ID locally
        final id = generateStableHash('${warning.category}_budget_alert');

        await notificationService.showNotification(
          id: id,
          title: title,
          body: body,
        );
      }

      ref.invalidate(dashboardProvider);
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failureOrThrow.message)));
    }
  }
}
