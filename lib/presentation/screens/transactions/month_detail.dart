import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:truecash/presentation/screens/transactions/edit_entry.dart';
import 'month_detail_components/category_icon.dart';
import 'month_detail_components/month_detail_header.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MonthDetailScreen extends ConsumerStatefulWidget {
  final String month;
  const MonthDetailScreen({super.key, required this.month});

  @override
  ConsumerState<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends ConsumerState<MonthDetailScreen> {
  String searchQuery = "";
  String typeFilter = "All";

  List<LedgerItem> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
    if (typeFilter != "All") {
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
      body: Column(
        children: [
          MonthDetailHeader(
            searchQuery: searchQuery,
            typeFilter: typeFilter,
            onSearchChanged: (v) => setState(() => searchQuery = v),
            onFilterChanged: (v) => setState(() => typeFilter = v),
            semantic: semantic,
          ),
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
                                  fontWeight: FontWeight.bold)));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(24, 0, 24,
                          24 + MediaQuery.of(context).padding.bottom),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final String type = item.type;
                        final isIncome = type == 'Income';
                        final label = item.label;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: semantic.divider)),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          EditEntryScreen(entry: item)));
                              _loadData();
                            },
                            borderRadius: BorderRadius.circular(12),
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
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                letterSpacing: 0.5,
                                                color: colorScheme.onSurface)),
                                        const SizedBox(height: 6),
                                        Text(type.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: semantic.secondaryText,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1)),
                                      ],
                                    ),
                                  ),
                                  Text(CurrencyFormatter.format(item.amount),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: isIncome
                                              ? semantic.income
                                              : colorScheme.onSurface)),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                                delay: (20 * i).clamp(0, 300).ms,
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
