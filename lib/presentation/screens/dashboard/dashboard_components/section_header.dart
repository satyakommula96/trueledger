import 'package:flutter/material.dart';
import 'package:trueledger/core/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String sub;
  final AppColors semantic;
  final VoidCallback? onAdd;

  const SectionHeader({
    super.key,
    required this.title,
    required this.sub,
    required this.semantic,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub.toUpperCase(),
                style: TextStyle(
                    fontSize: 9,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                )),
          ],
        ),
        if (onAdd != null)
          Material(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.add_rounded,
                    size: 20, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }
}
