import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trueledger/core/config/app_config.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'dart:ui';

class Haptics {
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }
}

class AppleScaffold extends StatelessWidget {
  final Widget? body;
  final String? title;
  final String? subtitle;
  final List<Widget>? slivers;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final List<Widget>? appBarActions;
  final Widget? bottomNavigationBar;
  final Future<void> Function()? onRefresh;

  const AppleScaffold({
    super.key,
    this.body,
    this.title,
    this.subtitle,
    this.slivers,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = true,
    this.appBarActions,
    this.bottomNavigationBar,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Decorative background elements (Excluded from semantics for stability)
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
                    semantic.primary.withValues(alpha: 0.05),
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
          Positioned(
            bottom: 100,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.03),
                    colorScheme.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            )
                .animate(
                    onPlay: (c) => !AppConfig.isTest
                        ? c.repeat(reverse: true)
                        : c.forward())
                .move(duration: 18.seconds, end: const Offset(30, -20)),
          ),

          // Main Content
          Positioned.fill(
            child: Column(
              children: [
                if (title != null && slivers == null)
                  SafeArea(
                    bottom: false,
                    child: AppBar(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtitle != null)
                            Text(subtitle!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: semantic.secondaryText)),
                          Text(title!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      actions: appBarActions,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: semantic.text,
                    ),
                  ),
                Expanded(
                  child: _buildBody(semantic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppColors semantic) {
    Widget content = body ??
        (slivers != null
            ? CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (title != null)
                    SliverAppBar(
                      expandedHeight: 140,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor:
                          semantic.surfaceCombined.withValues(alpha: 0.8),
                      centerTitle: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(title!,
                            style: TextStyle(
                              color: semantic.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            )),
                        centerTitle: true,
                        titlePadding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        expandedTitleScale: 1.5,
                      ),
                      actions: appBarActions,
                    ),
                  ...slivers!,
                ],
              )
            : const SizedBox.shrink());

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: semantic.primary,
        backgroundColor: semantic.surfaceCombined,
        child: content,
      );
    }
    return content;
  }
}

class AppleGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final double blur;
  final double borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const AppleGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.color,
    this.gradient,
    this.blur = 20,
    this.borderRadius = 32,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              Haptics.light();
              onTap!();
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            margin: margin,
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null
                  ? (color ??
                      (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.7)))
                  : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
              border: border ??
                  Border.all(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: isDark ? 0.3 : 0.25),
                    width: 1.0,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppleSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const AppleSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: semantic.secondaryText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: semantic.text,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            GestureDetector(
              onTap: () {
                Haptics.light();
                onAction!();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: semantic.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  actionIcon ?? CupertinoIcons.chevron_right,
                  size: 16,
                  color: semantic.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
