import 'package:flutter/material.dart';
import '../db/database.dart';

class EditEntryScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  final String type; 
  
  const EditEntryScreen({super.key, required this.entry, required this.type});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController amountCtrl;
  late TextEditingController labelCtrl;
  late TextEditingController noteCtrl;
  late String category;

  @override
  void initState() {
    super.initState();
    amountCtrl = TextEditingController(text: widget.entry['amount'].toString());
    String initialLabel = "";
    if (widget.type == 'Variable') { initialLabel = widget.entry['category']; } 
    else if (widget.type == 'Income') { initialLabel = widget.entry['source']; } 
    else { initialLabel = widget.entry['name']; }
    labelCtrl = TextEditingController(text: initialLabel);
    noteCtrl = TextEditingController(text: widget.entry['note']?.toString() ?? '');
    category = widget.type == 'Variable' ? widget.entry['category'] : widget.type;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("EDIT ${widget.type.toUpperCase()}"),
        actions: [
          IconButton(onPressed: _confirmDelete, icon: Icon(Icons.delete_outline, color: colorScheme.onSurface.withOpacity(0.3))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AMOUNT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 48, letterSpacing: -2),
              decoration: const InputDecoration(prefixText: "₹ ", border: InputBorder.none),
            ),
            const SizedBox(height: 48),
            Text(widget.type == 'Income' ? "SOURCE" : "LABEL", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.type == 'Variable') ...[
              const SizedBox(height: 48),
              const Text("NOTE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(border: UnderlineInputBorder()),
              ),
            ],
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("UPDATE ENTRY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    final db = await AppDatabase.db;
    final amount = int.tryParse(amountCtrl.text) ?? 0;
    switch (widget.type) {
      case 'Variable': await db.update('variable_expenses', {'amount': amount, 'category': labelCtrl.text, 'note': noteCtrl.text}, where: 'id = ?', whereArgs: [widget.entry['id']]); break;
      case 'Income': await db.update('income_sources', {'amount': amount, 'source': labelCtrl.text}, where: 'id = ?', whereArgs: [widget.entry['id']]); break;
      case 'Fixed': await db.update('fixed_expenses', {'amount': amount, 'name': labelCtrl.text}, where: 'id = ?', whereArgs: [widget.entry['id']]); break;
      case 'Investment': await db.update('investments', {'amount': amount, 'name': labelCtrl.text}, where: 'id = ?', whereArgs: [widget.entry['id']]); break;
      case 'Subscription': await db.update('subscriptions', {'amount': amount, 'name': labelCtrl.text}, where: 'id = ?', whereArgs: [widget.entry['id']]); break;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entry updated"), behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("DELETE ITEM?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("KEEP")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE", style: TextStyle(color: Colors.grey))),
        ],
      )
    );
    if (confirmed == true) {
      final db = await AppDatabase.db;
      String table = "";
      switch (widget.type) {
        case 'Variable': table = 'variable_expenses'; break;
        case 'Income': table = 'income_sources'; break;
        case 'Fixed': table = 'fixed_expenses'; break;
        case 'Investment': table = 'investments'; break;
        case 'Subscription': table = 'subscriptions'; break;
      }
      await db.delete(table, where: 'id = ?', whereArgs: [widget.entry['id']]);
      if (mounted) Navigator.pop(context);
    }
  }
}
