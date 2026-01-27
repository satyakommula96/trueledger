import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/presentation/screens/settings/settings.dart';

class DashboardHeader extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onLoad; // To reload dashboard when returning from settings

  const DashboardHeader({
    super.key,
    required this.isDark,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;
    final userName = ref.watch(userProvider);
    final isPrivacy = ref.watch(privacyProvider);

    String getGreeting() {
      final hour = DateTime.now().hour;
      String greeting;
      if (hour < 12) {
        greeting = "Good Morning";
      } else if (hour < 17) {
        greeting = "Good Afternoon";
      } else {
        greeting = "Good Evening";
      }
      return "$greeting, $userName";
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: SvgPicture.asset(
                    'assets/icon/trueledger_icon.svg',
                    placeholderBuilder: (context) => Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getGreeting(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: semantic.secondaryText,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 2),
                    Text("TrueLedger",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5)),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
              ],
            ),
            Row(
              children: [
                _buildHeaderAction(
                  context,
                  icon: isPrivacy
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  onTap: () => ref.read(privacyProvider.notifier).toggle(),
                  color: isPrivacy
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                  semantic: semantic,
                ),
                const SizedBox(width: 12),
                _buildHeaderAction(
                  context,
                  icon: Icons.settings_rounded,
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                    onLoad();
                  },
                  semantic: semantic,
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required AppColors semantic,
    Color? color,
  }) {
    return Material(
      color: semantic.surfaceCombined.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: semantic.divider.withValues(alpha: 0.05)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
