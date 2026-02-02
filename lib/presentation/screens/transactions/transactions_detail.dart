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
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title.toUpperCase())),
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
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            final items = _getFilteredItems();
            final total =
                items.fold<double>(0, (sum, item) => sum + item.amount);
            final isIncome = typeFilter == "Income";

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isIncome
                      ? [
                          semantic.income.withValues(alpha: 0.15),
                          semantic.income.withValues(alpha: 0.05)
                        ]
                      : [
                          semantic.overspent.withValues(alpha: 0.15),
                          semantic.overspent.withValues(alpha: 0.05)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: (isIncome ? semantic.income : semantic.overspent)
                        .withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: (isIncome ? semantic.income : semantic.overspent)
                        .withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        Text("${typeFilter.toUpperCase()} TOTAL",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: (isIncome
                                    ? semantic.income
                                    : semantic.overspent),
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Semantics(
                          container: true,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(CurrencyFormatter.format(total),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: (isIncome
                                        ? semantic.income
                                        : semantic.overspent),
                                    letterSpacing: -0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isIncome ? semantic.income : semantic.overspent)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: (isIncome ? semantic.income : semantic.overspent),
                      size: 28,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn()
                .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuint);
          }),
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
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? AppErrorView(
                        error: _error!,
                        onRetry: _loadData,
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Builder(builder: (context) {
                            final items = _getFilteredItems();
                            if (items.isEmpty) {
                              return EmptyState(
                                message: "No entries yet",
                                subMessage:
                                    "No transactions found for this period.",
                                icon: Icons.receipt_long_rounded,
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.fromLTRB(24, 8, 24,
                                  24 + MediaQuery.of(context).padding.bottom),
                              itemCount: items.length,
                              itemBuilder: (context, i) {
                                final item = items[i];
                                final String type = item.type;
                                final isIncome = type == 'Income';
                                final label = item.label;

                                return HoverWrapper(
                                  borderRadius: 16,
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                EditEntryScreen(entry: item)));
                                    _loadData();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: semantic.divider
                                                .withValues(alpha: 0.5))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          CategoryIcon(
                                              type: type,
                                              label: label,
                                              semantic: semantic),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    label
                                                        .toString()
                                                        .toUpperCase(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 14,
                                                        letterSpacing: 0,
                                                        color: colorScheme
                                                            .onSurface)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                          type.toUpperCase(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: semantic
                                                                  .secondaryText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              letterSpacing:
                                                                  0.5)),
                                                    ),
                                                    if (item.note != null &&
                                                        item.note!
                                                            .isNotEmpty) ...[
                                                      const SizedBox(width: 4),
                                                      Icon(Icons.notes_rounded,
                                                          size: 10,
                                                          color: semantic
                                                              .secondaryText),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Semantics(
                                                  container: true,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                        CurrencyFormatter
                                                            .format(
                                                                item.amount),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 16,
                                                            color: isIncome
                                                                ? semantic
                                                                    .income
                                                                : colorScheme
                                                                    .onSurface)),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Semantics(
                                                  container: true,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(
                                                              DateTime.parse(
                                                                  item.date)),
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: semantic
                                                              .secondaryText,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        delay: (15 * i).clamp(0, 300).ms,
                                        duration: 400.ms)
                                    .slideX(
                                        begin: 0.05,
                                        end: 0,
                                        curve: Curves.easeOutQuint);
                              },
                            );
                          }),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
