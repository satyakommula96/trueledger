import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../logic/financial_repository.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'edit_entry.dart';

class MonthDetailScreen extends StatefulWidget {
  final String month;
  const MonthDetailScreen({super.key, required this.month});

  @override
  State<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends State<MonthDetailScreen> {
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
      final repo = FinancialRepository();
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        return label.contains(searchQuery.toLowerCase()) || note.contains(searchQuery.toLowerCase());
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => searchQuery = v),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "SEARCH LEDGER...",
                      hintStyle: TextStyle(color: semantic.secondaryText.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                      prefixIcon: Icon(Icons.search, size: 16, color: semantic.secondaryText),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: semantic.divider)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: semantic.divider)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: semantic.divider)),
                  child: DropdownButton<String>(
                    value: typeFilter,
                    underline: const SizedBox(),
                    icon: Icon(Icons.filter_list, size: 14, color: semantic.secondaryText),
                    items: ['All', 'Variable', 'Income', 'Fixed', 'Investment'].map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)))).toList(),
                    onChanged: (v) => setState(() => typeFilter = v!),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Builder(
                  builder: (context) {
                    final items = _getFilteredItems();
                    if (items.isEmpty) return Center(child: Text("NO ENTRIES FOUND", style: TextStyle(color: semantic.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)));
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            border: Border.all(color: semantic.divider)
                          ),
                          child: InkWell(
                            onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditEntryScreen(entry: item))); _loadData(); },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  _CategoryIcon(type: type, label: label, semantic: semantic),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(label.toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5, color: colorScheme.onSurface)),
                                        const SizedBox(height: 6),
                                        Text(type.toUpperCase(), style: TextStyle(fontSize: 9, color: semantic.secondaryText, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${item.amount}", 
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isIncome ? semantic.income : colorScheme.onSurface)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String yyyyMm) {
    try {
      final date = DateTime.parse('$yyyyMm-01');
      return DateFormat('MMMM yyyy').format(date).toUpperCase();
    } catch (e) { return yyyyMm; }
  }
}

class _CategoryIcon extends StatelessWidget {
  final String type;
  final String label;
  final AppColors semantic;

  const _CategoryIcon({required this.type, required this.label, required this.semantic});

  IconData _getIcon() {
    if (type == 'Income') return Icons.arrow_downward;
    if (type == 'Investment') return Icons.trending_up;
    
    final l = label.toLowerCase();
    if (l.contains('food') || l.contains('grocer') || l.contains('restaurant')) return Icons.restaurant;
    if (l.contains('travel') || l.contains('transport') || l.contains('fuel') || l.contains('gas')) return Icons.directions_car;
    if (l.contains('shop') || l.contains('clothes')) return Icons.shopping_bag;
    if (l.contains('bill') || l.contains('utilit')) return Icons.receipt_long;
    if (l.contains('entert') || l.contains('movie')) return Icons.movie;
    if (l.contains('health') || l.contains('doctor') || l.contains('medic')) return Icons.medical_services;
    if (l.contains('educ') || l.contains('school') || l.contains('fee')) return Icons.school;
    if (l.contains('rent') || l.contains('home')) return Icons.home;
    if (l.contains('salary') || l.contains('wage')) return Icons.work;
    
    if (l.contains('investment') || l.contains('stock') || l.contains('sip') || l.contains('mutual')) return Icons.trending_up;
    return type == 'Fixed' ? Icons.calendar_today : Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getIconColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_getIcon(), size: 20, color: _getIconColor()),
    );
  }

  Color _getIconColor() {
    if (type == 'Income') return semantic.income;
    if (type == 'Investment') return semantic.warning;
    return semantic.secondaryText;
  }
}
