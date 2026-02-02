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
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final displayedTypes = widget.allowedTypes ??
        ['Variable', 'Fixed', 'Income', 'Investment', 'Subscription'];
    final bool isLocked = displayedTypes.length <= 1;

    final categoriesAsync = ref.watch(categoriesProvider(type));

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
                          selectedCategory = ''; // Reset when type changes
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
                    final addedAmount = int.tryParse(amountCtrl.text) ?? 0;
                    final totalAfter = currentSpent + addedAmount;
                    final limit = budget.monthlyLimit;
                    final progress = (totalAfter / limit).clamp(0.0, 1.0);
                    final isExceeded = totalAfter > limit;

                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isExceeded
                                    ? semantic.overspent
                                    : Colors.transparent,
                                width: 1)),
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
                                        color: colorScheme.onSurfaceVariant)),
                                Text(
                                    "${((totalAfter / limit) * 100).toStringAsFixed(0)}%",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: isExceeded
                                            ? semantic.overspent
                                            : semantic.income)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: colorScheme.surface,
                              color: isExceeded
                                  ? semantic.overspent
                                  : semantic.income,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isExceeded
                                  ? "This entry will exceed your ${budget.category} budget by ${CurrencyFormatter.format(totalAfter - limit)}."
                                  : "Remaining after this: ${CurrencyFormatter.format(limit - totalAfter)}",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isExceeded
                                      ? semantic.overspent
                                      : colorScheme.onSurface),
                            )
                          ],
                        ),
                      ).animate().fadeIn(),
                    );
                  },
                  orElse: () => const SizedBox.shrink());
            }),
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
            categoriesAsync.when(
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

                // If selectedCategory is empty or not in the list, set it to the first one
                if (selectedCategory.isEmpty ||
                    !categories.any((c) => c.name == selectedCategory)) {
                  // We use postFrameCallback to avoid setstate during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        selectedCategory = categories.first.name;
                      });
                    }
                  });
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...categories.map((cat) {
                      final active = selectedCategory == cat.name;
                      return ActionChip(
                        label: Text(cat.name.toUpperCase()),
                        onPressed: () =>
                            setState(() => selectedCategory = cat.name),
                        backgroundColor: active
                            ? colorScheme.onSurface.withValues(alpha: 0.05)
                            : Colors.transparent,
                        side: BorderSide(
                            color: active
                                ? colorScheme.onSurface
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.05)),
                        labelStyle: TextStyle(
                            color: colorScheme.onSurface,
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
                      side: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1)),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text("Error loading categories: $err"),
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
