import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final categoryCtrl = TextEditingController();
  final limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Budget")),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            TextField(
              controller: categoryCtrl,
              decoration:
                  const InputDecoration(labelText: "Category (e.g. Food)"),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync =
                    ref.watch(categoriesProvider('Variable'));
                return categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...categories.map((cat) {
                          final active = categoryCtrl.text == cat.name;
                          return ActionChip(
                            label: Text(cat.name.toUpperCase()),
                            onPressed: () => setState(() {
                              categoryCtrl.text = cat.name;
                            }),
                            backgroundColor: active
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.05)
                                : Colors.transparent,
                            side: BorderSide(
                                color: active
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.05)),
                            labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                                builder: (context) => ManageCategoriesScreen(
                                  initialType: 'Variable',
                                ),
                              ),
                            );
                            if (newCat != null && mounted) {
                              setState(() {
                                categoryCtrl.text = newCat;
                              });
                            }
                          },
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "${CurrencyFormatter.symbol} ",
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("CREATE BUDGET"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final category = categoryCtrl.text.trim();
    final limitText = limitCtrl.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category cannot be empty")));
      return;
    }
    if (limitText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Limit cannot be empty")));
      return;
    }

    final limit = int.tryParse(limitText);
    if (limit == null || limit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid non-negative limit")));
      return;
    }

    final repo = ref.read(financialRepositoryProvider);
    await repo.addBudget(category, limit);
    if (mounted) Navigator.pop(context);
  }
}
