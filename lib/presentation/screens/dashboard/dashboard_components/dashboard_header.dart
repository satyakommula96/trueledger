import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting().toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: semantic.secondaryText,
                          letterSpacing: 2,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          userName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          l10n.appTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          key: const ValueKey('dashboard_glowing_dot'),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: semantic.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: semantic.primary.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        )
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .scale(
                              duration: 1500.ms,
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.3, 1.3),
                              curve: Curves.easeInOut,
                            )
                            .blur(
                              duration: 1500.ms,
                              begin: const Offset(0, 0),
                              end: const Offset(8, 8),
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (activeStreak > 0)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: semantic.surfaceCombined,
                              title: Row(
                                children: [
                                  Icon(Icons.whatshot_rounded,
                                      color: Colors.orange, size: 24),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(l10n.dailyStreak,
                                        style: TextStyle(color: semantic.text)),
                                  ),
                                ],
                              ),
                              content: Text(
                                l10n.streakMessage(activeStreak),
                                style: TextStyle(color: semantic.secondaryText),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.gotIt,
                                      style:
                                          TextStyle(color: semantic.primary)),
                                ),
                              ],
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: hasLoggedToday
                                ? Colors.orange.withValues(alpha: 0.1)
                                : semantic.surfaceCombined,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: hasLoggedToday
                                    ? Colors.orange.withValues(alpha: 0.5)
                                    : semantic.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.whatshot_rounded,
                                  size: 14,
                                  color: hasLoggedToday
                                      ? Colors.orange
                                      : semantic.secondaryText),
                              const SizedBox(width: 4),
                              Text(
                                "$activeStreak",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: hasLoggedToday
                                      ? Colors.orange
                                      : semantic.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                  _buildHeaderAction(
                    context,
                    icon: isPrivacy
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    onTap: () => ref.read(privacyProvider.notifier).toggle(),
                    color:
                        isPrivacy ? semantic.primary : semantic.secondaryText,
                    semantic: semantic,
                  ),
                  _buildHeaderAction(
                    context,
                    badgeCount: notificationCount,
                    icon: Icons.notifications_none_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()),
                    ),
                    semantic: semantic,
                  ),
                  _buildHeaderAction(
                    context,
                    icon: Icons.sort_rounded,
                    onTap: () async {
                      final shouldReload = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                      if (shouldReload == true) onLoad();
                    },
                    semantic: semantic,
                  ),
                ],
              ),
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
