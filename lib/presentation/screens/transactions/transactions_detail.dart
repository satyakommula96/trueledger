import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/apple_style.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail_components/category_icon.dart';
import 'package:trueledger/presentation/components/empty_state.dart';
import 'package:trueledger/presentation/screens/transactions/month_detail_components/month_detail_header.dart';
import 'package:trueledger/presentation/screens/transactions/edit_entry.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_bottom_sheet.dart';
import 'package:trueledger/presentation/components/error_view.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class TransactionsDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String? initialTypeFilter;
  final bool showFilters;

  const TransactionsDetailScreen({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.initialTypeFilter,
    this.showFilters = true,
  });

  @override
  ConsumerState<TransactionsDetailScreen> createState() =>
      _TransactionsDetailScreenState();
}

class _TransactionsDetailScreenState
    extends ConsumerState<TransactionsDetailScreen> {
  String searchQuery = "";
  String typeFilter = "All";
  bool _isLoading = true;
  Object? _error;

  List<LedgerItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    typeFilter = widget.initialTypeFilter ?? "All";
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data =
          await repo.getTransactionsForRange(widget.startDate, widget.endDate);
      if (mounted) {
        setState(() {
          _allItems = data;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint("Error loading range details: $e");
      if (kDebugMode) {
        throw Exception("Range Detail loading failed: $e\n$stack");
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  List<LedgerItem> _getFilteredItems() {
    var items = _allItems;
    if (typeFilter == "Expenses") {
      items = items
          .where((e) => e.type != 'Income' && e.type != 'Investment')
          .toList();
    } else if (typeFilter != "All") {
      items = items.where((e) => e.type == typeFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      items = items.where((e) {
        final label = e.label.toLowerCase();
        final note = (e.note ?? "").toLowerCase();
        final amount = e.amount.toString();
        return label.contains(searchQuery.toLowerCase()) ||
            note.contains(searchQuery.toLowerCase()) ||
            amount.contains(searchQuery);
      }).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isPrivate = ref.watch(privacyProvider);
    final l10n = AppLocalizations.of(context)!;

    return AppleScaffold(
      title: widget.title,
      subtitle: typeFilter == "All" ? l10n.allTransactions : typeFilter,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const QuickAddBottomSheet(),
          );
          if (added == true) {
            _loadData();
          }
        },
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildSummaryHeader(semantic, isPrivate, l10n),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MonthDetailHeader(
                  searchQuery: searchQuery,
                  typeFilter: typeFilter,
                  showFilters: widget.showFilters,
                  onSearchChanged: (v) => setState(() => searchQuery = v),
                  onFilterChanged: (v) => setState(() => typeFilter = v),
                  semantic: semantic,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (_isLoading)
          SliverFillRemaining(
            child: Center(
                child: CircularProgressIndicator(color: semantic.primary)),
          )
        else if (_error != null)
          SliverFillRemaining(
            child: AppErrorView(error: _error!, onRetry: _loadData),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildLedgerListSliver(semantic, isPrivate, l10n),
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(
      AppColors semantic, bool isPrivate, AppLocalizations l10n) {
    final items = _getFilteredItems();
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final isIncome = typeFilter == "Income";
    final displayColor = isIncome
        ? semantic.income
        : (typeFilter == "All" ? semantic.primary : semantic.overspent);

    return AppleGlassCard(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: displayColor.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.typeTotal(typeFilter.toUpperCase()),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: displayColor,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(total, isPrivate: isPrivate),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: semantic.text,
                      letterSpacing: -1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: displayColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: displayColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerListSliver(
      AppColors semantic, bool isPrivate, AppLocalizations l10n) {
    final items = _getFilteredItems();
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          message:
              searchQuery.isEmpty ? l10n.noEntriesYet : l10n.noResultsMatched,
          subMessage: l10n.noTransactionsFoundPeriod,
          icon: Icons.receipt_long_rounded,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final item = items[i];
          final isIncome = item.type == 'Income';

          return AppleGlassCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditEntryScreen(entry: item)),
                );
                _loadData();
              },
              contentPadding: EdgeInsets.zero,
              leading: CategoryIcon(
                type: item.type,
                label: item.label,
                semantic: semantic,
              ),
              title: Text(
                item.label.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: semantic.text,
                  letterSpacing: 0.5,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMM').format(item.date).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: semantic.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              trailing: Text(
                CurrencyFormatter.format(item.amount, isPrivate: isPrivate),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isIncome ? semantic.income : semantic.text,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ).animate().fadeIn(delay: (20 * i).ms).slideX(begin: 0.05, end: 0);
        },
        childCount: items.length,
      ),
    );
  }
}
