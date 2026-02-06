import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/screens/transactions/edit_entry.dart';
import 'package:trueledger/presentation/components/error_view.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard_components/quick_add_bottom_sheet.dart';
import 'month_detail_components/category_icon.dart';
import 'month_detail_components/month_detail_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/presentation/components/empty_state.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';

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

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      appBar: AppBar(
        title: Text(widget.title.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(semantic, isPrivate),
          MonthDetailHeader(
            searchQuery: searchQuery,
            typeFilter: typeFilter,
            showFilters: widget.showFilters,
            onSearchChanged: (v) => setState(() => searchQuery = v),
            onFilterChanged: (v) => setState(() => typeFilter = v),
            semantic: semantic,
          ).animate().fadeIn(delay: 100.ms),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: semantic.primary))
                : _error != null
                    ? AppErrorView(
                        error: _error!,
                        onRetry: _loadData,
                      )
                    : _buildLedgerList(semantic, isPrivate),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(AppColors semantic, bool isPrivate) {
    final items = _getFilteredItems();
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final isIncome = typeFilter == "Income";
    final displayColor = isIncome
        ? semantic.income
        : (typeFilter == "All" ? semantic.primary : semantic.overspent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: displayColor.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${typeFilter.toUpperCase()} TOTAL",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: displayColor,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(total, isPrivate: isPrivate),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: semantic.text,
                      letterSpacing: -1.5,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: displayColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: displayColor.withValues(alpha: 0.2)),
            ),
            child: Icon(
              isIncome
                  ? Icons.trending_up_rounded
                  : (typeFilter == "All"
                      ? Icons.analytics_rounded
                      : Icons.trending_down_rounded),
              color: displayColor,
              size: 28,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildLedgerList(AppColors semantic, bool isPrivate) {
    final items = _getFilteredItems();
    if (items.isEmpty) {
      return const EmptyState(
        message: "NO ENTRIES YET",
        subMessage: "NO TRANSACTIONS FOUND FOR THIS PERIOD.",
        icon: Icons.receipt_long_rounded,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              24, 8, 24, 24 + MediaQuery.of(context).padding.bottom),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final String type = item.type;
            final isIncome = type == 'Income';
            final label = item.label;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HoverWrapper(
                borderRadius: 24,
                scale: 1.01,
                translateY: -2,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEntryScreen(entry: item),
                    ),
                  );
                  _loadData();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: semantic.surfaceCombined.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: semantic.divider, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CategoryIcon(
                        type: type,
                        label: label,
                        semantic: semantic,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label.toString().toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.2,
                                color: semantic.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        semantic.divider.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: semantic.secondaryText,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                if (item.note != null &&
                                    item.note!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.notes_rounded,
                                    size: 11,
                                    color: semantic.secondaryText
                                        .withValues(alpha: 0.5),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              CurrencyFormatter.format(item.amount,
                                  isPrivate: isPrivate),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color:
                                    isIncome ? semantic.income : semantic.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('dd MMM')
                                .format(DateTime.parse(item.date))
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  semantic.secondaryText.withValues(alpha: 0.4),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(
                    delay: (100 + (25 * i)).clamp(0, 600).ms, duration: 500.ms)
                .slideX(begin: 0.03, end: 0, curve: Curves.easeOutQuart);
          },
        ),
      ),
    );
  }
}
