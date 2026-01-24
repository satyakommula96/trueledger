import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truecash/core/utils/web_saver.dart';

import 'package:truecash/data/datasources/database.dart';

import 'package:truecash/core/config/version.dart';
import 'package:truecash/main.dart';
import 'package:truecash/core/utils/currency_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showThemePicker(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Theme"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("System Default"),
              leading: const Icon(Icons.settings_suggest_rounded),
              onTap: () {
                themeNotifier.value = ThemeMode.system;
                prefs.setString('theme_mode', 'system');
                Navigator.pop(context);
              },
              trailing: themeNotifier.value == ThemeMode.system
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            ListTile(
              title: const Text("Light Mode"),
              leading: const Icon(Icons.light_mode_rounded),
              onTap: () {
                themeNotifier.value = ThemeMode.light;
                prefs.setString('theme_mode', 'light');
                Navigator.pop(context);
              },
              trailing: themeNotifier.value == ThemeMode.light
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            ListTile(
              title: const Text("Dark Mode"),
              leading: const Icon(Icons.dark_mode_rounded),
              onTap: () {
                themeNotifier.value = ThemeMode.dark;
                prefs.setString('theme_mode', 'dark');
                Navigator.pop(context);
              },
              trailing: themeNotifier.value == ThemeMode.dark
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: CurrencyHelper.currencyNotifier,
        builder: (context, currentCurrency, _) {
          return AlertDialog(
            title: const Text("Select Currency"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...CurrencyHelper.currencies.entries.map((entry) {
                  return ListTile(
                    title: Text("${entry.key} (${entry.value})"),
                    onTap: () {
                      CurrencyHelper.setCurrency(entry.key);
                      Navigator.pop(context);
                    },
                    trailing: currentCurrency == entry.key
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportToCSV(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(financialRepositoryProvider);
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

  Future<void> _seedData(BuildContext context, WidgetRef ref) async {
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
      final repo = ref.read(financialRepositoryProvider);
      await repo.seedData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sample data generated successfully")));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(financialRepositoryProvider);

    // Gather all data
    final data = {
      'vars': await repo.getAllValues('variable_expenses'),
      'income': await repo.getAllValues('income_sources'),
      'fixed': await repo.getAllValues('fixed_expenses'),
      'invs': await repo.getAllValues('investments'),
      'subs': await repo.getAllValues('subscriptions'),
      'cards': await repo.getAllValues('credit_cards'),
      'loans': await repo.getAllValues('loans'),
      'goals': await repo.getAllValues('saving_goals'),
      'budgets': await repo.getAllValues('budgets'),
      'backup_date': DateTime.now().toIso8601String(),
      'version': '1.0'
    };

    final jsonString = jsonEncode(data);
    final fileName =
        "truecash_backup_${DateTime.now().millisecondsSinceEpoch}.json";

    if (kIsWeb) {
      // Web: Create XFile from bytes and "share" it (triggers download)
      final bytes = utf8.encode(jsonString);
      await saveFileWeb(bytes, fileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Backup download started")));
      }
      return;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop: Open "Save As" dialog
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Backup saved to $outputFile")));
        }
      }
      return;
    }

    // Mobile (Android/iOS)
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    if (context.mounted) {
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'TrueCash Backup File');
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;

    // If web, bytes should be populated; else use path
    String jsonString;
    if (kIsWeb) {
      final bytes = result.files.single.bytes;
      if (bytes == null) return;
      jsonString = utf8.decode(bytes);
    } else {
      final file = File(result.files.single.path!);
      jsonString = await file.readAsString();
    }

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['version'] != '1.0') throw "Unknown backup version";

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Restore Data?"),
                content: const Text(
                    "This will OVERWRITE all current data with the backup relative to the file date."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("CANCEL")),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("RESTORE",
                          style: TextStyle(color: Colors.red))),
                ],
              ));

      if (confirmed == true) {
        final repo = ref.read(financialRepositoryProvider);
        await repo.clearData();

        // Restore tables directly via AppDatabase for batch efficiency (Pragmatic concession until Repo expanded)
        // Ideally this moves to Repo.
        final db = await AppDatabase.db;
        final batch = db.batch();

        for (var i in (data['vars'] as List)) {
          batch.insert('variable_expenses', i as Map<String, dynamic>);
        }
        for (var i in (data['income'] as List)) {
          batch.insert('income_sources', i as Map<String, dynamic>);
        }
        for (var i in (data['fixed'] as List)) {
          batch.insert('fixed_expenses', i as Map<String, dynamic>);
        }
        for (var i in (data['invs'] as List)) {
          batch.insert('investments', i as Map<String, dynamic>);
        }
        for (var i in (data['subs'] as List)) {
          batch.insert('subscriptions', i as Map<String, dynamic>);
        }
        for (var i in (data['cards'] as List)) {
          batch.insert('credit_cards', i as Map<String, dynamic>);
        }
        for (var i in (data['loans'] as List)) {
          batch.insert('loans', i as Map<String, dynamic>);
        }
        for (var i in (data['goals'] as List)) {
          batch.insert('saving_goals', i as Map<String, dynamic>);
        }
        for (var i in (data['budgets'] as List)) {
          batch.insert('budgets', i as Map<String, dynamic>);
        }

        await batch.commit();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Restore Successful!")));
          Navigator.pop(context); // Go back to dashboard to refresh
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Restore Failed: $e")));
      }
    }
  }

  Future<void> _resetData(BuildContext context, WidgetRef ref) async {
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
      final repo = ref.read(financialRepositoryProvider);
      await repo.clearData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("All data has been reset")));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setupPin(BuildContext context) async {
    // ... (unchanged)
    final prefs = await SharedPreferences.getInstance();
    final currentPin = prefs.getString('app_pin');

    if (!context.mounted) return;

    if (currentPin != null) {
      final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) =>
              AlertDialog(title: const Text("Remove Security PIN?"), actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("REMOVE",
                        style: TextStyle(color: Colors.red))),
              ]));

      if (confirm == true) {
        await prefs.remove('app_pin');
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("PIN Removed")));
        }
      }
    } else {
      // Set new PIN
      String newPin = "";
      await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Set 4-Digit PIN"),
              content: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                onChanged: (val) => newPin = val,
                decoration: const InputDecoration(hintText: "Enter PIN"),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("CANCEL")),
                TextButton(
                    onPressed: () {
                      if (newPin.length == 4) {
                        prefs.setString('app_pin', newPin);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("PIN Set Successfully")));
                      }
                    },
                    child: const Text("SAVE")),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings & Tools")),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
        children: [
          _buildOption(
            context,
            "Appearance",
            "Switch between Light, Dark, or System theme",
            Icons.dark_mode_outlined,
            Colors.indigo,
            () => _showThemePicker(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "App Security",
            "Set PIN for access",
            Icons.lock_outline_rounded,
            Colors.deepPurple,
            () => _setupPin(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Currency",
            "Choose your preferred currency (${CurrencyHelper.symbol})",
            Icons.payments_outlined,
            Colors.teal,
            () => _showCurrencyPicker(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Export to CSV",
            "Download your transaction history",
            Icons.download_rounded,
            colorScheme.primary,
            () => _exportToCSV(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Backup Data",
            "Save full backup to file",
            Icons.cloud_upload_outlined,
            Colors.blueAccent,
            () => _backupData(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Restore Data",
            "Import backup file",
            Icons.restore_page_outlined,
            Colors.orange,
            () => _restoreData(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Seed Sample Data",
            "Populate app with demo entries",
            Icons.science_rounded,
            Colors.amber,
            () => _seedData(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Reset Application",
            "Clear all data and start fresh",
            Icons.refresh_rounded,
            Colors.redAccent,
            () => _resetData(context, ref),
          ),
          const SizedBox(height: 48), // ... rest of build

          const Center(
            child: Column(
              children: [
                Text("TRUECASH",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey)),
                Text("Version ${AppVersion.current}",
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
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
