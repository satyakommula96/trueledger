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
import 'package:trueledger/l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trustCenter),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 48 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFraming(context, semantic, l10n),
            const SizedBox(height: 32),
            _buildSectionHeader(l10n.ourGuarantees, semantic),
            const SizedBox(height: 16),
            _buildGuaranteesGrid(context, semantic, l10n),
            const SizedBox(height: 32),
            _buildSectionHeader(l10n.strictPolicies, semantic),
            const SizedBox(height: 16),
            _buildNeverList(semantic, l10n),
            const SizedBox(height: 32),
            _buildSectionHeader(l10n.dataHealth, semantic),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                children: [
                  _StatCard(
                      label: l10n.totalRecords,
                      value: stats['total_records'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: l10n.expenses.toUpperCase(),
                      value: stats['variable'].toString(),
                      semantic: semantic,
                      color: semantic.overspent),
                  _StatCard(
                      label: l10n.income.toUpperCase(),
                      value: stats['income'].toString(),
                      semantic: semantic,
                      color: semantic.income),
                  _StatCard(
                      label: l10n.budgets.toUpperCase(),
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
            _buildSectionHeader(l10n.backupConfidence, semantic),
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
                            Text(l10n.localBackupStatus,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: semantic.text)),
                            const SizedBox(height: 2),
                            Text(l10n.lastBackupLabel(lastBackup),
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
                          l10n.nextAutoBackup,
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
                  child: _buildSectionHeader(l10n.localBackups, semantic),
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
                    label: Text(l10n.viewFolder,
                        style: const TextStyle(
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
                            l10n.noLocalBackupsFound,
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
                  l10n.sqlCipherEncryption,
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

  Widget _buildFraming(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productLevelPrivacy,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: semantic.primary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.privacyPrinciple,
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

  Widget _buildGuaranteesGrid(
      BuildContext context, AppColors semantic, AppLocalizations l10n) {
    final guarantees = [
      (l10n.noAds, l10n.noAdsDesc, Icons.block_rounded),
      (l10n.noTracking, l10n.noTrackingDesc, Icons.visibility_off_rounded),
      (l10n.noProfiling, l10n.noProfilingDesc, Icons.psychology_alt_rounded),
      if (kIsWeb ||
          (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS))
        (l10n.localOnly, l10n.localOnlyDesc, Icons.devices_rounded)
      else
        (
          l10n.desktopIsolation,
          l10n.desktopIsolationDesc,
          Icons.computer_rounded
        ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final itemWidth =
          isNarrow ? constraints.maxWidth : (constraints.maxWidth - 16) / 2;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final g in guarantees)
            SizedBox(
              width: itemWidth,
              child: _buildGuaranteeCard(g, semantic),
            ),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
    });
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

  Widget _buildNeverList(AppColors semantic, AppLocalizations l10n) {
    final nevers = [
      l10n.noAnalyticsSdk,
      l10n.noBehaviorProfiling,
      l10n.noBankScraping,
      l10n.noCloudSync,
      l10n.noSellingLogs,
      l10n.noExternalAi,
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
    final l10n = AppLocalizations.of(context)!;
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
                () => _confirmRestore(context, ref, file, l10n), semantic),
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

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref,
      BackupFile file, AppLocalizations l10n) async {
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
          title: Text(l10n.restoreDataTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: semantic.overspent)),
          content: Text(
            l10n.restoreDataWarning,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel,
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
              child: Text(l10n.restoreNow,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
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
              content: Text(l10n.restoreCompleted),
              backgroundColor: semantic.success),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.restoreFailed(result.failureOrThrow.message)),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color ?? semantic.text,
                    letterSpacing: -0.5)),
          ),
        ],
      ),
    );
  }
}
