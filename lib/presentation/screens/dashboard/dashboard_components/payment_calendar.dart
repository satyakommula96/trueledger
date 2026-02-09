import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';

class PaymentCalendar extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> bills;
  final AppColors semantic;

  const PaymentCalendar(
      {super.key, required this.bills, required this.semantic});

  @override
  ConsumerState<PaymentCalendar> createState() => _PaymentCalendarState();
}

class _PaymentCalendarState extends ConsumerState<PaymentCalendar> {
  late DateTime _focusedMonth;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  List<Map<String, dynamic>> _getEventsForDay(
      int day, List<String> paidLabels) {
    final targetDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final events = <Map<String, dynamic>>[];

    for (var bill in widget.bills) {
      final dueDateStr = bill['due']?.toString() ?? '';

      if (bill['isRecurring'] == false) {
        final nextDue = DateHelper.getNextOccurrence(dueDateStr);
        if (nextDue != null) {
          if (nextDue.year != targetDate.year ||
              nextDue.month != targetDate.month ||
              nextDue.day != targetDate.day) {
            continue;
          }
        }
      }

      final date = _parseDueDate(dueDateStr);
      if (date != null) {
        if (date.year == targetDate.year &&
            date.month == targetDate.month &&
            date.day == targetDate.day) {
          final billCopy = Map<String, dynamic>.from(bill);
          final name = (billCopy['name'] ?? billCopy['title'] ?? '')
              .toString()
              .toLowerCase();

          if (billCopy['type'] == 'CREDIT DUE') {
            final isCurrentMonth = _focusedMonth.year == DateTime.now().year &&
                _focusedMonth.month == DateTime.now().month;
            if (!isCurrentMonth) {
              billCopy['isPaid'] = false;
            }
          } else if (name.isNotEmpty) {
            billCopy['isPaid'] = paidLabels.any((label) {
              final l = label.toLowerCase();
              return l.contains(name) || name.contains(l);
            });
          }
          events.add(billCopy);
        }
      }
    }
    return events;
  }

