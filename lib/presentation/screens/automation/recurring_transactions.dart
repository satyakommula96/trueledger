import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/recurring_provider.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/core/constants/widget_keys.dart';

class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final recurringState = ref.watch(recurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AUTOMATION & RECURRING"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        key: WidgetKeys.addRecurringFab,
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: recurringState.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: semantic.primary)),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (items) => _buildBody(context, items, semantic, ref),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<RecurringTransaction> items,
      AppColors semantic, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 64, color: semantic.divider),
            const SizedBox(height: 24),
            Text(
              "NO AUTOMATED TRANSACTIONS YET.",
              style: TextStyle(
                color: semantic.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add rent, salary, or bills to automate your ledger.",
              style: TextStyle(
                  color: semantic.secondaryText.withValues(alpha: 0.6),
                  fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: WidgetKeys.recurringList,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildRecurringCard(context, item, semantic, ref, index);
      },
    );
  }

  Widget _buildRecurringCard(BuildContext context, RecurringTransaction item,
      AppColors semantic, WidgetRef ref, int index) {
    final isIncome = item.type == 'INCOME';
    final accentColor = isIncome ? semantic.income : semantic.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: HoverWrapper(
        onTap: () {},
        borderRadius: 24,
        child: Container(
          key: WidgetKeys.recurringItem(item.id),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: semantic.divider, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isIncome
                      ? Icons.keyboard_double_arrow_up_rounded
                      : Icons.keyboard_double_arrow_down_rounded,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: semantic.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildFrequencyText(item).toUpperCase(),
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                    if (item.lastProcessed != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "LAST: ${item.lastProcessed!.substring(0, 10)}",
                        style: TextStyle(
                            color: semantic.income.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w900),
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
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: accentColor),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    key: WidgetKeys.deleteButton,
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 18,
                        color: semantic.overspent.withValues(alpha: 0.5)),
                    onPressed: () {
                      ref.read(recurringProvider.notifier).delete(item.id);
                      ref.invalidate(dashboardProvider);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'EXPENSE';
    String frequency = 'MONTHLY';
    String category = 'Others';
    int dayOfMonth = 1;
    int dayOfWeek = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final semantic = Theme.of(context).extension<AppColors>()!;
          return Container(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: semantic.surfaceCombined,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NEW AUTOMATION",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 1,
                          color: semantic.text)),
                  const SizedBox(height: 24),
                  _buildField(semantic, "Label", Icons.label_outline_rounded,
                      nameController),
                  const SizedBox(height: 16),
                  _buildField(semantic, "Amount", Icons.attach_money_rounded,
                      amountController,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDropdown<String>(
                    semantic,
                    "Type",
                    Icons.swap_vert_rounded,
                    type,
                    ['EXPENSE', 'INCOME'],
                    (val) => setState(() => type = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown<String>(
                    semantic,
                    "Frequency",
                    Icons.repeat_rounded,
                    frequency,
                    ['DAILY', 'WEEKLY', 'MONTHLY'],
                    (val) => setState(() => frequency = val!),
                  ),
                  if (frequency == 'MONTHLY') ...[
                    const SizedBox(height: 16),
                    _buildDropdown<int>(
                      semantic,
                      "Day of Month",
                      Icons.calendar_today_rounded,
                      dayOfMonth,
                      List.generate(31, (i) => i + 1),
                      (val) => setState(() => dayOfMonth = val!),
                    ),
                  ],
                  if (frequency == 'WEEKLY') ...[
                    const SizedBox(height: 16),
                    _buildDropdown<int>(
                        semantic,
                        "Day of Week",
                        Icons.calendar_view_week_rounded,
                        dayOfWeek,
                        [1, 2, 3, 4, 5, 6, 7],
                        (val) => setState(() => dayOfWeek = val!),
                        labels: {
                          1: 'MON',
                          2: 'TUE',
                          3: 'WED',
                          4: 'THU',
                          5: 'FRI',
                          6: 'SAT',
                          7: 'SUN'
                        }),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      key: WidgetKeys.saveButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: semantic.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            amountController.text.isNotEmpty) {
                          ref.read(recurringProvider.notifier).add(
                                name: nameController.text,
                                amount:
                                    double.tryParse(amountController.text) ?? 0,
                                category: category,
                                type: type,
                                frequency: frequency,
                                dayOfMonth: dayOfMonth,
                                dayOfWeek: dayOfWeek,
                              );
                          // Invalidate dashboard to refresh payment calendar
                          ref.invalidate(dashboardProvider);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("SAVE AUTOMATION",
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(AppColors semantic, String label, IconData icon,
      TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: semantic.divider.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: semantic.text, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          icon: Icon(icon, color: semantic.primary, size: 20),
          labelText: label.toUpperCase(),
          labelStyle: TextStyle(
              color: semantic.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w900),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(AppColors semantic, String label, IconData icon,
      T value, List<T> items, ValueChanged<T?> onChanged,
      {Map<T, String>? labels}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: semantic.divider.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: semantic.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: TextStyle(
                        color: semantic.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
                DropdownButton<T>(
                  value: value,
                  items: items
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(labels?[e] ?? e.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))))
                      .toList(),
                  onChanged: onChanged,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: semantic.surfaceCombined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildFrequencyText(RecurringTransaction item) {
    String dayInfo = '';
    if (item.frequency == 'MONTHLY' && item.dayOfMonth != null) {
      dayInfo = ' • Day ${item.dayOfMonth}';
    } else if (item.frequency == 'WEEKLY' && item.dayOfWeek != null) {
      const days = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
      dayInfo = ' • ${days[item.dayOfWeek! % 7]}';
    }
    return '${item.frequency} • ${item.category}$dayInfo';
  }
}
