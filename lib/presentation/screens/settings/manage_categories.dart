import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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
        return 'Subscription';
      default:
        return t;
    }
  }

  void _addCategory() async {
    final l10n = AppLocalizations.of(context)!;
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
      final semantic = Theme.of(context).extension<AppColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryAddedTo(name.toUpperCase(),
              _getTypeLabel(selectedType, l10n).toUpperCase())),
          backgroundColor: semantic.primary,
        ),
      );
    }
  }

  void _deleteCategory(TransactionCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(financialRepositoryProvider);
    await repo.deleteCategory(category.id!);
    ref.invalidate(categoriesProvider(category.type));

    if (mounted) {
      final semantic = Theme.of(context).extension<AppColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryDeleted(category.name.toUpperCase())),
          backgroundColor: semantic.overspent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider(selectedType));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle.toUpperCase()),
        centerTitle: true,
        actions: [
          if (lastAddedCategory != null)
            IconButton(
              icon: Icon(Icons.check_circle_rounded, color: semantic.income),
              onPressed: () => Navigator.pop(context, lastAddedCategory),
              tooltip: l10n.useCategoryTooltip(lastAddedCategory!),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildTypeSelector(semantic, l10n),
              _buildAddInput(semantic, l10n),
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return _buildEmptyState(semantic, l10n);
                    }
                    return ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Container(
                          key: ValueKey(cat.id),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryItem(cat, index, semantic),
                        );
                      },
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;
                        final updatedList =
                            List<TransactionCategory>.from(categories);
                        final item = updatedList.removeAt(oldIndex);
                        updatedList.insert(newIndex, item);

                        // Optimistic update if needed, but here we just call repo
                        await ref
                            .read(financialRepositoryProvider)
                            .reorderCategories(updatedList);
                        ref.invalidate(categoriesProvider(selectedType));
                      },
                      proxyDecorator: (child, index, animation) {
                        return Material(
                          color: Colors.transparent,
                          child: child,
                        );
                      },
                    );
                  },
                  loading: () => Center(
                      child:
                          CircularProgressIndicator(color: semantic.primary)),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppColors semantic, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: types.map((t) {
            final active = selectedType == t;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Theme(
                data:
                    Theme.of(context).copyWith(canvasColor: Colors.transparent),
                child: ChoiceChip(
                  label: Text(_getTypeLabel(t, l10n).toUpperCase()),
                  selected: active,
                  onSelected: (_) => setState(() => selectedType = t),
                  backgroundColor:
                      semantic.surfaceCombined.withValues(alpha: 0.3),
                  selectedColor: semantic.primary.withValues(alpha: 0.1),
                  side: BorderSide(
                      color: active ? semantic.primary : semantic.divider,
                      width: 1.5),
                  labelStyle: TextStyle(
                      color: active ? semantic.primary : semantic.secondaryText,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate(target: active ? 1 : 0).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 200.ms,
                  ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddInput(AppColors semantic, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: categoryCtrl,
                style: TextStyle(
                    color: semantic.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.addNewCategoryHint,
                  hintStyle: TextStyle(
                      color: semantic.secondaryText.withValues(alpha: 0.3),
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: semantic.surfaceCombined.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: semantic.divider, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: semantic.primary, width: 2),
                  ),
                ),
                onSubmitted: (_) => _addCategory(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    semantic.primary,
                    semantic.primary.withValues(alpha: 0.8)
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addCategory,
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      TransactionCategory cat, int index, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.drag_indicator_rounded,
                  size: 20,
                  color: semantic.secondaryText.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: semantic.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(cat.name.isNotEmpty ? cat.name[0].toUpperCase() : "?",
                style: TextStyle(
                    color: semantic.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              cat.name.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: semantic.text,
                letterSpacing: 1,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionIcon(
                Icons.check_circle_outline_rounded,
                () => Navigator.pop(context, cat.name),
                semantic,
                color: semantic.income,
              ),
              const SizedBox(width: 8),
              _buildActionIcon(
                Icons.delete_outline_rounded,
                () => _deleteCategory(cat),
                semantic,
                color: semantic.overspent,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 40).ms)
        .slideX(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, AppColors semantic,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? semantic.text).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: color ?? semantic.text),
      ),
    );
  }

  Widget _buildEmptyState(AppColors semantic, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: semantic.divider.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_rounded,
              size: 48,
              color: semantic.secondaryText.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.noCategoriesYet,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: semantic.text,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addFirstCategory(_getTypeLabel(selectedType, l10n)),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: semantic.secondaryText),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
