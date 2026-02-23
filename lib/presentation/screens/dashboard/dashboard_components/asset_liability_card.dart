import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/screens/net_worth/net_worth_details.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

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
        (summary.netWorth + summary.creditCardDebt + summary.loansTotal)
            .toDouble();
    final totalLiabilities =
        (summary.creditCardDebt + summary.loansTotal).toDouble();

    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            title: "ASSETS",
            value: totalAssets,
            color: semantic.income,
            icon: CupertinoIcons.house_fill,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.assets)));
              onLoad();
            },
            isPrivate: isPrivate,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(
            context,
            title: "LIABILITIES",
            value: totalLiabilities,
            color: semantic.overspent,
            icon: CupertinoIcons.doc_text_fill,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NetWorthDetailsScreen(
                          viewMode: NetWorthView.liabilities)));
              onLoad();
            },
            isPrivate: isPrivate,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrivate,
  }) {
    return AppleGlassCard(
      onTap: onTap,
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: semantic.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(value, isPrivate: isPrivate),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
