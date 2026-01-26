import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/screens/transactions/edit_entry.dart';
import 'package:trueledger/presentation/screens/transactions/add_expense.dart';
import 'month_detail_components/category_icon.dart';
import 'month_detail_components/month_detail_header.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

class MonthDetailScreen extends ConsumerStatefulWidget {
  final String month;
  final String? initialTypeFilter;
  final bool showFilters;
  const MonthDetailScreen({
    super.key,
    required this.month,
    this.initialTypeFilter,
    this.showFilters = true,
  });

  @override
  ConsumerState<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends ConsumerState<MonthDetailScreen> {
  String searchQuery = "";
  late String typeFilter;

  List<LedgerItem> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    typeFilter = widget.initialTypeFilter ?? "All";
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data = await repo.getMonthDetails(widget.month);
      if (mounted) {
        setState(() {
          _allItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading month details: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
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
        return label.contains(searchQuery.toLowerCase()) ||
            note.contains(searchQuery.toLowerCase());
      }).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text(_formatMonth(widget.month))),
      floatingActionButton: HoverWrapper(
        onTap: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddExpense()));
          _loadData();
        },
        borderRadius: 28,
        glowColor: semantic.income,
        glowOpacity: 0.15,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: semantic.income,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: semantic.income.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text("ADD ENTRY",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1)),
            ],
          ),
        ),
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
                  Column(
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
                      Text(CurrencyFormatter.format(total),
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: (isIncome
                                  ? semantic.income
                                  : semantic.overspent),
                              letterSpacing: -0.5)),
                    ],
                  ),
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
                : Builder(builder: (context) {
                    final items = _getFilteredItems();
                    if (items.isEmpty) {
                      return Center(
                          child: Text("NO ENTRIES FOUND",
                              style: TextStyle(
                                  color: semantic.secondaryText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5)));
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
                                        Text(label.toString().toUpperCase(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                letterSpacing: 0,
                                                color: colorScheme.onSurface)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(type.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color:
                                                        semantic.secondaryText,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5)),
                                            if (item.note != null &&
                                                item.note!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Icon(Icons.notes_rounded,
                                                  size: 10,
                                                  color:
                                                      semantic.secondaryText),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                          CurrencyFormatter.format(item.amount),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              color: isIncome
                                                  ? semantic.income
                                                  : colorScheme.onSurface)),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd MMM')
                                            .format(DateTime.parse(item.date)),
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: semantic.secondaryText,
                                            fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  String _formatMonth(String yyyyMm) {
    try {
      final date = DateTime.parse('$yyyyMm-01');
      return DateFormat('MMMM yyyy').format(date).toUpperCase();
    } catch (e) {
      return yyyyMm;
    }
  }
}
