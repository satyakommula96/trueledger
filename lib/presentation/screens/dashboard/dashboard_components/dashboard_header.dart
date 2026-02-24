import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/theme/theme.dart';

import 'package:trueledger/presentation/screens/settings/settings.dart';
import 'package:trueledger/presentation/screens/settings/notifications_screen.dart';

import 'package:trueledger/l10n/app_localizations.dart';

class DashboardHeader extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onLoad;
  final int activeStreak;
  final bool hasLoggedToday;

  const DashboardHeader({
    super.key,
    required this.isDark,
    required this.onLoad,
    required this.activeStreak,
    required this.hasLoggedToday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final userName = ref.watch(userProvider);
    final isPrivacy = ref.watch(privacyProvider);
    final notificationCount = ref.watch(pendingNotificationCountProvider);
    final l10n = AppLocalizations.of(context)!;

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return l10n.goodMorning;
      if (hour < 17) return l10n.goodAfternoon;
      return l10n.goodEvening;
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: semantic.text,
                      letterSpacing: -1.0,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: semantic.secondaryText,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                ],
              ),
            ),
            Row(
              children: [
                _buildHeaderAction(
                  context,
                  icon: isPrivacy
                      ? CupertinoIcons.eye_slash_fill
                      : CupertinoIcons.eye_fill,
                  onTap: () => ref.read(privacyProvider.notifier).toggle(),
                  color: isPrivacy ? semantic.primary : semantic.secondaryText,
                  semantic: semantic,
                ),
                const SizedBox(width: 8),
                _buildHeaderAction(
                  context,
                  badgeCount: notificationCount,
                  icon: CupertinoIcons.bell,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  ),
                  semantic: semantic,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final shouldReload = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    if (shouldReload == true) onLoad();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: semantic.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: semantic.primary.withValues(alpha: 0.2),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: semantic.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate(delay: 200.ms).fadeIn(),
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
    int badgeCount = 0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: semantic.divider, width: 1.5),
            color: semantic.surfaceCombined.withValues(alpha: 0.3),
          ),
          child: badgeCount > 0
              ? Badge(
                  label: Text('$badgeCount'),
                  backgroundColor: semantic.overspent,
                  child: Icon(icon, size: 22, color: color ?? semantic.text),
                )
              : Icon(icon, size: 22, color: color ?? semantic.text),
        ),
      ),
    );
  }
}
