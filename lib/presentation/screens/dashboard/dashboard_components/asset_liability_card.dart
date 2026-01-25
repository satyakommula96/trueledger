import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/privacy_provider.dart';
import 'package:truecash/presentation/screens/net_worth/net_worth_details.dart';

class AssetLiabilityCard extends ConsumerWidget {
  final MonthlySummary summary;
  final AppColors semantic;
  final VoidCallback onLoad;

  const AssetLiabilityCard({
    super.key,
    required this.summary,
    required this.semantic,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyProvider);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.assets)));
              onLoad();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      semantic.income.withValues(alpha: 0.15),
                      semantic.income.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: semantic.income.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: semantic.income.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]),
              child: Stack(
                children: [
                  Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(Icons.account_balance_rounded,
                          size: 48,
                          color: semantic.income.withValues(alpha: 0.1))),
                  _buildMiniStat(
                      "ASSETS",
                      CurrencyFormatter.format(
                          summary.netWorth +
                              summary.creditCardDebt +
                              summary.loansTotal,
                          isPrivate: isPrivate),
                      semantic.income,
                      semantic),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.liabilities)));
              onLoad();
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      semantic.overspent.withValues(alpha: 0.15),
                      semantic.overspent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: semantic.overspent.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: semantic.overspent.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]),
              child: Stack(
                children: [
                  Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(Icons.receipt_long_rounded,
                          size: 48,
                          color: semantic.overspent.withValues(alpha: 0.1))),
                  _buildMiniStat(
                      "LIABILITIES",
                      CurrencyFormatter.format(
                          summary.creditCardDebt + summary.loansTotal,
                          isPrivate: isPrivate),
                      semantic.overspent,
                      semantic),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildMiniStat(
      String label, String val, Color color, AppColors semantic) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text(val,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    ]);
  }
}
