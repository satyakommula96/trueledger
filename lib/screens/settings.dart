import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportToCSV(BuildContext context) async {
    final db = await AppDatabase.db;
    final txs = await db.query('variable_expenses');
    
    if (txs.isEmpty) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No transactions to export")));
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Date', 'Amount', 'Category', 'Note']);
    for (var tx in txs) {
      rows.add([tx['id'], tx['date'], tx['amount'], tx['category'], tx['note']]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/expensetracker_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exported to: $path"), duration: const Duration(seconds: 5)));
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete All Data?"),
        content: const Text("This action cannot be undone. All entries, budgets, and cards will be wiped."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DELETE ALL", style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirmed == true) {
      final db = await AppDatabase.db;
      await db.delete('income_sources');
      await db.delete('fixed_expenses');
      await db.delete('variable_expenses');
      await db.delete('investments');
      await db.delete('subscriptions');
      await db.delete('credit_cards');
      await db.delete('saving_goals');
      await db.delete('budgets');
      await db.delete('retirement_contributions');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All data has been reset")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings & Tools")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildOption(
            context,
            "Export to CSV",
            "Download your transaction history for Excel",
            Icons.download_rounded,
            colorScheme.primary,
            () => _exportToCSV(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Reset Application",
            "Clear all data and start fresh",
            Icons.refresh_rounded,
            Colors.redAccent,
            () => _resetData(context),
          ),
          const SizedBox(height: 48),
          const Center(
            child: Column(
              children: [
                Text("EXPENSE TRACKER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                Text("Version 1.0.0", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
