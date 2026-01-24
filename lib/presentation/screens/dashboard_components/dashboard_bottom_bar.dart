import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:truecash/core/theme/theme.dart';
import '../loans.dart';
import '../credit_cards.dart';
import '../add_expense.dart';
import '../monthly_history.dart';
import '../analysis_screen.dart';

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
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                            Icons.handshake_outlined,
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
                      const SizedBox(width: 60),
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
                                    builder: (_) =>
                                        const MonthlyHistoryScreen())),
                            semantic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddExpense()));
                  onLoad();
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary]),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
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
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: semantic.secondaryText,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
