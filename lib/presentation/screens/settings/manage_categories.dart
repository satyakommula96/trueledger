import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/presentation/components/empty_state.dart';

class ManageCategoriesScreen extends ConsumerStatefulWidget {
  final String? initialType;
  const ManageCategoriesScreen({super.key, this.initialType});

  @override
  ConsumerState<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends ConsumerState<ManageCategoriesScreen> {
  late String selectedType;
  final types = ['Variable', 'Fixed', 'Income', 'Investment', 'Subscription'];
  final categoryCtrl = TextEditingController();
  String? lastAddedCategory;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialType ?? 'Variable';
  }

  @override
  void dispose() {
    categoryCtrl.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final name = categoryCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(financialRepositoryProvider);
    await repo.addCategory(name, selectedType);
    categoryCtrl.clear();
    ref.invalidate(categoriesProvider(selectedType));

    setState(() {
      lastAddedCategory = name;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added to $selectedType categories")),
      );
    }
  }

  void _deleteCategory(TransactionCategory category) async {
    final repo = ref.read(financialRepositoryProvider);
    await repo.deleteCategory(category.id!);
    ref.invalidate(categoriesProvider(category.type));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${category.name} deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final categoriesAsync = ref.watch(categoriesProvider(selectedType));

    return Scaffold(
      appBar: AppBar(
        title: const Text("MANAGE CATEGORIES"),
        actions: [
          if (lastAddedCategory != null)
            IconButton(
              icon: const Icon(Icons.check_circle_rounded),
              onPressed: () => Navigator.pop(context, lastAddedCategory),
              tooltip: "Use $lastAddedCategory",
            ),
        ],
      ),
      body: Column(
        children: [
          // Type Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: types.map((t) {
                  final active = selectedType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(t.toUpperCase()),
                      selected: active,
                      onSelected: (_) => setState(() => selectedType = t),
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: active
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Add Category Input
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: categoryCtrl,
                    decoration: InputDecoration(
                      hintText: "Add new category...",
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 12),
                HoverWrapper(
                  onTap: _addCategory,
                  borderRadius: 12,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(Icons.add_rounded, color: colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const EmptyState(
                    message: "No categories",
                    subMessage: "Add your first category for this type",
                    icon: Icons.category_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle_outline_rounded,
                                  color: semantic.income),
                              onPressed: () => Navigator.pop(context, cat.name),
                              tooltip: "Select ${cat.name}",
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: semantic.overspent),
                              onPressed: () => _deleteCategory(cat),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
