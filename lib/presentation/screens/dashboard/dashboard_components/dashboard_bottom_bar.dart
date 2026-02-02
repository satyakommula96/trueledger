import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/credit_cards.dart';
import 'package:trueledger/presentation/screens/transactions/monthly_history.dart';
import 'package:trueledger/presentation/screens/analysis/analysis_screen.dart';
import 'package:trueledger/presentation/screens/loans/loans.dart';

class DashboardBottomBar extends StatelessWidget {
  final VoidCallback onLoad;

  const DashboardBottomBar({
    super.key,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 0, 24, 32 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionIcon(
                        context,
                        Icons.account_balance_rounded,
                        "LOANS",
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoansScreen())),
                        semantic),
                  ),
                  Expanded(
                    child: _buildActionIcon(
                        context,
                        Icons.credit_card_outlined,
                        "CARDS",
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreditCardsScreen())),
                        semantic),
                  ),
                  Expanded(
                    child: _buildActionIcon(
                        context,
                        Icons.analytics_outlined,
                        "ANALYSIS",
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AnalysisScreen())),
                        semantic),
                  ),
                  Expanded(
                    child: _buildActionIcon(
                        context,
                        Icons.history_outlined,
                        "HISTORY",
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MonthlyHistoryScreen())),
                        semantic),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label,
      VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: semantic.secondaryText),
          const SizedBox(height: 4),
          Flexible(
            child: Semantics(
              container: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: semantic.secondaryText,
                        letterSpacing: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
