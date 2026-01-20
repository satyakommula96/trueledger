import 'package:flutter/material.dart';
import '../db/database.dart';
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

  Future<List<Map<String, dynamic>>> _loadHistory() async {
    final db = await AppDatabase.db;
    List<Map<String, dynamic>> allItems = [];
    final vars = await db.rawQuery('SELECT *, "Variable" as entryType FROM variable_expenses WHERE substr(date, 1, 7) = ?', [widget.month]);
    allItems.addAll(vars);
    final income = await db.rawQuery('SELECT *, "Income" as entryType FROM income_sources WHERE substr(date, 1, 7) = ?', [widget.month]);
    allItems.addAll(income);
    final fixed = await db.rawQuery('SELECT *, "Fixed" as entryType FROM fixed_expenses WHERE substr(date, 1, 7) = ?', [widget.month]);
    allItems.addAll(fixed);
    final invs = await db.rawQuery('SELECT *, "Investment" as entryType FROM investments WHERE substr(date, 1, 7) = ?', [widget.month]);
    allItems.addAll(invs);

    if (typeFilter != "All") allItems = allItems.where((e) => e['entryType'] == typeFilter).toList();
    if (searchQuery.isNotEmpty) {
      allItems = allItems.where((e) {
        final label = (e['category'] ?? e['source'] ?? e['name'] ?? "").toString().toLowerCase();
        final note = (e['note'] ?? "").toString().toLowerCase();
        return label.contains(searchQuery.toLowerCase()) || note.contains(searchQuery.toLowerCase());
      }).toList();
    }
    allItems.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return allItems;
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadHistory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final String type = item['entryType'];
                    final isIncome = type == 'Income';
                    final label = item['category'] ?? item['source'] ?? item['name'] ?? "Unknown";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface, 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: semantic.divider)
                      ),
                      child: InkWell(
                        onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => EditEntryScreen(entry: item, type: type))); setState(() {}); },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
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
                                "₹${item['amount']}", 
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isIncome ? semantic.income : colorScheme.onSurface)
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String yyyyMm) {
    try {
      final parts = yyyyMm.split('-');
      const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
      return "${months[int.parse(parts[1]) - 1]} ${parts[0]}";
    } catch (e) { return yyyyMm; }
  }
}
