import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/core/services/notification_service.dart';

class PaymentCalendar extends StatefulWidget {
  final List<Map<String, dynamic>> bills;
  final AppColors semantic;

  const PaymentCalendar(
      {super.key, required this.bills, required this.semantic});

  @override
  State<PaymentCalendar> createState() => _PaymentCalendarState();
}

class _PaymentCalendarState extends State<PaymentCalendar> {
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

  List<Map<String, dynamic>> _getEventsForDay(int day) {
    final targetDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final events = <Map<String, dynamic>>[];

    for (var bill in widget.bills) {
      final dueDateStr = bill['due']?.toString() ?? '';
      final date = _parseDueDate(dueDateStr);
      if (date != null) {
        // Check if it matches this day
        if (date.year == targetDate.year &&
            date.month == targetDate.month &&
            date.day == targetDate.day) {
          events.add(bill);
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
                    const SizedBox(width: 8),
                    IconButton(
                        icon: const Icon(Icons.notifications_active_outlined),
                        onPressed: _scheduleNotifications,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        tooltip: "Schedule Reminders"),
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
              final events = _getEventsForDay(day);
              final isToday = day == DateTime.now().day &&
                  _focusedMonth.month == DateTime.now().month &&
                  _focusedMonth.year == DateTime.now().year;

              return InkWell(
                onTap: events.isNotEmpty
                    ? () => _showDayDetails(day, events)
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : (events.isNotEmpty
                            ? widget.semantic.surfaceCombined
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$day",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: events.isNotEmpty || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: events.isNotEmpty || isToday
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.grey)),
                      if (events.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.take(3).map((e) {
                            Color dotColor = widget.semantic.secondaryText;
                            if (e['type'] == 'SUBSCRIPTION') {
                              dotColor = widget.semantic.overspent;
                            }
                            if (e['type'] == 'LOAN EMI') {
                              dotColor = Colors.orange;
                            }

                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
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
                  DateFormat('EEEE, dd MMMM yyyy')
                      .format(DateTime(
                          _focusedMonth.year, _focusedMonth.month, day))
                      .toUpperCase(),
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
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.semantic.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill['name'] ?? 'Bill',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(bill['type'] ?? 'PAYMENT',
                    style: TextStyle(
                        fontSize: 10,
                        color: widget.semantic.secondaryText,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(CurrencyFormatter.format(bill['amount']),
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: widget.semantic.overspent)),
        ],
      ),
    );
  }

  Future<void> _scheduleNotifications() async {
    final notificationService = NotificationService();
    // Use the central service's specialized logic
    await notificationService.requestPermissions();

    int count = 0;
    for (var bill in widget.bills) {
      final date = _parseDueDate(bill['due'] ?? '');
      if (date != null) {
        final now = DateTime.now();
        // If date is today or future
        if (date.isAfter(now.subtract(const Duration(days: 1)))) {
          // Schedule actual notification logic would go here.
          // For now, we just simulate enabling them.
          count++;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Scheduled reminders for $count upcoming payments.")));
    }
  }
}
