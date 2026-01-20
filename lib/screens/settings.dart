import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../logic/financial_repository.dart';

import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportToCSV(BuildContext context) async {
    final repo = FinancialRepository();
    final txs = await repo.getAllValues('variable_expenses');

    if (txs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No transactions to export")));
      }
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Date', 'Amount', 'Category', 'Note']);
    for (var tx in txs) {
      rows.add(
          [tx['id'], tx['date'], tx['amount'], tx['category'], tx['note']]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}/expensetracker_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Exported to: $path"),
          duration: const Duration(seconds: 5)));
    }
  }

  Future<void> _seedData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Generate Sample Data?"),
              content: const Text(
                  "This will add professional demo entries to your ledger. Existing data will not be deleted."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("CONTINUE")),
              ],
            ));

    if (confirmed == true) {
      final repo = FinancialRepository();
      await repo.seedData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sample data generated successfully")));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete All Data?"),
              content: const Text(
                  "This action cannot be undone. All entries, budgets, and cards will be wiped."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("DELETE ALL",
                        style: TextStyle(color: Colors.red))),
              ],
            ));

    if (confirmed == true) {
      final repo = FinancialRepository();
      await repo.clearData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All data has been reset")));
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
            "Download your transaction history",
            Icons.download_rounded,
            colorScheme.primary,
            () => _exportToCSV(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Seed Sample Data",
            "Populate app with demo entries",
            Icons.science_rounded,
            Colors.amber,
            () => _seedData(context),
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
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Test Notification",
            "Send a test notification now",
            Icons.notifications_active_rounded,
            Colors.purple,
            () async {
              await NotificationService().requestPermissions();
              await NotificationService().showNotification(
                id: 1,
                title: 'Test Notification',
                body: 'This is a test notification from TrueCash',
              );
            },
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Schedule Notification",
            "Schedule a notification for 5 seconds later",
            Icons.schedule_rounded,
            Colors.deepPurple,
            () async {
              await NotificationService().requestPermissions();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Notification scheduled for 5 seconds later')),
                );
              }

              await Future.delayed(const Duration(seconds: 5));

              await NotificationService().showNotification(
                id: 2,
                title: 'Scheduled Notification',
                body: 'This notification was scheduled 5 seconds ago',
              );
            },
          ),
          const SizedBox(height: 48),
          const Center(
            child: Column(
              children: [
                Text("TRUECASH",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey)),
                Text("Version 1.1.0",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String sub,
      IconData icon, Color color, VoidCallback onTap) {
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
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(sub,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
