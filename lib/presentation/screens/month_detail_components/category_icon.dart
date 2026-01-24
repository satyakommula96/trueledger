import 'package:flutter/material.dart';
import 'package:truecash/core/theme/theme.dart';

class CategoryIcon extends StatelessWidget {
  final String type;
  final String label;
  final AppColors semantic;

  const CategoryIcon(
      {super.key,
      required this.type,
      required this.label,
      required this.semantic});

  IconData _getIcon() {
    if (type == 'Income') {
      return Icons.arrow_downward;
    }
    if (type == 'Investment') {
      return Icons.trending_up;
    }

    final l = label.toLowerCase();
    if (l.contains('food') ||
        l.contains('grocer') ||
        l.contains('restaurant')) {
      return Icons.restaurant;
    }
    if (l.contains('travel') ||
        l.contains('transport') ||
        l.contains('fuel') ||
        l.contains('gas')) {
      return Icons.directions_car;
    }
    if (l.contains('shop') || l.contains('clothes')) {
      return Icons.shopping_bag;
    }
    if (l.contains('bill') || l.contains('utilit')) {
      return Icons.receipt_long;
    }
    if (l.contains('entert') || l.contains('movie')) {
      return Icons.movie;
    }
    if (l.contains('health') || l.contains('doctor') || l.contains('medic')) {
      return Icons.medical_services;
    }
    if (l.contains('educ') || l.contains('school') || l.contains('fee')) {
      return Icons.school;
    }
    if (l.contains('rent') || l.contains('home')) {
      return Icons.home;
    }
    if (l.contains('salary') || l.contains('wage')) {
      return Icons.work;
    }

    if (l.contains('investment') ||
        l.contains('stock') ||
        l.contains('sip') ||
        l.contains('mutual')) {
      return Icons.trending_up;
    }
    return type == 'Fixed' ? Icons.calendar_today : Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getIconColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_getIcon(), size: 20, color: _getIconColor()),
    );
  }

  Color _getIconColor() {
    if (type == 'Income') return semantic.income;
    if (type == 'Investment') return semantic.warning;
    return semantic.secondaryText;
  }
}
