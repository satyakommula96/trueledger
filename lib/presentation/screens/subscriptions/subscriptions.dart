import 'package:flutter/material.dart';

import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/utils/currency_formatter.dart';
import 'package:truecash/core/utils/date_helper.dart';
import 'package:truecash/presentation/screens/subscriptions/add_subscription.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/presentation/providers/repository_providers.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  List<Subscription> subs = [];
  bool _isLoading = true;

  Future<void> load() async {
    final repo = ref.read(financialRepositoryProvider);
    final data = await repo.getSubscriptions();
    if (mounted) {
      setState(() {
        subs = data;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total =
        subs.isEmpty ? 0 : subs.map((e) => e.amount).reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text("SUBSCRIPTIONS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.surface,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("MONTHLY BURN",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 2,
                              color: Colors.grey)),
                      Text(CurrencyFormatter.format(total),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 24)),
                    ],
                  ),
                ),
                Expanded(
                  child: subs.isEmpty
                      ? const Center(
                          child: Text("Empty stream",
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(24, 0, 24,
                              100 + MediaQuery.of(context).padding.bottom),
                          itemCount: subs.length,
                          itemBuilder: (context, i) {
                            final s = subs[i];
                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AddSubscriptionScreen(
                                            subscription: s)));
                                load();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.06)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.subscriptions_rounded,
                                          color:
                                              colorScheme.onSecondaryContainer,
                                          size: 20),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(s.name.toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  letterSpacing: 1)),
                                          Text(
                                              DateHelper.formatDue(
                                                  s.billingDate,
                                                  prefix: "NEXT"),
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Text(CurrencyFormatter.format(s.amount),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15)),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _delete(s.id),
                                      icon: Icon(Icons.delete_outline,
                                          color: colorScheme.error
                                              .withValues(alpha: 0.5),
                                          size: 20),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("REMOVE TRACKER?"),
              content: const Text(
                  "This subscription will no longer be tracked in your monthly burn."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("KEEP")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("REMOVE",
                        style: TextStyle(color: Colors.grey))),
              ],
            ));
    if (confirmed == true) {
      final repo = ref.read(financialRepositoryProvider);
      await repo.deleteItem('subscriptions', id);
      load();
    }
  }
}
