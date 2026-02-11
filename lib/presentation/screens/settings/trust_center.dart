import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/backup_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trueledger/domain/usecases/get_local_backups_usecase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:trueledger/core/config/app_config.dart';
import 'package:trueledger/domain/usecases/restore_from_local_file_usecase.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(financialRepositoryProvider).getDatabaseStats();
});

class TrustCenterScreen extends ConsumerWidget {
  const TrustCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final statsAsync = ref.watch(databaseStatsProvider);
    final lastBackup = ref.watch(lastBackupTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRUST CENTER"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 48 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFraming(context, semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("OUR GUARANTEES", semantic),
            const SizedBox(height: 16),
            _buildGuaranteesGrid(semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("STRICT POLICIES", semantic),
            const SizedBox(height: 16),
            _buildNeverList(semantic),
            const SizedBox(height: 32),
            _buildSectionHeader("DATA HEALTH", semantic),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                children: [
                  _StatCard(
                      label: "TOTAL RECORDS",
                      value: stats['total_records'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "EXPENSES",
                      value: stats['variable'].toString(),
                      semantic: semantic,
                      color: semantic.overspent),
                  _StatCard(
                      label: "INCOME",
                      value: stats['income'].toString(),
                      semantic: semantic,
                      color: semantic.income),
                  _StatCard(
                      label: "BUDGETS",
                      value: stats['budgets'].toString(),
                      semantic: semantic),
                ],
              ),
              loading: () => Center(
                  child: CircularProgressIndicator(color: semantic.primary)),
              error: (e, s) => Text("Error loading stats: $e",
                  style: TextStyle(color: semantic.overspent)),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("BACKUP CONFIDENCE", semantic),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: semantic.divider, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: semantic.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_rounded,
                            color: semantic.success, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("LOCAL BACKUP STATUS",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: semantic.text)),
                            const SizedBox(height: 2),
                            Text("Last backup: $lastBackup",
                                style: TextStyle(
                                    color: semantic.secondaryText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48, thickness: 1.5),
                  Row(
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          size: 16, color: semantic.secondaryText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Next automatic backup: At next application launch",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color:
                                semantic.secondaryText.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader("LOCAL BACKUPS", semantic),
                ),
                if (!kIsWeb &&
                    (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS))
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final directory =
                            await getApplicationDocumentsDirectory();
                        final backupPath =
                            '${directory.path}/${AppConfig.backupFolderName}';
                        final backupDir = Directory(backupPath);
                        if (!await backupDir.exists()) {
                          await backupDir.create(recursive: true);
                        }
                        final uri = Uri.file(backupPath);
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Could not open folder: $e")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open_rounded, size: 16),
                    label: const Text("VIEW FOLDER",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(localBackupsProvider).when(
                  data: (backups) {
                    if (backups.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            "NO LOCAL BACKUPS FOUND YET.",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: semantic.secondaryText
                                    .withValues(alpha: 0.5),
                                letterSpacing: 1),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: backups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final file = backups[index];
                        return _buildBackupItem(context, ref, file, semantic);
                      },
                    );
                  },
                  loading: () => Center(
                      child:
                          CircularProgressIndicator(color: semantic.primary)),
                  error: (e, _) => Text("Error: $e"),
                ),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "TrueLedger uses SQLCipher AES-256 for database encryption on supported platforms.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: semantic.secondaryText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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

  Widget _buildFraming(BuildContext context, AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRODUCT-LEVEL PRIVACY GUARANTEES.",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: semantic.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "TrueLedger is built on the principle that your financial life is yours alone. We believe in absolute privacy, which is why your data never leaves your device.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: semantic.text,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildGuaranteesGrid(AppColors semantic) {
    const guarantees = [
      (
        "NO ADS",
        "We never clutter your experience with advertisements or sponsored content.",
        Icons.block_rounded
      ),
      (
        "NO TRACKING",
        "We don't track your behavior, location, or usage. You are not a data point.",
        Icons.visibility_off_rounded
      ),
      (
        "NO PROFILING",
        "Your financial habits are private. We don't build profiles for targeting.",
        Icons.psychology_alt_rounded
      ),
      (
        "100% LOCAL",
        "Your database exists only on your device. We have no access to your logs.",
        Icons.devices_rounded
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < guarantees.length; i += 2) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildGuaranteeCard(guarantees[i], semantic)),
                const SizedBox(width: 16),
                if (i + 1 < guarantees.length)
                  Expanded(
                      child: _buildGuaranteeCard(guarantees[i + 1], semantic))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          if (i + 2 < guarantees.length) const SizedBox(height: 16),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildGuaranteeCard((String, String, IconData) g, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: semantic.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(g.$3, color: semantic.primary, size: 20),
          ),
          const SizedBox(height: 16),
          Text(g.$1,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: semantic.text)),
          const SizedBox(height: 8),
          Text(
            g.$2,
            style: TextStyle(
                fontSize: 11,
                color: semantic.secondaryText,
                fontWeight: FontWeight.w700,
                height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildNeverList(AppColors semantic) {
    final nevers = [
      "No analytics or tracking SDKs",
      "No behavior profiling or scoring",
      "No bank or SMS scraping",
      "No cloud sync or external storage",
      "No selling or sharing of user logs",
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        children: nevers
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: semantic.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBackupItem(BuildContext context, WidgetRef ref, BackupFile file,
      AppColors semantic) {
    return HoverWrapper(
      onTap: () {},
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: semantic.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: semantic.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_rounded,
                  size: 20, color: semantic.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm')
                        .format(file.date)
                        .toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: semantic.text),
                  ),
                  Text(
                    _formatSize(file.size),
                    style: TextStyle(
                        color: semantic.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            _buildActionIcon(Icons.settings_backup_restore_rounded,
                () => _confirmRestore(context, ref, file), semantic),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.ios_share_rounded, () {
              SharePlus.instance.share(ShareParams(
                  files: [XFile(file.path)],
                  text: 'TrueLedger Auto-Backup (${file.name})'));
            }, semantic),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(
      IconData icon, VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: semantic.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: semantic.text),
      ),
    );
  }

  Future<void> _confirmRestore(
      BuildContext context, WidgetRef ref, BackupFile file) async {
    final semantic = Theme.of(context).extension<AppColors>()!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text("RESTORE DATA?",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.overspent)),
          content: const Text(
            "This will REPLACE all your current data with the data from this backup. This action cannot be undone.",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("CANCEL",
                    style: TextStyle(
                        color: semantic.secondaryText,
                        fontWeight: FontWeight.w900))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: semantic.overspent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("RESTORE NOW",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    final useCase = ref.read(restoreFromLocalFileUseCaseProvider);
    final result = await useCase(RestoreFromLocalFileParams(path: file.path));

    if (context.mounted) {
      Navigator.pop(context); // Pop loading
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text("RESTORE COMPLETED SUCCESSFULLY"),
              backgroundColor: semantic.success),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("RESTORE FAILED: ${result.failureOrThrow.message}"),
              backgroundColor: semantic.overspent),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final AppColors semantic;
  final Color? color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.semantic,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: semantic.secondaryText,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color ?? semantic.text,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }
}
