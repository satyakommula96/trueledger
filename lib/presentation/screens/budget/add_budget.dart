import 'package:flutter/material.dart';

import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        title: const Text("NEW BUDGET"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CATEGORY IDENTIFIER",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryCtrl,
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: semantic.text),
              decoration: InputDecoration(
                hintText: "e.g. DINING",
                filled: true,
                fillColor: semantic.surfaceCombined.withValues(alpha: 0.5),
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
                  borderSide: BorderSide(color: semantic.primary, width: 2),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 20),
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
                            backgroundColor:
                                active ? semantic.primary : Colors.transparent,
                            side: BorderSide(
                                color: active
                                    ? semantic.primary
                                    : semantic.divider),
                            labelStyle: TextStyle(
                                color: active ? Colors.black : semantic.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          );
                        }),
                        ActionChip(
                          label: const Icon(Icons.add, size: 16),
                          onPressed: () async {
                            final newCat = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManageCategoriesScreen(
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
                          side: BorderSide(color: semantic.divider),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                );
              },
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 48),
            const Text(
              "MONTHLY CEILING",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 48,
                letterSpacing: -2,
                color: semantic.text,
              ),
              decoration: InputDecoration(
                prefixText: "${CurrencyFormatter.symbol} ",
                border: InputBorder.none,
                hintText: "0",
                hintStyle: TextStyle(
                    color: semantic.secondaryText.withValues(alpha: 0.1)),
              ),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.05, end: 0),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text(
                  "ESTABLISH BUDGET",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
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

    final limit = double.tryParse(limitText);
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
