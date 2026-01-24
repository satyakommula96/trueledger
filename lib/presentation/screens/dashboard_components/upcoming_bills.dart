import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:truecash/core/theme/theme.dart';
import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/utils/date_helper.dart';

class UpcomingBills extends StatelessWidget {
  final List<Map<String, dynamic>> bills;
  final AppColors semantic;

  const UpcomingBills({
    super.key,
    required this.bills,
    required this.semantic,
  });

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const Text("Clean slate",
          style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: bills.asMap().entries.map((entry) {
          final index = entry.key;
          final b = entry.value;
          return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: semantic.divider)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['type'].toString(),
                            style: TextStyle(
                                fontSize: 8,
                                color: semantic.secondaryText,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(b['title'].toString().toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 12),
                        Text(CurrencyHelper.format(b['amount']),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15)),
                        Text(DateHelper.formatDue(b['due'].toString()),
                            style: TextStyle(
                                fontSize: 9, color: semantic.secondaryText))
                      ]))
              .animate()
              .fadeIn(delay: (100 * index).ms, duration: 600.ms)
              .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint);
        }).toList()));
  }
}
