import 'dart:io';
import 'package:trueledger/core/services/file_service.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trueledger/core/utils/web_saver.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:trueledger/main.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/core/providers/version_provider.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';

import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/presentation/screens/settings/trust_center.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showNamePicker(BuildContext context, WidgetRef ref) async {
    final currentName = ref.read(userProvider);
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set User Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter your name",
            labelText: "Name",
          ),
          maxLength: 20,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(userProvider.notifier).setName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(sharedPreferencesProvider);
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
    String searchQuery = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      "Select Currency",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    final currentCurrency =
                        CurrencyFormatter.currencyNotifier.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search currency...",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                searchQuery = val.toLowerCase();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            controller: controller,
                            children: CurrencyFormatter.currencies.entries
                                .where((e) =>
                                    e.key.toLowerCase().contains(searchQuery) ||
                                    _getCurrencyName(e.key)
                                        .toLowerCase()
                                        .contains(searchQuery))
                                .map((entry) {
                              final isSelected = currentCurrency == entry.key;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(_getCurrencyName(
                                    entry.key)), // Helper for full names
                                trailing: isSelected
                                    ? Icon(Icons.check_circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)
                                    : null,
                                onTap: () {
                                  CurrencyFormatter.setCurrency(entry.key);
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'INR':
        return 'Indian Rupee';
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      case 'JPY':
        return 'Japanese Yen';
      case 'CAD':
        return 'Canadian Dollar';
      case 'AUD':
        return 'Australian Dollar';
      case 'SGD':
        return 'Singapore Dollar';
      case 'AED':
        return 'UAE Dirham';
      case 'SAR':
        return 'Saudi Riyal';
      case 'CNY':
        return 'Chinese Yuan';
      case 'KRW':
        return 'South Korean Won';
      case 'BRL':
        return 'Brazilian Real';
      case 'MXN':
        return 'Mexican Peso';
      default:
        return '';
    }
  }

  Future<void> _exportToCSV(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Unencrypted Data?"),
        content: const Text(
          "This will create a CSV file with your financial data in plain text.\n\nAnyone with access to this file can read it.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("EXPORT ANYWAY"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
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
    final fileName =
        "trueledger_export_${DateTime.now().millisecondsSinceEpoch}.csv";

    if (kIsWeb) {
      final bytes = utf8.encode(csv);
      await saveFileWeb(bytes, fileName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Export download started")));
      }
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final file = File(path);
    await file.writeAsString(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Exported to: $path"),
          duration: const Duration(seconds: 5)));
    }
  }

  Future<void> _seedData(BuildContext context, WidgetRef ref) async {
    final option = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Data Scenario"),
                  const SizedBox(height: 4),
                  Text(
                    "This data is fictional and for demonstration only.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'roadmap'),
                  child: const ListTile(
                    leading: Icon(Icons.star_rounded, color: Colors.purple),
                    title: Text("Complete Demo"),
                    subtitle: Text("All features, including Streaks"),
                  ),
                ),
              ],
            ));

    if (option != null) {
      final repo = ref.read(financialRepositoryProvider);

      try {
        if (option == 'roadmap') {
          await repo.seedRoadmapData();
        } else if (option == 'positive') {
          await repo.seedHealthyProfile();
        } else if (option == 'negative') {
          await repo.seedAtRiskProfile();
        }

        if (context.mounted) {
          final scenarioName = option == 'roadmap'
              ? "Complete Demo"
              : option == 'positive'
                  ? "Healthy Profile"
                  : option == 'negative'
                      ? "At-Risk Profile"
                      : option.toUpperCase();

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Generated $scenarioName data scenario")));
          Navigator.pop(context, true);
        }
      } catch (e, stack) {
        debugPrint("Data seeding failed: $e");
        if (kDebugMode) {
          debugPrint(stack.toString());
          throw Exception("Data seeding failed: $e\n$stack");
        }
      }
    }
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(financialRepositoryProvider);

    // 1. Ask for encryption password
    String? password;
    if (context.mounted) {
      password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          String input = "";
          bool obscure = true;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Encrypt Backup"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Enter a password to encrypt this backup file.",
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    obscureText: obscure,
                    onChanged: (v) => input = v,
                    decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () => setState(() => obscure = !obscure),
                        )),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("CANCEL")),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, input),
                    child: const Text("CREATE BACKUP")),
              ],
            );
          });
        },
      );
    }

    if (password == null || password.isEmpty) return;

    // 2. Gather Data
    final rawData = {
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
      'version': '1.0' // Inner version
    };

    final jsonString = jsonEncode(rawData);

    // 3. Encrypt Data
    final encryptedData =
        BackupEncryptionService.encryptData(jsonString, password);

    // 4. Wrap in container JSON
    final container = {
      'version': '2.0', // Container version
      'encrypted': true,
      'data': encryptedData,
      'date': DateTime.now().toIso8601String(),
    };
    final finalOutput = jsonEncode(container);

    final fileName =
        "trueledger_backup_enc_${DateTime.now().millisecondsSinceEpoch}.json";

    if (kIsWeb) {
      final bytes = utf8.encode(finalOutput);
      await saveFileWeb(bytes, fileName);

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('last_backup_time',
          DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Backup download started")));
      }
      return;
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Encrypted Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final fileService = ref.read(fileServiceProvider);
        await fileService.writeAsString(outputFile, finalOutput);

        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString('last_backup_time',
            DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Encrypted backup saved to $outputFile")));
        }
      }
      return;
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    final fileService = ref.read(fileServiceProvider);
    await fileService.writeAsString(file.path, finalOutput);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('last_backup_time',
        DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()));

    if (context.mounted) {
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)],
          text: 'TrueLedger Encrypted Backup');
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;

    String fileContent;
    if (kIsWeb) {
      final bytes = result.files.single.bytes;
      if (bytes == null) return;
      fileContent = utf8.decode(bytes);
    } else {
      final fileService = ref.read(fileServiceProvider);
      fileContent = await fileService.readAsString(result.files.single.path!);
    }

    try {
      final container = jsonDecode(fileContent) as Map<String, dynamic>;

      // Check for encryption
      Map<String, dynamic> data;
      if (container['encrypted'] == true) {
        String? password;

        // 1. Try Auto-Decryption with Device Key (for auto-backups)
        try {
          final deviceKey = await AppDatabase.getEncryptionKey();
          final decryptedJson =
              BackupEncryptionService.decryptData(container['data'], deviceKey);
          data = jsonDecode(decryptedJson) as Map<String, dynamic>;
          debugPrint("Auto-decryption successful with device key.");
        } catch (_) {
          // 2. Fallback: Ask user for password
          if (context.mounted) {
            password = await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) {
                String input = "";
                bool obscure = true;
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Decrypt Backup"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Enter password to decrypt this file.",
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 16),
                        TextField(
                          autofocus: true,
                          obscureText: obscure,
                          onChanged: (v) => input = v,
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                              )),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CANCEL")),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, input),
                          child: const Text("DECRYPT")),
                    ],
                  );
                });
              },
            );
          }

          if (password == null) return;

          try {
            final decryptedJson = BackupEncryptionService.decryptData(
                container['data'], password);
            data = jsonDecode(decryptedJson) as Map<String, dynamic>;
          } catch (e) {
            throw "Invalid Password or Corrupted File";
          }
        }
      } else {
        // Legacy (unencrypted) support
        data = container;
      }

      if (data['version'] != '1.0') throw "Unknown backup version";

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    const Text("Restore & Overwrite?"),
                  ],
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This will REPLACE all your current entries, budgets, and cards with those from the backup file.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "• Your current state will be AUTO-BACKUPED before proceeding.\n• This action is destructive and cannot be merged.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("CANCEL")),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("RESTORE")),
                ],
              ));

      if (confirmed == true) {
        final repo = ref.read(financialRepositoryProvider);
        final restoreUseCase = ref.read(restoreBackupUseCaseProvider);

        // Immediate safety backup for in-app UNDO
        Map<String, dynamic>? safetyBackup;
        try {
          safetyBackup = await repo.generateBackup();
        } catch (e, stack) {
          debugPrint("In-memory safety backup failed: $e");
          if (kDebugMode) {
            throw Exception("Safety backup failed: $e\n$stack");
          }
        }

        final result = await restoreUseCase.call(RestoreBackupParams(
          backupData: data,
          merge: false, // Currently only replace is supported
        ));

        // When data is replaced, pre-existing notification schedules are stale.
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.cancelAllNotifications();

        if (!context.mounted) return;

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Restore Successful!"),
            duration: const Duration(seconds: 8),
            action: safetyBackup != null
                ? SnackBarAction(
                    label: "UNDO",
                    onPressed: () async {
                      try {
                        await repo.clearData();
                        await repo.restoreBackup(safetyBackup!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Restore undone. Data recovered.")));
                        }
                      } catch (e, stack) {
                        debugPrint("Undo failed: $e");
                        if (kDebugMode) {
                          throw Exception("Restore UNDO failed: $e\n$stack");
                        }
                      }
                    })
                : null,
          ));
          Navigator.pop(context, true); // Go back to refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Restore Failed: ${result.failureOrThrow.message}")));
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
      try {
        final repo = ref.read(financialRepositoryProvider);
        final notificationService = ref.read(notificationServiceProvider);
        await repo.clearData();
        await notificationService.cancelAllNotifications();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("All data has been reset")));
          Navigator.pop(context, true);
        }
      } catch (e, stack) {
        debugPrint("Reset failed: $e");
        if (kDebugMode) {
          throw Exception("Application Reset failed: $e\n$stack");
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Reset failed: ${e.toString()}")));
        }
      }
    }
  }

  String _generateRecoveryKey() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking chars
    final rnd = Random();
    return List.generate(14, (index) {
      if (index == 4 || index == 9) return '-';
      return chars[rnd.nextInt(chars.length)];
    }).join();
  }

  Future<void> _showRecoveryKeyDialog(BuildContext context, String key) async {
    bool checked = false;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Recovery Key Generated"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "SAVE THIS KEY SECURELY.\n\nIf you forget your PIN, this is the ONLY way to recover your data without resetting.\n\nIf you lose this key, your data cannot be recovered."),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: key));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard")));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3))),
                        child: Text(key,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2))),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("I have safely saved this key",
                          style: TextStyle(fontSize: 14)),
                      value: checked,
                      onChanged: (v) => setState(() => checked = v ?? false))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      // ignore: deprecated_member_use
                      Share.share(
                          "TrueLedger Recovery Key: $key\n\nKEEP THIS KEY SAFE. If you lose this, you lose access to your encrypted data.");
                    },
                    child: const Text("SHARE SECURELY")),
                TextButton(
                    onPressed: checked ? () => Navigator.pop(ctx) : null,
                    child: const Text("DONE"))
              ],
            );
          });
        });
  }

  Future<bool> _verifyPin(BuildContext context, String correctPin) async {
    String input = "";
    return await showDialog<bool>(
            context: context,
            builder: (ctx) {
              bool obscure = true;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Verify PIN"),
                    content: TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      obscureText: obscure,
                      maxLength: correctPin.length,
                      onChanged: (v) => input = v,
                      decoration: InputDecoration(
                        hintText: "Enter current PIN",
                        suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("CANCEL")),
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(ctx, input == correctPin),
                          child: const Text("VERIFY")),
                    ],
                  );
                },
              );
            }) ??
        false;
  }

  Future<void> _setupPin(BuildContext context) async {
    const storage = FlutterSecureStorage();
    final currentPin = await storage.read(key: 'app_pin');

    if (!context.mounted) return;

    if (currentPin != null) {
      // PIN is set - Show management options
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("App Security"),
                content: const Text("Manage your security settings."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CANCEL",
                          style: TextStyle(color: Colors.grey))),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        // Verify PIN first
                        bool verified = await _verifyPin(context, currentPin);
                        if (verified && context.mounted) {
                          final key = await storage.read(key: 'recovery_key') ??
                              "No key found (Legacy)";
                          if (context.mounted) {
                            _showRecoveryKeyDialog(context, key);
                          }
                        }
                      },
                      child: const Text("VIEW RECOVERY KEY",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);

                        // Verify PIN first before removing
                        bool verified = await _verifyPin(context, currentPin);
                        if (!verified) return;

                        if (!context.mounted) return;

                        final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                                    title: const Text("Remove Security PIN?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text("CANCEL")),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text("REMOVE",
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ]));

                        if (confirm == true) {
                          await storage.delete(key: 'app_pin');
                          await storage.delete(key: 'recovery_key');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("PIN Removed")));
                          }
                        }
                      },
                      child: const Text("REMOVE PIN",
                          style: TextStyle(color: Colors.red))),
                ],
              ));
    } else {
      // Set new PIN
      String newPin = "";
      int targetLength = 4;

      await showDialog(
          context: context,
          builder: (ctx) {
            bool obscure = true;
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text("Set $targetLength-Digit PIN"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: targetLength,
                      obscureText: obscure,
                      onChanged: (val) => newPin = val,
                      decoration: InputDecoration(
                        hintText: "Enter PIN",
                        suffixIcon: IconButton(
                          icon: Icon(obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            targetLength = targetLength == 4 ? 6 : 4;
                            newPin = "";
                          });
                        },
                        child: Text(targetLength == 4
                            ? "Use 6-Digit PIN"
                            : "Use 4-Digit PIN"))
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CANCEL")),
                  TextButton(
                      onPressed: () async {
                        if (newPin.length == targetLength) {
                          // 1. Generate Key
                          final key = _generateRecoveryKey();

                          // 2. Save Both
                          await storage.write(key: 'app_pin', value: newPin);
                          await storage.write(key: 'recovery_key', value: key);

                          // 3. Close PIN dialog
                          if (ctx.mounted) Navigator.pop(ctx);

                          // 4. Show Key Dialog
                          if (context.mounted) {
                            await _showRecoveryKeyDialog(context, key);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("PIN Enabled Securely")));
                            }
                          }
                        }
                      },
                      child: const Text("SAVE")),
                ],
              );
            });
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
            "User Name",
            ref.watch(userProvider),
            Icons.person_outline_rounded,
            Colors.blue,
            () => _showNamePicker(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Trust & Privacy",
            "Data health & security",
            Icons.verified_user_outlined,
            Colors.green,
            () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TrustCenterScreen())),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Appearance",
            "Switch between Light, Dark, or System theme",
            Icons.dark_mode_outlined,
            Colors.indigo,
            () => _showThemePicker(context, ref),
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
            "Choose your preferred currency (${CurrencyFormatter.symbol})",
            Icons.payments_outlined,
            Colors.teal,
            () => _showCurrencyPicker(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Manage Categories",
            "Add, edit, or remove your personal categories",
            Icons.category_outlined,
            Colors.orange,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageCategoriesScreen())),
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
            "Secure Backup",
            "Creates an encrypted data package",
            Icons.cloud_upload_outlined,
            Colors.blueAccent,
            () => _backupData(context, ref),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            "Restore Data",
            "Import from encrypted backup",
            Icons.restore_page_outlined,
            Colors.orange,
            () => _restoreData(context, ref),
          ),
          const SizedBox(height: 16),
          if (kDebugMode) ...[
            _buildOption(
              context,
              "Seed Sample Data",
              "Populate app with demo entries",
              Icons.science_rounded,
              Colors.amber,
              () => _seedData(context, ref),
            ),
            const SizedBox(height: 16),
          ],
          _buildOption(
            context,
            "Reset Application",
            "Clear all data and start fresh",
            Icons.refresh_rounded,
            Colors.redAccent,
            () => _resetData(context, ref),
          ),
          const SizedBox(height: 48), // ... rest of build

          Center(
            child: Column(
              children: [
                const Text("TRUELEDGER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey)),
                ref.watch(appVersionProvider).when(
                      data: (version) => Text("Version $version",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const Text("Version 1.1.0",
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                const SizedBox(height: 12),
                const Text(
                  "TrueLedger stores all data locally on your device.\nNo data is transmitted or stored on external servers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => launchUrl(Uri.parse(
                      "https://satyakommula96.github.io/trueledger/privacy/")),
                  child: const Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
