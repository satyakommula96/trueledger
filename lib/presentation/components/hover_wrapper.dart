import 'package:flutter/material.dart';

class HoverWrapper extends StatefulWidget {
  final Widget child;
  final double scale;
  final double translateY;
  final Duration duration;
  final bool useGlow;
  final double glowOpacity;
  final Color? glowColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const HoverWrapper({
    super.key,
    required this.child,
    this.scale = 1.02,
    this.translateY = -4.0,
    this.duration = const Duration(milliseconds: 300),
    this.useGlow = true,
    this.glowOpacity = 0.1,
    this.glowColor,
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  State<HoverWrapper> createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<HoverWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    if (isTouch) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutQuint,
          transform: Matrix4.identity()
            // ignore: deprecated_member_use
            ..scale(_isHovered ? widget.scale : 1.0)
            // ignore: deprecated_member_use
            ..translate(0.0, _isHovered ? widget.translateY : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered && widget.useGlow
                ? [
                    BoxShadow(
                      color: (widget.glowColor ??
                              Theme.of(context).colorScheme.primary)
                          .withValues(alpha: widget.glowOpacity),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    )
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
