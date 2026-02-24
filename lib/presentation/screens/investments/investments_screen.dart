import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/investments_provider.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsProvider);
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return investmentsAsync.when(
      loading: () => AppleScaffold(
        title: l10n.portfolio,
        body: Center(child: CircularProgressIndicator(color: semantic.primary)),
      ),
      error: (err, stack) => AppleScaffold(
          title: l10n.portfolio, body: Center(child: Text("Error: $err"))),
      data: (data) {
        return AppleScaffold(
          title: l10n.portfolio,
          subtitle: "Assets & Allocation",
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddInvestmentDialog(context, ref),
            backgroundColor: semantic.primary,
            elevation: 4,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPortfolioHero(
                          data.totalValue, semantic, isPrivate, context)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                  const SizedBox(height: 48),
                  if (data.distribution.isNotEmpty) ...[
                    AppleSectionHeader(
                      title: l10n.allocation,
                      subtitle: l10n.assetClasses,
                    ),
                    const SizedBox(height: 20),
                    _buildAllocationWidget(
                        data.distribution, data.totalValue, semantic),
                    const SizedBox(height: 48),
                  ],
                  AppleSectionHeader(
                    title: l10n.myAssets,
                    subtitle: l10n.fullList,
                  ),
                  const SizedBox(height: 20),
                  if (data.investments.isEmpty)
                    _buildEmptyState(semantic, context)
                  else
                    ...data.investments.map((inv) =>
                        _buildInvestmentCard(inv, semantic, isPrivate)),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPortfolioHero(
      double total, AppColors semantic, bool isPrivate, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppleGlassCard(
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          semantic.success.withValues(alpha: 0.2),
          semantic.primary.withValues(alpha: 0.1),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_graph_rounded,
              size: 120,
              color: semantic.success.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.netPortfolioValue.toUpperCase(),
                  style: TextStyle(
                    color: semantic.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(total, isPrivate: isPrivate),
                    style: TextStyle(
                      color: semantic.text,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSimpleInsightTag(
                        semantic, Icons.trending_up_rounded, "Growth +12.4%"),
                    _buildSimpleInsightTag(
                        semantic, Icons.verified_user_rounded, "Diversified"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInsightTag(
      AppColors semantic, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: semantic.success),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: semantic.text.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationWidget(
      Map<String, double> distribution, double total, AppColors semantic) {
    return LayoutBuilder(builder: (context, constraints) {
      final sortedTypes = distribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Column(
        children: sortedTypes.map((entry) {
          final percentage = total == 0 ? 0.0 : entry.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppleGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: semantic.text),
                      ),
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: semantic.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: semantic.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: 1.seconds,
                        curve: Curves.easeOutQuint,
                        height: 6,
                        width: (constraints.maxWidth - 64) * percentage,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              semantic.primary,
                              semantic.primary.withValues(alpha: 0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildInvestmentCard(dynamic inv, AppColors semantic, bool isPrivate) {
    return AppleGlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: semantic.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForType(inv.type),
                      color: semantic.success, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: semantic.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inv.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: semantic.secondaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(inv.amount, isPrivate: isPrivate),
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: semantic.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    type = type.toLowerCase();
    if (type.contains('stock') || type.contains('equity')) {
      return Icons.show_chart_rounded;
    }
    if (type.contains('fund') || type.contains('mutual')) {
      return Icons.pie_chart_rounded;
    }
    if (type.contains('fixed') || type.contains('fd')) {
      return Icons.lock_clock_rounded;
    }
    if (type.contains('gold')) return Icons.brightness_high_rounded;
    if (type.contains('real')) return Icons.home_work_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  Widget _buildEmptyState(AppColors semantic, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.layers_clear_rounded,
              size: 64, color: semantic.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            l10n.noAssetsTracked,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: semantic.text),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstInvestment,
            style: TextStyle(
                fontSize: 14,
                color: semantic.secondaryText,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddInvestmentDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'Stock';
    final types = [
      'Stock',
      'Mutual Fund',
      'Fixed Deposit',
      'Gold',
      'Real Estate',
      'Other'
    ];
    final semantic = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.95),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: semantic.divider)),
            title: const Text("Add Investment",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: "Asset Name", hintText: "e.g. Apple Stock"),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Current Value", hintText: "0.00"),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration:
                        const InputDecoration(labelText: "Asset Category"),
                    items: types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(color: semantic.secondaryText))),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      amountController.text.isEmpty) {
                    return;
                  }
                  final amount = double.tryParse(amountController.text) ?? 0;
                  await ref.read(financialRepositoryProvider).addInvestment(
                        nameController.text,
                        amount,
                        selectedType,
                        DateTime.now(),
                      );
                  ref.invalidate(investmentsProvider);
                  ref.invalidate(dashboardProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: semantic.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("Save Asset"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
