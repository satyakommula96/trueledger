import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/add_transaction_usecase.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/core/services/notification_service.dart';
import 'package:trueledger/core/utils/hash_utils.dart';
import 'package:trueledger/presentation/providers/category_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key});

  @override
  ConsumerState<QuickAddBottomSheet> createState() =>
      _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = ''; // Will be set when categories load
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onNoteChanged(String value) async {
    if (value.length < 3) return;

    final recommended = await ref
        .read(financialRepositoryProvider)
        .getRecommendedCategory(value);
    if (recommended != null && mounted) {
      setState(() {
        _selectedCategory = recommended;
      });
    }
  }

  Future<void> _handleSave() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final result = await ref.read(addTransactionUseCaseProvider).call(
          AddTransactionParams(
            type: 'Variable',
            amount: amount,
            category: _selectedCategory,
            note: _noteController.text.isEmpty
                ? 'Quick add'
                : _noteController.text,
            date: DateTime.now().toIso8601String(),
          ),
        );

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

      if (mounted) Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.failureOrThrow.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "QUICK ADD",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: semantic.secondaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
                decoration: const InputDecoration(
                  hintText: "0",
                  border: InputBorder.none,
                  prefixText: "", // Could add currency symbol here
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: semantic.secondaryText,
                ),
                decoration: const InputDecoration(
                  hintText: "What was this for?",
                  border: InputBorder.none,
                ),
                onChanged: _onNoteChanged,
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync =
                      ref.watch(categoriesProvider('Variable'));
                  return categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return TextButton.icon(
                          onPressed: () async {
                            final newCat = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ManageCategoriesScreen(
                                            initialType: 'Variable')));
                            if (newCat != null && mounted) {
                              setState(() => _selectedCategory = newCat);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("MANAGE CATEGORIES"),
                        );
                      }

                      if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedCategory = categories.first.name;
                            });
                          }
                        });
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                itemCount: categories.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final cat = categories[index].name;
                                  final isSelected = cat == _selectedCategory;
                                  return InkWell(
                                    onTap: () =>
                                        setState(() => _selectedCategory = cat),
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  colorScheme.primary,
                                                  colorScheme.primary
                                                      .withValues(alpha: 0.8)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                                  .withValues(alpha: 0.2)
                                              : Colors.transparent,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected) ...[
                                              const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 16,
                                                  color: Colors.white),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              cat,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : colorScheme
                                                        .onSurfaceVariant,
                                                fontWeight: isSelected
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: () async {
                              final newCat = await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageCategoriesScreen(
                                              initialType: 'Variable')));
                              if (newCat != null && mounted) {
                                setState(() => _selectedCategory = newCat);
                              }
                            },
                            icon: const Icon(Icons.settings_suggest_rounded,
                                size: 20),
                          ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text("Error: $err"),
                  );
                },
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: const Text(
                        "SAVE EXPENSE",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontSize: 16,
                          color: Color(0xFF064E3B), // Dark green for contrast
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
