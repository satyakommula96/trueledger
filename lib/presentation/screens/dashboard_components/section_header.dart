import 'package:flutter/material.dart';
import 'package:truecash/core/theme/theme.dart';

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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(sub,
                style: TextStyle(
                    fontSize: 11,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                size: 20, color: Colors.grey),
            onPressed: onAdd,
          ),
      ],
    );
  }
}
