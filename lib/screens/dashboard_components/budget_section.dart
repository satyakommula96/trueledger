import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/theme.dart';
import '../edit_budget.dart';

class BudgetSection extends StatelessWidget {
  final List<Budget> budgets;
  final AppColors semantic;
  final VoidCallback onLoad;

  const BudgetSection({
    super.key,
    required this.budgets,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return const Text("No active budgets",
          style: TextStyle(color: Colors.grey));
    }
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
        children: budgets.map((b) {
      final double progress = (b.spent / b.monthlyLimit).clamp(0.0, 1.0);
      final bool isOver = b.spent > b.monthlyLimit;

      return InkWell(
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditBudgetScreen(budget: b)));
          onLoad();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: semantic.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(b.category.toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("₹${b.spent} / ₹${b.monthlyLimit}",
                      style: TextStyle(
                          fontSize: 12,
                          color: isOver
                              ? semantic.overspent
                              : semantic.secondaryText,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: semantic.divider,
                  color: isOver ? semantic.overspent : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList());
  }
}
