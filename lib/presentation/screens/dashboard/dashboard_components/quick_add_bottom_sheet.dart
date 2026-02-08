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
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

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
  String? _suggestedCategory;
  String? _suggestedPaymentMethod;
  String? _suggestedReason;
  QuickAddPreset? _shortcutSuggestion;
  String? _paymentMethod;
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Net Banking'];
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _paymentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDefaults();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _loadDefaults() {
    final service = ref.read(personalizationServiceProvider);
    final lastUsed = service.getLastUsed();
    final settings = service.getSettings();

    if (settings.rememberLastUsed) {
      if (lastUsed['category'] != null) {
        setState(() {
          _selectedCategory = lastUsed['category']!;
          _suggestedCategory = lastUsed['category'];
          _suggestedReason = "Based on your last entry";
        });
      }
      if (lastUsed['paymentMethod'] != null) {
        final pm = lastUsed['paymentMethod']!;
        setState(() {
          _paymentMethod = pm;
          _suggestedPaymentMethod = pm;
          if (!_paymentMethods.contains(pm)) {
            _paymentMethods.insert(0, pm);
          }
        });
      }
    }

    // Phase 5.2 Time-of-day suggestion (Preview integration)
    if (settings.timeOfDaySuggestions) {
      final todSuggestion =
          service.getSuggestedCategoryForTime(DateTime.now().hour);
      if (todSuggestion != null) {
        setState(() {
          _selectedCategory = todSuggestion;
          _suggestedCategory = todSuggestion;
          _suggestedReason = "Based on your daily routine";
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
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
    final amount = double.tryParse(_amountController.text);
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
            paymentMethod: _paymentMethod,
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
          controller: _scrollController,
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
              if ((_suggestedCategory != null &&
                      _selectedCategory == _suggestedCategory) ||
                  (_suggestedPaymentMethod != null &&
                      _paymentMethod == _suggestedPaymentMethod))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: semantic.income.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: semantic.income.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 14, color: semantic.income),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _buildSuggestionText(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: semantic.income,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.circle, size: 3, color: semantic.income),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _jumpToOverride,
                            child: Text(
                              "CHANGE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: semantic.income,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showSuggestionInfo(context),
                            child: Icon(Icons.help_outline_rounded,
                                size: 14, color: semantic.income),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              TextField(
                controller: _amountController,
                focusNode: _focusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 12),
              _buildShortcutSuggestion(context, semantic),
              const SizedBox(height: 24),
              _buildPresetsSection(context),
              const SizedBox(height: 24),
              Consumer(
                key: _categoryKey,
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
                                  final isSuggested =
                                      cat == _suggestedCategory && isSelected;
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
                                              Icon(
                                                  isSuggested
                                                      ? Icons
                                                          .auto_awesome_rounded
                                                      : Icons
                                                          .check_circle_rounded,
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
              const SizedBox(height: 24),
              _buildPaymentMethodSection(context, semantic),
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

  Widget _buildShortcutSuggestion(BuildContext context, AppColors semantic) {
    if (_shortcutSuggestion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Save as shortcut?",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                Text(
                  "You log '${_shortcutSuggestion!.title}' often.",
                  style: TextStyle(
                    fontSize: 11,
                    color: semantic.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(personalizationServiceProvider).snoozeSuggestion(
                  'shortcut_${_shortcutSuggestion!.title}|${_shortcutSuggestion!.category}|${_shortcutSuggestion!.amount}');
              setState(() => _shortcutSuggestion = null);
            },
            child: const Text("NOT NOW", style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(personalizationServiceProvider)
                  .addPreset(_shortcutSuggestion!);
              setState(() => _shortcutSuggestion = null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Shortcut saved!")),
              );
            },
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text("SAVE",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection(BuildContext context) {
    final service = ref.read(personalizationServiceProvider);
    final presets = service.getPresets();
    final semantic = Theme.of(context).extension<AppColors>()!;

    if (presets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRESETS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: semantic.secondaryText,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = presets[index];
              return ActionChip(
                label: Text(
                    "${preset.title} · ${CurrencyFormatter.format(preset.amount, compact: false)}"),
                onPressed: () {
                  _amountController.text = preset.amount.toString();
                  _noteController.text = preset.note ?? preset.title;
                  setState(() {
                    _selectedCategory = preset.category;
                    _paymentMethod = preset.paymentMethod;
                  });
                },
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                labelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context, AppColors semantic) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: _paymentKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PAYMENT METHOD",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: semantic.secondaryText,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: _paymentMethods.map((method) {
              final isSelected = _paymentMethod == method;
              final isSuggested =
                  _suggestedPaymentMethod == method && isSelected;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => setState(() => _paymentMethod = method),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSuggested) ...[
                            Icon(Icons.auto_awesome_rounded,
                                size: 12, color: colorScheme.primary),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            method,
                            style: TextStyle(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _buildSuggestionText() {
    final catSuggested =
        _suggestedCategory != null && _selectedCategory == _suggestedCategory;
    final paySuggested = _suggestedPaymentMethod != null &&
        _paymentMethod == _suggestedPaymentMethod;

    if (!catSuggested && !paySuggested) return "";

    if (catSuggested && paySuggested) {
      return "Suggested: $_selectedCategory & $_paymentMethod · ${_suggestedReason ?? 'Daily Pattern'}";
    }

    if (catSuggested) {
      return "Suggested: $_selectedCategory · $_suggestedReason";
    }

    return "Suggested: $_paymentMethod · Based on last record";
  }

  void _jumpToOverride() {
    final catSuggested =
        _suggestedCategory != null && _selectedCategory == _suggestedCategory;
    final targetKey = catSuggested ? _categoryKey : _paymentKey;

    final context = targetKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuggestionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Transparency Check"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "We pre-filled some values locally to save you typing effort.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 16),
            if (_suggestedCategory != null &&
                _selectedCategory == _suggestedCategory)
              _buildInfoRow(
                  Icons.category_rounded, "Category", _suggestedReason!),
            if (_suggestedPaymentMethod != null &&
                _paymentMethod == _suggestedPaymentMethod)
              _buildInfoRow(Icons.payment_rounded, "Payment",
                  "Based on your last record"),
            const SizedBox(height: 12),
            const Text(
              "This data never leaves your device.",
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("GOT IT")),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 12)),
                Text(reason, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
