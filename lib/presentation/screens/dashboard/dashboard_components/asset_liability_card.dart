import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';

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
    final totalAssets =
        summary.netWorth + summary.creditCardDebt + summary.loansTotal;
    final totalLiabilities = summary.creditCardDebt + summary.loansTotal;

    return Row(
      children: [
        Expanded(
          child: HoverWrapper(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.assets)));
              onLoad();
            },
            borderRadius: 20,
            glowColor: semantic.income,
            glowOpacity: 0.15,
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
                  border: Border.all(
                      color: semantic.income.withValues(alpha: 0.2))),
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
                      CurrencyFormatter.format(totalAssets,
                          isPrivate: isPrivate),
                      semantic.income,
                      semantic),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HoverWrapper(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.liabilities)));
              onLoad();
            },
            borderRadius: 20,
            glowColor: semantic.overspent,
            glowOpacity: 0.15,
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
                      color: semantic.overspent.withValues(alpha: 0.2))),
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
                      CurrencyFormatter.format(totalLiabilities,
                          isPrivate: isPrivate),
                      semantic.overspent,
                      semantic),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0),
        ),
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
      Semantics(
        container: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(val,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
      ),
    ]);
  }
}
