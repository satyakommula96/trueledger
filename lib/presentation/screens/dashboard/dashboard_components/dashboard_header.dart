import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/privacy_provider.dart';
import 'package:truecash/core/theme/theme.dart';

import 'package:truecash/presentation/screens/settings/settings.dart';

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

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TrueCash",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    Text("Your Financial Outlook",
                        style: TextStyle(
                            fontSize: 12,
                            color: semantic.secondaryText,
                            fontWeight: FontWeight.w500)),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0),
              ],
            ),
            Row(
              children: [
                // Privacy Toggle
                IconButton(
                  icon: Icon(
                    ref.watch(privacyProvider)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () {
                    ref.read(privacyProvider.notifier).toggle();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings_outlined,
                      size: 22, color: colorScheme.onSurface),
                  onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                    onLoad();
                  },
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