  DateTime? _parseDueDate(String due) {
    return DateHelper.parseDue(due, relativeTo: _focusedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstDayWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    final isTouch = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    final monthStr = DateFormat('yyyy-MM').format(_focusedMonth);
    final paidLabelsAsync = ref.watch(paidLabelsProvider(monthStr));
    final paidLabels = paidLabelsAsync.value ?? [];

    final mainContent = AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeOutQuint,
      // ignore: deprecated_member_use
      transform: Matrix4.identity()..scale(_isHovered ? 1.01 : 1.0),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _isHovered
                ? widget.semantic.secondaryText.withValues(alpha: 0.5)
                : widget.semantic.divider),
        boxShadow: [
          if (_isHovered)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: widget.semantic.secondaryText)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month - 1);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                              _focusedMonth.year, _focusedMonth.month + 1);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                )
              ],
            ),
          ),
          _buildSummaryBar(paidLabels),
          GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: daysInMonth + (firstDayWeekday - 1),
            itemBuilder: (context, index) {
              if (index < firstDayWeekday - 1) {
                return const SizedBox();
              }
              final day = index - (firstDayWeekday - 1) + 1;
              final events = _getEventsForDay(day, paidLabels);
              final isToday = day == DateTime.now().day &&
                  _focusedMonth.month == DateTime.now().month &&
                  _focusedMonth.year == DateTime.now().year;

              final allPaid =
                  events.isNotEmpty && events.every((e) => e['isPaid'] == true);

              return InkWell(
                onTap: events.isNotEmpty
                    ? () => _showDayDetails(day, events)
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: 400.ms,
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : (allPaid
                            ? Colors.green.withValues(alpha: 0.05)
                            : (events.isNotEmpty
                                ? widget.semantic.surfaceCombined
                                : Colors.transparent)),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary)
                        : (allPaid
                            ? Border.all(
                                color: Colors.green.withValues(alpha: 0.2))
                            : null),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$day",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: events.isNotEmpty || isToday
                                  ? FontWeight.w900
                                  : FontWeight.normal,
                              color: allPaid
                                  ? Colors.green
                                  : (events.isNotEmpty || isToday
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.grey))),
                      if (events.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        if (allPaid)
                          const Icon(Icons.check_rounded,
                              size: 10, color: Colors.green)
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.take(4).map((e) {
                              Color dotColor = widget.semantic.secondaryText;
                              if (e['isPaid'] == true) {
                                dotColor = widget.semantic.divider;
                              } else {
                                if (e['type'] == 'CREDIT DUE') {
                                  dotColor = Colors.red;
                                } else if (e['type'] == 'LOAN EMI') {
                                  dotColor = Colors.orange;
                                } else if (e['type'] == 'SUBSCRIPTION') {
                                  dotColor = widget.semantic.overspent;
                                }
                              }

                              return Container(
                                width: 3,
                                height: 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                    color: dotColor, shape: BoxShape.circle),
                              );
                            }).toList(),
                          )
                      ]
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (index % 7 * 50).ms, duration: 400.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack);
            },
          )
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);

    if (isTouch) {
      return mainContent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: mainContent,
    );
  }

  Widget _buildSummaryBar(List<String> paidLabels) {
    double totalDue = 0;
    double totalPaid = 0;

    final daysInMonth = _getDaysInMonth(_focusedMonth);
    for (int d = 1; d <= daysInMonth; d++) {
      final events = _getEventsForDay(d, paidLabels);
      for (var e in events) {
        totalDue += (e['amount'] as num).toDouble();
        if (e['isPaid'] == true) {
          totalPaid += (e['amount'] as num).toDouble();
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildSummaryItem("TOTAL DUE", totalDue, widget.semantic.overspent),
          Container(
            width: 1,
            height: 24,
            color: widget.semantic.divider,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _buildSummaryItem("PAID", totalPaid, Colors.green),
          const Spacer(),
          if (totalDue > 0)
            CircularProgressIndicator(
              value: totalPaid / totalDue,
              strokeWidth: 3,
              backgroundColor: widget.semantic.divider,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(CurrencyFormatter.format(amount, compact: true),
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  void _showDayDetails(int day, List<Map<String, dynamic>> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd-MM-yyyy').format(
                      DateTime(_focusedMonth.year, _focusedMonth.month, day)),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: widget.semantic.secondaryText),
                ),
                const SizedBox(height: 16),
                ...events.map((e) => _buildDetailItem(e)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(Map<String, dynamic> bill) {
    IconData icon = Icons.receipt_long;
    Color color = widget.semantic.secondaryText;

    if (bill['type'] == 'SUBSCRIPTION') {
      icon = Icons.subscriptions;
      color = widget.semantic.overspent;
    } else if (bill['type'] == 'LOAN EMI') {
      icon = Icons.account_balance;
      color = Colors.orange;
    } else if (bill['type'] == 'CREDIT DUE') {
      icon = Icons.credit_card;
      color = Colors.red;
    } else if (bill['type'] == 'BORROWING DUE') {
      icon = Icons.person;
      color = Colors.purple;
    }

    final isPaid = bill['isPaid'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.semantic.surfaceCombined
            .withValues(alpha: isPaid ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isPaid
                ? widget.semantic.divider.withValues(alpha: 0.2)
                : widget.semantic.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isPaid ? 0.05 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isPaid ? Icons.check_circle_rounded : icon,
                color: isPaid ? widget.semantic.secondaryText : color,
                size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill['name'] ?? bill['title'] ?? 'Bill',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid
                          ? widget.semantic.secondaryText
                          : Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bill['type'].toString().toUpperCase(),
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color:
                          widget.semantic.secondaryText.withValues(alpha: 0.6),
                      letterSpacing: 1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(bill['amount']),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    decoration: isPaid ? TextDecoration.lineThrough : null,
                    color: isPaid
                        ? widget.semantic.secondaryText
                        : widget.semantic.overspent),
              ),
              if (isPaid)
                Text(
                  "PAID",
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.green.shade700,
                      letterSpacing: 1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
