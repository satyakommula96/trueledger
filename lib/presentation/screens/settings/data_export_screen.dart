import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trueledger/core/utils/web_saver.dart';
import 'package:trueledger/core/services/file_service.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _isExporting = false;
  bool _encryptFullExport = false;

  Future<void> _exportCompleteData() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(financialRepositoryProvider);

      // Ensure dashboard data is ready for comprehensive insights
      final dashboardData = await ref.read(dashboardProvider.future);
      final intelligenceService = ref.read(intelligenceServiceProvider);

      final insights = intelligenceService.generateInsights(
        summary: dashboardData.summary,
        trendData: dashboardData.trendData,
        budgets: dashboardData.budgets,
        categorySpending: dashboardData.categorySpending,
        requestedSurface: InsightSurface.details, // Get all insights for export
        forceRefresh: true,
      );

      final data = await repo.generateBackup();

      // Capture Insight Metadata (History/Dismissals)
      final prefs = ref.read(sharedPreferencesProvider);
      final insightHistory = prefs.getString('insight_display_history');
      final insightKindHistory = prefs.getString('insight_kind_history');

      // Compatibility: Update version to 2.0 for comprehensive export
      data['version'] = '2.0';
      data['insights'] = insights.map((e) => e.toJson()).toList();
      data['insights_meta'] = {
        // Persist history so dismissals/snoozes are respected on restore
        'display_history':
            insightHistory != null ? jsonDecode(insightHistory) : {},
        'kind_history':
            insightKindHistory != null ? jsonDecode(insightKindHistory) : {},
      };
      data['export_metadata'] = {
        'date': DateTime.now().toIso8601String(),
        'app': "TrueLedger",
        'version': '1.0.0',
        'type': 'FULL_DATA_DUMP'
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      String finalOutput;
      String actualFileName =
          "trueledger_full_export_${DateTime.now().millisecondsSinceEpoch}.json";

      if (_encryptFullExport) {
        String? password = await _showBackupPasswordDialog();
        if (password == null || password.isEmpty) {
          setState(() => _isExporting = false);
          return;
        }

        // Encrypt Data
        final encryptedData =
            BackupEncryptionService.encryptData(jsonString, password);

        // Wrap in container JSON
        final container = {
          'version': '2.0', // Container version
          'encrypted': true,
          'data': encryptedData,
          'date': DateTime.now().toIso8601String(),
        };
        finalOutput = jsonEncode(container);
        actualFileName =
            "trueledger_full_export_enc_${DateTime.now().millisecondsSinceEpoch}.json";
      } else {
        finalOutput = jsonString;
      }

      if (kIsWeb) {
        await saveFileWeb(utf8.encode(finalOutput), actualFileName);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle:
              _encryptFullExport ? 'Save Encrypted Export' : 'Save Full Export',
          fileName: actualFileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final fileService = ref.read(fileServiceProvider);
          await fileService.writeAsString(outputFile, finalOutput);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Export saved to $outputFile")),
            );
          }
        }
        setState(() => _isExporting = false);
        return;
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$actualFileName');
        await file.writeAsString(finalOutput);
        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(file.path)],
            subject: _encryptFullExport
                ? 'TrueLedger Encrypted Export'
                : 'TrueLedger Data Export',
            text: _encryptFullExport
                ? 'Here is my secure encrypted financial data export from TrueLedger.'
                : 'Here is my complete financial data export from TrueLedger.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Full data export completed successfully"),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Export failed: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _backupData() async {
    final repo = ref.read(financialRepositoryProvider);

    // 1. Ask for encryption password
    String? password = await _showBackupPasswordDialog();
    if (password == null || password.isEmpty) return;

    setState(() => _isExporting = true);

    try {
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
        await ref.read(lastBackupTimeProvider.notifier).updateLastBackupTime();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Backup download started")));
        }
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Encrypted Backup',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final fileService = ref.read(fileServiceProvider);
          await fileService.writeAsString(outputFile, finalOutput);
          await ref
              .read(lastBackupTimeProvider.notifier)
              .updateLastBackupTime();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Encrypted backup saved to $outputFile")));
          }
        }
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        final fileService = ref.read(fileServiceProvider);
        await fileService.writeAsString(file.path, finalOutput);
        await ref.read(lastBackupTimeProvider.notifier).updateLastBackupTime();
        if (mounted) {
          // ignore: deprecated_member_use
          await Share.shareXFiles([XFile(file.path)],
              text: 'TrueLedger Encrypted Backup');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backup failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String?> _showBackupPasswordDialog() async {
    String input = "";
    bool obscure = true;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                      icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off),
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
        ),
      ),
    );
  }

  Future<void> _exportCSV(String type) async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(financialRepositoryProvider);
      List<List<dynamic>> rows = [];
      String fileName = "";

      if (type == 'transactions') {
        final txs = await repo.getAllValues('variable_expenses');
        final income = await repo.getAllValues('income_sources');
        final fixed = await repo.getAllValues('fixed_expenses');
        final investments = await repo.getAllValues('investments');

        rows.add(['ID', 'Date', 'Type', 'Amount', 'Label/Category', 'Note']);
        for (var tx in txs) {
          rows.add([
            tx['id'],
            tx['date'],
            'Expense',
            tx['amount'],
            tx['category'],
            tx['note']
          ]);
        }
        for (var inc in income) {
          rows.add([
            inc['id'],
            inc['date'],
            'Income',
            inc['amount'],
            inc['source'],
            inc['note']
          ]);
        }
        for (var f in fixed) {
          rows.add([
            f['id'],
            f['date'],
            'Fixed Expense',
            f['amount'],
            f['category'],
            f['note']
          ]);
        }
        for (var inv in investments) {
          rows.add([
            inv['id'],
            inv['date'],
            'Investment',
            inv['amount'],
            inv['name'],
            inv['note']
          ]);
        }
        fileName =
            "trueledger_transactions_${DateTime.now().millisecondsSinceEpoch}.csv";
      } else if (type == 'budgets') {
        final budgets = await repo.getBudgets();
        rows.add(['ID', 'Category', 'Monthly Limit', 'Last Reviewed']);
        for (var b in budgets) {
          rows.add([
            b.id,
            b.category,
            b.monthlyLimit,
            b.lastReviewedAt?.toIso8601String()
          ]);
        }
        fileName =
            "trueledger_budgets_${DateTime.now().millisecondsSinceEpoch}.csv";
      } else if (type == 'insights') {
        // Fetch dashboard data and generate full insights list
        final dashboardData = await ref.read(dashboardProvider.future);
        final intelligenceService = ref.read(intelligenceServiceProvider);

        final insights = intelligenceService.generateInsights(
          summary: dashboardData.summary,
          trendData: dashboardData.trendData,
          budgets: dashboardData.budgets,
          categorySpending: dashboardData.categorySpending,
          requestedSurface:
              InsightSurface.details, // Show all priorities in export
          forceRefresh: true,
        );

        rows.add(['ID', 'Title', 'Type', 'Priority', 'Body', 'Value']);
        for (var i in insights) {
          rows.add(
              [i.id, i.title, i.type.name, i.priority.name, i.body, i.value]);
        }
        fileName =
            "trueledger_insights_${DateTime.now().millisecondsSinceEpoch}.csv";
      }

      if (rows.length <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No $type data found to export."),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isExporting = false);
        return;
      }

      String csv = const ListToCsvConverter().convert(rows);
      if (kIsWeb) {
        await saveFileWeb(utf8.encode(csv), fileName);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save ${type.capitalize()} Export',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final fileService = ref.read(fileServiceProvider);
          await fileService.writeAsString(outputFile, csv);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("${type.capitalize()} saved to $outputFile")),
            );
          }
        }
        setState(() => _isExporting = false);
        return;
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        // ignore: deprecated_member_use
        await Share.shareXFiles([XFile(file.path)],
            subject: 'TrueLedger ${type.capitalize()} Export',
            text: 'Sharing my TrueLedger $type export.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${type.capitalize()} exported successfully"),
            backgroundColor: Colors.blue[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("CSV Export failed: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _restoreData() async {
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
        // 1. Try Auto-Decryption with Device Key (for auto-backups)
        try {
          final deviceKey = await AppDatabase.getEncryptionKey();
          final decryptedJson =
              BackupEncryptionService.decryptData(container['data'], deviceKey);
          data = jsonDecode(decryptedJson) as Map<String, dynamic>;
        } catch (_) {
          // 2. Fallback: Ask user for password
          String? password = await _showPasswordDialog();
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
        // Legacy or unencrypted export
        data = container;
      }

      if (data['version'] != '1.0' &&
          data['version'] != '1.1' &&
          data['version'] != '2.0') {
        throw "Unsupported backup version: ${data['version']}";
      }

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Restore Data?"),
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
                "• Your current state will be AUTO-BACKUPED before proceeding.\n• This action can be undone immediately after restore.",
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
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("RESTORE")),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() => _isExporting = true);
        final repo = ref.read(financialRepositoryProvider);
        final restoreUseCase = ref.read(restoreBackupUseCaseProvider);

        // Immediate safety backup for in-app UNDO
        Map<String, dynamic>? safetyBackup;
        try {
          safetyBackup = await repo.generateBackup();
        } catch (e) {
          debugPrint("In-memory safety backup failed: $e");
        }

        final result = await restoreUseCase.call(RestoreBackupParams(
          backupData: data,
          merge: false,
        ));

        // Restore Insight Metadata
        if (data.containsKey('insights_meta')) {
          final meta = data['insights_meta'];
          final prefs = ref.read(sharedPreferencesProvider);
          if (meta['display_history'] != null) {
            await prefs.setString(
                'insight_display_history', jsonEncode(meta['display_history']));
          }
          if (meta['kind_history'] != null) {
            await prefs.setString(
                'insight_kind_history', jsonEncode(meta['kind_history']));
          }
        }

        // When data is replaced, pre-existing notification schedules are stale.
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.cancelAllNotifications();

        if (mounted) {
          setState(() => _isExporting = false);
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Restore Successful!"),
                duration: const Duration(seconds: 8),
                action: safetyBackup != null
                    ? SnackBarAction(
                        label: "UNDO",
                        onPressed: () async {
                          try {
                            await repo.clearData();
                            await repo.restoreBackup(safetyBackup!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Restore undone. Data recovered.")));
                            }
                          } catch (e) {
                            debugPrint("Undo failed: $e");
                          }
                        })
                    : null,
              ),
            );
            Navigator.pop(context, true); // Go back to refresh
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Restore Failed: ${result.failureOrThrow.message}")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error during restore: $e")),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    String input = "";
    bool obscure = true;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Decrypt Backup"),
          content: TextField(
            autofocus: true,
            obscureText: obscure,
            onChanged: (v) => input = v,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CANCEL")),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, input),
                child: const Text("DECRYPT")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data & Export"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildOneTapSection(context),
              const SizedBox(height: 32),
              _buildRestoreSection(context),
              const SizedBox(height: 32),
              Text(
                "INDIVIDUAL REPORTS (CSV)",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              _buildExportOption(
                context: context,
                title: "Transactions",
                subtitle: "Expenses, income and investments",
                icon: Icons.list_alt_rounded,
                color: Colors.blue,
                onTap: () => _exportCSV('transactions'),
              ),
              const SizedBox(height: 16),
              _buildExportOption(
                context: context,
                title: "Budgets",
                subtitle: "Monthly limits and category targets",
                icon: Icons.pie_chart_outline_rounded,
                color: Colors.orange,
                onTap: () => _exportCSV('budgets'),
              ),
              const SizedBox(height: 16),
              _buildExportOption(
                context: context,
                title: "AI Insights",
                subtitle: "Financial patterns and health analysis",
                icon: Icons.auto_awesome_outlined,
                color: Colors.purple,
                onTap: () => _exportCSV('insights'),
              ),
              const SizedBox(height: 40),
              _buildOwnershipNotice(context),
            ],
          ),
          if (_isExporting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.file_upload_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          "Your Data, Your Control",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Export your financial records anytime. We believe in complete data portability and ownership.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOneTapSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(77),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "ONE-TAP EXPORT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Download your entire financial footprint including history, budgets, and insights in a machine-readable JSON format.\n\nExport is local-only. No cloud sync or external services.",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white70,
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _encryptFullExport,
                  onChanged: (v) =>
                      setState(() => _encryptFullExport = v ?? false),
                  title: const Text(
                    "Encrypt this export",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    "Highly recommended for sensitive data",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.white,
                  checkColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isExporting ? null : _exportCompleteData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleEdges(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _encryptFullExport
                        ? "Secure Export (JSON)"
                        : "Export Everything (JSON)",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildExportOption(
          context: context,
          title: "Secure Backup",
          subtitle: "Creates an encrypted data package",
          icon: Icons.cloud_upload_outlined,
          color: Colors.blueAccent,
          onTap: _backupData,
        ),
      ],
    );
  }

  Widget _buildRestoreSection(BuildContext context) {
    return _buildExportOption(
      context: context,
      title: "Restore Data",
      subtitle: "Import from standard or encrypted backups",
      icon: Icons.restore_page_outlined,
      color: Colors.orange,
      onTap: _restoreData,
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).dividerColor.withAlpha(25)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnershipNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                "Privacy Note",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "These files contain sensitive financial data. Keep them in a safe place or delete them after use. TrueLedger never stores or sees your exported files.",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

class RoundedRectangleEdges extends RoundedRectangleBorder {
  const RoundedRectangleEdges(
      {super.borderRadius = BorderRadius.zero, super.side = BorderSide.none});
}
