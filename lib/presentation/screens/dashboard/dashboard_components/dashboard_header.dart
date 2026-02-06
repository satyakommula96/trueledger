import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/config/app_config.dart';

import 'package:trueledger/presentation/screens/settings/settings.dart';
import 'package:trueledger/presentation/screens/settings/notifications_screen.dart';

class DashboardHeader extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onLoad;

  const DashboardHeader({
    super.key,
    required this.isDark,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final userName = ref.watch(userProvider);
    final isPrivacy = ref.watch(privacyProvider);
    final notificationCount = ref.watch(pendingNotificationCountProvider);

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return "Good Morning";
      if (hour < 17) return "Good Afternoon";
      return "Good Evening";
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
                      Text(
                        userName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: semantic.text,
                          letterSpacing: 0.5,
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
                          "TrueLedger",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: semantic.text,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: semantic.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(onPlay: (controller) {
                              if (!AppConfig.isTest) {
                                controller.repeat(reverse: true);
                              }
                            })
                            .scale(
                                duration: 1.seconds,
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.2, 1.2))
                            .blur(
                                duration: 1.seconds,
                                begin: const Offset(0, 0),
                                end: const Offset(4, 4)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),
            Row(
              children: [
                _buildHeaderAction(
                  context,
                  icon: isPrivacy
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  onTap: () => ref.read(privacyProvider.notifier).toggle(),
                  color: isPrivacy ? semantic.primary : semantic.secondaryText,
                  semantic: semantic,
                ),
                const SizedBox(width: 12),
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
                const SizedBox(width: 12),
                _buildHeaderAction(
                  context,
                  icon: Icons.sort_rounded,
                  onTap: () async {
                    final shouldReload = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    if (shouldReload == true) onLoad();
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
