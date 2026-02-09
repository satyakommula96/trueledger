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

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsProvider);
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;

    return investmentsAsync.when(
      loading: () => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: Center(child: CircularProgressIndicator(color: semantic.primary)),
      ),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (data) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("PORTFOLIO"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddInvestmentDialog(context, ref),
            backgroundColor: semantic.primary,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 80, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPortfolioHero(data.totalValue, semantic, isPrivate)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 48),
                if (data.distribution.isNotEmpty) ...[
                  _buildSectionHeader(semantic, "ALLOCATION", "ASSET CLASSES"),
                  const SizedBox(height: 24),
                  _buildAllocationWidget(
                      data.distribution, data.totalValue, semantic),
                  const SizedBox(height: 48),
                ],
                _buildSectionHeader(semantic, "MY ASSETS", "FULL LIST"),
                const SizedBox(height: 24),
                if (data.investments.isEmpty)
                  _buildEmptyState(semantic)
                else
                  ...data.investments.map(
                      (inv) => _buildInvestmentCard(inv, semantic, isPrivate)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(AppColors semantic, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sub.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              color: semantic.secondaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildPortfolioHero(double total, AppColors semantic, bool isPrivate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "NET PORTFOLIO VALUE",
                style: TextStyle(
                  color: semantic.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.auto_graph_rounded, color: semantic.success, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(total, isPrivate: isPrivate),
            style: TextStyle(
              color: semantic.text,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleInsightTag(
                  semantic, Icons.trending_up_rounded, "Growth +12.4%"),
              const SizedBox(width: 12),
              _buildSimpleInsightTag(
                  semantic, Icons.verified_user_rounded, "Diversified"),
            ],
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
        color: semantic.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: semantic.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: semantic.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Re-implementing allocation breakdown with context for sizing
  Widget _buildAllocationWidget(
      Map<String, double> distribution, double total, AppColors semantic) {
    return LayoutBuilder(builder: (context, constraints) {
      final sortedTypes = distribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return Column(
        children: sortedTypes.map((entry) {
          final percentage = total == 0 ? 0.0 : entry.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: semantic.text,
                      ),
                    ),
                    Text(
                      "${(percentage * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: semantic.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: semantic.divider.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedContainer(
                      duration: 1.seconds,
                      curve: Curves.easeOutQuint,
                      height: 10,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            semantic.primary,
                            semantic.primary.withValues(alpha: 0.7)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ).animate().shimmer(
                        duration: 2.seconds,
                        color: Colors.white.withValues(alpha: 0.1)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildInvestmentCard(dynamic inv, AppColors semantic, bool isPrivate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantic.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                  ),
                ),
                Text(
                  inv.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(inv.amount, isPrivate: isPrivate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: semantic.text,
            ),
          ),
        ],
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

  Widget _buildEmptyState(AppColors semantic) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.layers_clear_rounded, size: 64, color: semantic.divider),
          const SizedBox(height: 24),
          Text(
            "NO ASSETS TRACKED",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: semantic.secondaryText,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first investment to see analysis.",
            style: TextStyle(
              fontSize: 14,
              color: semantic.secondaryText,
              fontWeight: FontWeight.w600,
            ),
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              Theme.of(context).extension<AppColors>()!.surfaceCombined,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("ADD INVESTMENT",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Asset Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Current Value"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: "Type"),
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
                child: const Text("CANCEL")),
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
                      DateTime.now().toIso8601String(),
                    );
                ref.invalidate(investmentsProvider);
                ref.invalidate(dashboardProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("SAVE"),
            ),
          ],
        ),
      ),
    );
  }
}
