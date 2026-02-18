import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:trueledger/core/utils/web_saver.dart';
import 'package:trueledger/core/services/file_service.dart';
import 'package:trueledger/data/dtos/insight_dto.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/domain/usecases/restore_backup_usecase.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/services/intelligence_service.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/data/datasources/database.dart';
import 'package:trueledger/core/services/backup_encryption_service.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/l10n/app_localizations.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _isExporting = false;
  bool _encryptFullExport = false;
  DateTimeRange? _selectedDateRange;

  Future<void> _exportCompleteData() async {
    setState(() => _isExporting = true);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(financialRepositoryProvider);
      final dashboardData = await ref.read(dashboardProvider.future);
      final intelligenceService = ref.read(intelligenceServiceProvider);

      final insights = intelligenceService.generateInsights(
        summary: dashboardData.summary,
        trendData: dashboardData.trendData,
        budgets: dashboardData.budgets,
        categorySpending: dashboardData.categorySpending,
        requestedSurface: InsightSurface.details,
        forceRefresh: true,
      );

      final data = await repo.generateBackup();
      final prefs = ref.read(sharedPreferencesProvider);
      final insightHistory = prefs.getString('insight_display_history');
      final insightKindHistory = prefs.getString('insight_kind_history');

      data['version'] = '2.0';
      data['insights'] =
          insights.map((e) => AIInsightDto.fromDomain(e).toJson()).toList();
      data['insights_meta'] = {
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
        String? password = await _showBackupPasswordDialog(semantic, l10n);
        if (password == null || password.isEmpty) {
          setState(() => _isExporting = false);
          return;
        }

        final encryptedData =
            BackupEncryptionService.encryptData(jsonString, password);
        final container = {
          'version': '2.0',
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
          dialogTitle: _encryptFullExport
              ? l10n.saveEncryptedExport
              : l10n.saveFullExport,
          fileName: actualFileName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (outputFile != null) {
          final fileService = ref.read(fileServiceProvider);
          await fileService.writeAsString(outputFile, finalOutput);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.exportSaved(outputFile).toUpperCase()),
                backgroundColor: semantic.primary,
              ),
            );
          }
        }
        setState(() => _isExporting = false);
        return;
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$actualFileName');
        await file.writeAsString(finalOutput);
        await SharePlus.instance.share(ShareParams(
            files: [XFile(file.path)],
            subject:
                _encryptFullExport ? l10n.encryptBackup : l10n.oneTapArchive,
            text: _encryptFullExport
                ? l10n.encryptBackupSubtitle
                : l10n.dataSovereigntyDescription));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fullDataExportCompleted),
            backgroundColor: semantic.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString()).toUpperCase()),
            backgroundColor: semantic.overspent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<String?> _showBackupPasswordDialog(
      AppColors semantic, AppLocalizations l10n) async {
    String input = "";
    bool obscure = true;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5),
            ),
            title: Text(l10n.encryptBackup.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    color: semantic.text)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.encryptBackupSubtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: semantic.text,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextField(
                  autofocus: true,
                  obscureText: obscure,
                  style: TextStyle(
                      color: semantic.text, fontWeight: FontWeight.w900),
                  onChanged: (v) => input = v,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    labelStyle: TextStyle(
                        color: semantic.secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1),
                    filled: true,
                    fillColor: semantic.surfaceCombined.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: semantic.secondaryText),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel.toUpperCase(),
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w900,
                          fontSize: 12))),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, input),
                style: ElevatedButton.styleFrom(
                    backgroundColor: semantic.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(l10n.backupCreated.toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportCSV(String type) async {
    setState(() => _isExporting = true);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(financialRepositoryProvider);
      List<List<dynamic>> rows = [];
      String fileName = "";

      if (type == 'transactions') {
        final txs = await repo.getAllValues('variable_expenses');
        final income = await repo.getAllValues('income_sources');
        final fixed = await repo.getAllValues('fixed_expenses');
        final investments = await repo.getAllValues('investments');

        final allItems = [
          ...txs.map((e) => {...e, 'type': 'Expense'}),
          ...income.map((e) => {...e, 'type': 'Income'}),
          ...fixed.map((e) => {...e, 'type': 'Fixed Expense'}),
          ...investments.map((e) => {...e, 'type': 'Investment'}),
        ];

        // Filter by date range if selected
        final filteredItems = _selectedDateRange == null
            ? allItems
            : allItems.where((item) {
                final date = DateTime.parse(item['date']);
                return date.isAfter(_selectedDateRange!.start
                        .subtract(const Duration(days: 1))) &&
                    date.isBefore(
                        _selectedDateRange!.end.add(const Duration(days: 1)));
              }).toList();

        // Sort by date descending
        filteredItems.sort((a, b) => b['date'].compareTo(a['date']));

        rows.add(['ID', 'Date', 'Type', 'Amount', 'Label/Category', 'Note']);
        for (var item in filteredItems) {
          rows.add([
            item['id'],
            item['date'],
            item['type'],
            item['amount'],
            item['category'] ?? item['source'] ?? item['name'] ?? '',
            item['note'] ?? ''
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
        final dashboardData = await ref.read(dashboardProvider.future);
        final intelligenceService = ref.read(intelligenceServiceProvider);
        final insights = intelligenceService.generateInsights(
          summary: dashboardData.summary,
          trendData: dashboardData.trendData,
          budgets: dashboardData.budgets,
          categorySpending: dashboardData.categorySpending,
          requestedSurface: InsightSurface.details,
          forceRefresh: true,
          ignoreCooldown: true,
        );

        rows.add(['ID', 'Title', 'Type', 'Priority', 'Body', 'Value']);
        for (var i in insights) {
          rows.add(
              [i.id, i.title, i.type.name, i.priority.name, i.body, i.value]);
        }
        fileName =
            "trueledger_insights_${DateTime.now().millisecondsSinceEpoch}.csv";
      } else if (type == 'loans') {
        final loans = await repo.getLoans();
        rows.add([
          'ID',
          'Name',
          'Type',
          'Total Amount',
          'Remaining',
          'EMI',
          'Rate',
          'Due Day',
          'Last Payment'
        ]);
        for (var l in loans) {
          rows.add([
            l.id,
            l.name,
            l.loanType,
            l.totalAmount,
            l.remainingAmount,
            l.emi,
            l.interestRate,
            l.dueDate,
            l.lastPaymentDate ?? 'N/A'
          ]);
        }
        fileName =
            "trueledger_loans_${DateTime.now().millisecondsSinceEpoch}.csv";
      }

      if (rows.length <= 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noDataFoundToExport),
              backgroundColor: semantic.secondaryText,
            ),
          );
        }
        setState(() => _isExporting = false);
        return;
      }

      String csv = const CsvEncoder().convert(rows);
      if (kIsWeb) {
        await saveFileWeb(utf8.encode(csv), fileName);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: l10n.saveCsvExport,
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
                content: Text("${type.toUpperCase()} SAVED TO $outputFile"),
                backgroundColor: semantic.primary,
              ),
            );
          }
        }
        setState(() => _isExporting = false);
        return;
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csv);
        await SharePlus.instance.share(ShareParams(
            files: [XFile(file.path)],
            subject: 'TrueLedger ${type.toUpperCase()} Export',
            text: 'Sharing my TrueLedger $type export.'));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccessful(type).toUpperCase()),
            backgroundColor: semantic.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString()).toUpperCase()),
            backgroundColor: semantic.overspent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPDF() async {
    setState(() => _isExporting = true);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    try {
      final repo = ref.read(financialRepositoryProvider);

      final txs = await repo.getAllValues('variable_expenses');
      final income = await repo.getAllValues('income_sources');
      final fixed = await repo.getAllValues('fixed_expenses');
      final investments = await repo.getAllValues('investments');

      final allItems = [
        ...txs.map((e) => {...e, 'type': 'Expense'}),
        ...income.map((e) => {...e, 'type': 'Income'}),
        ...fixed.map((e) => {...e, 'type': 'Fixed Expense'}),
        ...investments.map((e) => {...e, 'type': 'Investment'}),
      ];

      // Filter by date range
      final filteredItems = _selectedDateRange == null
          ? allItems
          : allItems.where((item) {
              final date = DateTime.parse(item['date']);
              return date.isAfter(_selectedDateRange!.start
                      .subtract(const Duration(days: 1))) &&
                  date.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)));
            }).toList();

      filteredItems.sort((a, b) => b['date'].compareTo(a['date']));

      final pdf = pw.Document();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (var item in filteredItems) {
        final amount = (item['amount'] as num).toDouble();
        if (item['type'] == 'Income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      // Load fonts with fallback to default
      pw.Font? font;
      pw.Font? fontBold;
      try {
        font = await PdfGoogleFonts.notoSansRegular();
        fontBold = await PdfGoogleFonts.notoSansBold();
      } catch (e) {
        // Fallback to default fonts if asset loading fails
        font = null;
        fontBold = null;
      }

      pdf.addPage(
        pw.MultiPage(
          maxPages: 1000,
          pageFormat: PdfPageFormat.a4,
          theme: font != null && fontBold != null
              ? pw.ThemeData.withFont(base: font, bold: fontBold)
              : null,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TrueLedger Report',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        _selectedDateRange != null
                            ? '${_selectedDateRange!.start.toString().split(' ')[0]} to ${_selectedDateRange!.end.toString().split(' ')[0]}'
                            : l10n.allTime,
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(children: [
                    pw.Text('Total Income',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(totalIncome.toStringAsFixed(2),
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                  ]),
                  pw.Column(children: [
                    pw.Text('Total Expenses',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(totalExpense.toStringAsFixed(2),
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ]),
                  pw.Column(children: [
                    pw.Text('Net Savings',
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text((totalIncome - totalExpense).toStringAsFixed(2),
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue)),
                  ]),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Category', 'Note', 'Amount'],
                data: filteredItems.map((item) {
                  return [
                    item['date'].toString().split(' ')[0],
                    item['type'],
                    item['category'] ?? item['source'] ?? item['name'] ?? '',
                    (item['note'] ?? '').toString().length > 20
                        ? "${(item['note'] ?? '').toString().substring(0, 20)}..."
                        : (item['note'] ?? ''),
                    (item['amount'] as num).toStringAsFixed(2),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200)),
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerRight,
                },
              ),
            ];
          },
        ),
      );

      final fileName =
          "trueledger_report_${DateTime.now().millisecondsSinceEpoch}.pdf";

      if (kIsWeb) {
        await saveFileWeb(await pdf.save(), fileName);
      } else {
        await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfGenerated),
            backgroundColor: semantic.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed(e.toString()).toUpperCase()),
            backgroundColor: semantic.overspent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _restoreData() async {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
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
      Map<String, dynamic> data;
      if (container['encrypted'] == true) {
        try {
          final deviceKey = await AppDatabase.getEncryptionKey();
          final decryptedJson =
              BackupEncryptionService.decryptData(container['data'], deviceKey);
          data = jsonDecode(decryptedJson) as Map<String, dynamic>;
        } catch (_) {
          String? password = await _showRestorePasswordDialog(semantic, l10n);
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
        builder: (ctx) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5),
            ),
            title: Text(l10n.restoreDataTitle.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    color: semantic.overspent)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restoreReplaceWarning,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.restoreAutoBackupNotice,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel.toUpperCase(),
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w900))),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: semantic.overspent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(l10n.restore,
                      style: const TextStyle(fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      );

      if (confirmed == true) {
        setState(() => _isExporting = true);
        final repo = ref.read(financialRepositoryProvider);
        final restoreUseCase = ref.read(restoreBackupUseCaseProvider);

        Map<String, dynamic>? safetyBackup;
        try {
          safetyBackup = await repo.generateBackup();
        } catch (e) {
          debugPrint("Safety backup failed: $e");
        }

        final result = await restoreUseCase.call(RestoreBackupParams(
          backupData: data,
          merge: false,
        ));

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

        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.cancelAllNotifications();

        if (mounted) {
          setState(() => _isExporting = false);
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.restoreSuccessful),
                duration: const Duration(seconds: 8),
                action: safetyBackup != null
                    ? SnackBarAction(
                        label: l10n.undo.toUpperCase(),
                        onPressed: () async {
                          try {
                            await repo.clearData();
                            await repo.restoreBackup(safetyBackup!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.restoreUndone)));
                            }
                          } catch (e) {
                            debugPrint("Undo failed: $e");
                          }
                        })
                    : null,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(l10n
                      .restoreFailedDetailed(result.failureOrThrow.message))),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ERROR DURING RESTORE: $e")),
        );
      }
    }
  }

  Future<String?> _showRestorePasswordDialog(
      AppColors semantic, AppLocalizations l10n) async {
    String input = "";
    bool obscure = true;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(color: semantic.divider, width: 1.5)),
            title: Text(l10n.decryptBackup.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                    color: semantic.text)),
            content: TextField(
              autofocus: true,
              obscureText: obscure,
              style:
                  TextStyle(color: semantic.text, fontWeight: FontWeight.w900),
              onChanged: (v) => input = v,
              decoration: InputDecoration(
                labelText: "PASSWORD",
                labelStyle: TextStyle(
                    color: semantic.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
                filled: true,
                fillColor: semantic.surfaceCombined.withValues(alpha: 0.3),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                suffixIcon: IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: semantic.secondaryText),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("CANCEL",
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w900))),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, input),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: semantic.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(l10n.decrypt.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dataExport.toUpperCase()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, 48 + MediaQuery.of(context).padding.bottom),
            children: [
              _buildHeader(semantic, l10n),
              const SizedBox(height: 32),
              _buildOneTapSection(semantic, l10n),
              const SizedBox(height: 32),
              _buildRestoreSection(semantic, l10n),
              const SizedBox(height: 32),
              _buildSectionHeader(
                  l10n.individualReports.toUpperCase(), semantic),
              const SizedBox(height: 12),
              _buildDateFilter(semantic, l10n),
              const SizedBox(height: 16),

              // Adaptive Grid Layout for export options
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth,
                        child: _buildExportOption(
                          title: l10n.transactions,
                          subtitle: l10n.transactionsSubtitle,
                          icon: Icons.list_alt_rounded,
                          color: Colors.blue,
                          onTap: () => _exportCSV('transactions'),
                          semantic: semantic,
                          l10n: l10n,
                        ),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth,
                        child: _buildExportOption(
                          title: l10n.pdfReport,
                          subtitle: l10n.pdfReportSubtitle,
                          icon: Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          onTap: _exportPDF,
                          semantic: semantic,
                          l10n: l10n,
                        ),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth,
                        child: _buildExportOption(
                          title: l10n.budgets.toUpperCase(),
                          subtitle: l10n.budgetsSubtitle,
                          icon: Icons.pie_chart_outline_rounded,
                          color: Colors.orange,
                          onTap: () => _exportCSV('budgets'),
                          semantic: semantic,
                          l10n: l10n,
                        ),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth,
                        child: _buildExportOption(
                          title: l10n.aiInsights.toUpperCase(),
                          subtitle: l10n.aiInsightsSubtitle,
                          icon: Icons.auto_awesome_outlined,
                          color: Colors.purple,
                          onTap: () => _exportCSV('insights'),
                          semantic: semantic,
                          l10n: l10n,
                        ),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth,
                        child: _buildExportOption(
                          title: l10n.loans.toUpperCase(),
                          subtitle: l10n.loansSubtitle,
                          icon: Icons.account_balance_rounded,
                          color: Colors.redAccent,
                          onTap: () => _exportCSV('loans'),
                          semantic: semantic,
                          l10n: l10n,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              _buildOwnershipNotice(semantic, l10n),
            ],
          ),
          if (_isExporting)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: CircularProgressIndicator(color: semantic.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors semantic) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: semantic.secondaryText,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors semantic, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: semantic.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
                color: semantic.primary.withValues(alpha: 0.1), width: 2),
          ),
          child: Icon(
            Icons.account_tree_rounded,
            size: 48,
            color: semantic.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.dataSovereignty.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: semantic.text,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.dataSovereigntyDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: semantic.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.5),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildOneTapSection(AppColors semantic, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [semantic.primary, semantic.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: semantic.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  l10n.oneTapArchive.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.oneTapArchiveDescription,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.5,
                letterSpacing: -0.2),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _encryptFullExport = !_encryptFullExport),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _encryptFullExport,
                        onChanged: (v) =>
                            setState(() => _encryptFullExport = v ?? false),
                        activeColor: Colors.white,
                        checkColor: semantic.primary,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(l10n.encryptBackup.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _exportCompleteData,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.exportNow.toUpperCase(),
                    style: TextStyle(
                        color: semantic.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 800.ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildRestoreSection(AppColors semantic, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _restoreData,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: semantic.overspent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.history_rounded,
                      color: semantic.overspent, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.restoreBackup.toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text(l10n.restoreBackupSubtitle,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: semantic.divider, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required AppColors semantic,
    required AppLocalizations l10n,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: semantic.secondaryText)),
                    ],
                  ),
                ),
                Icon(Icons.download_rounded,
                    color: semantic.divider.withValues(alpha: 0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter(AppColors semantic, AppLocalizations l10n) {
    return HoverWrapper(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _selectedDateRange,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: semantic.primary,
                  onPrimary: Colors.white,
                  surface: semantic.surfaceCombined,
                  onSurface: semantic.text,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDateRange = picked);
        }
      },
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: semantic.divider, width: 1.5)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: semantic.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.date_range_rounded,
                  size: 18, color: semantic.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dateRange.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: semantic.secondaryText,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDateRange == null
                        ? l10n.allTime
                        : "${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: semantic.text),
                  ),
                ],
              ),
            ),
            if (_selectedDateRange != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _selectedDateRange = null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more_rounded, color: semantic.divider),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnershipNotice(AppColors semantic, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: semantic.divider, width: 1.5, style: BorderStyle.none),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 20, color: semantic.secondaryText),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.dataOwnershipNotice,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
