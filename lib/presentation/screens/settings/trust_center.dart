import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.watch(financialRepositoryProvider).getDatabaseStats();
});

class TrustCenterScreen extends ConsumerWidget {
  const TrustCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final statsAsync = ref.watch(databaseStatsProvider);
    final lastBackup =
        ref.watch(sharedPreferencesProvider).getString('last_backup_time') ??
            'Never';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Trust & Privacy",
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacyCard(context, semantic),
            const SizedBox(height: 32),
            Text(
              "DATA HEALTH",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: semantic.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                      label: "Total Records",
                      value: stats['total_records'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Expenses",
                      value: stats['variable'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Income",
                      value: stats['income'].toString(),
                      semantic: semantic),
                  _StatCard(
                      label: "Budgets",
                      value: stats['budgets'].toString(),
                      semantic: semantic),
                ],
              ),
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (e, s) => Text("Error loading stats: $e"),
            ),
            const SizedBox(height: 32),
            Text(
              "BACKUP CONFIDENCE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: semantic.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: semantic.surfaceCombined,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: semantic.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded, color: Colors.green),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Local Backup Status",
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Text("Last backup: $lastBackup",
                                style: TextStyle(
                                    color: semantic.secondaryText,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 14, color: semantic.secondaryText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Next automatic backup: At next application launch",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: semantic.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "TrueLedger uses SQLCipher AES-256 for database encryption on supported platforms.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: semantic.secondaryText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context, AppColors semantic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security_rounded, color: Colors.green),
              SizedBox(width: 12),
              Text(
                "Privacy First",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Your financial data is yours alone. It is stored locally on your device and never touches our servers. We have no way of seeing what you log.",
            style: TextStyle(
              fontSize: 14,
              color: semantic.text,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final AppColors semantic;

  const _StatCard(
      {required this.label, required this.value, required this.semantic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: semantic.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
