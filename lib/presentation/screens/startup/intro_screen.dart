import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/screens/dashboard/dashboard.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/providers/user_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _finishIntro() async {
    await ref.read(notificationServiceProvider).requestPermissions();

    final prefs = ref.read(sharedPreferencesProvider);
    final name = _nameController.text.trim();
    if (name.length > 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.nameTooLong)),
        );
      }
      return;
    }

    if (name.isNotEmpty) {
      ref.read(userProvider.notifier).setName(name);
    }

    await prefs.setBool('intro_seen', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Dashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: 800.ms,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      body: Stack(
        children: [
          // Decorative background elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    semantic.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                    semantic.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            )
                .animate(
                    onPlay: (c) => !AppConfig.isTest
                        ? c.repeat(reverse: true)
                        : c.forward())
                .move(duration: 15.seconds, end: const Offset(-20, 20)),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // App Branding
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: semantic.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color:
                                      semantic.primary.withValues(alpha: 0.1),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 44,
                                color: semantic.primary,
                              ),
                            ).animate().fadeIn(duration: 800.ms).scale(
                                curve: Curves.easeOutBack, duration: 800.ms),
                            const SizedBox(height: 32),
                            Text(
                              l10n.introTrueLedger,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                color: semantic.text,
                                height: 1.1,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 12),
                            Text(
                              l10n.introTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: semantic.secondaryText,
                                letterSpacing: -0.2,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 64),

                            // Features List
                            _buildFeatureItem(
                              context,
                              CupertinoIcons.graph_circle_fill,
                              l10n.trackYourWealth,
                              l10n.trackYourWealthDesc,
                              semantic.income,
                              600,
                            ),
                            const SizedBox(height: 32),
                            _buildFeatureItem(
                              context,
                              Icons.pie_chart_rounded,
                              l10n.smartBudgeting,
                              l10n.smartBudgetingDesc,
                              semantic.primary,
                              800,
                            ),
                            const SizedBox(height: 32),
                            _buildFeatureItem(
                              context,
                              CupertinoIcons.lock_shield_fill,
                              l10n.secureAndPrivate,
                              l10n.secureAndPrivateDesc,
                              semantic.warning,
                              1000,
                            ),

                            const SizedBox(height: 64),
                            // Name Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.whatShouldWeCallYou.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: semantic.secondaryText,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: semantic.surfaceCombined,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                            alpha: isDark ? 0.3 : 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _nameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: TextStyle(
                                        color: semantic.text,
                                        fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: l10n.enterYourNameHint,
                                      hintStyle: TextStyle(
                                          color: semantic.secondaryText
                                              .withValues(alpha: 0.5)),
                                      filled: true,
                                      fillColor: semantic.surfaceCombined,
                                      prefixIcon: Icon(
                                          CupertinoIcons.person_fill,
                                          size: 20,
                                          color: semantic.primary),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: semantic.divider
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: semantic.divider
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: semantic.primary,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 1200.ms)
                                .slideY(begin: 0.1, end: 0),
                          ],
                        ),
                      ),
                    ),
                    // Sticky Bottom Button
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () {
                            Haptics.light();
                            _finishIntro();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: semantic.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            shadowColor:
                                semantic.primary.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            l10n.getStarted,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1400.ms)
                          .slideY(begin: 0.2, end: 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title,
      String description, Color iconColor, int delayMs) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: semantic.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: semantic.secondaryText,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delayMs.ms).slideX(begin: 0.05, end: 0);
  }
}
