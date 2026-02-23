import 'package:flutter/material.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/presentation/screens/subscriptions/add_subscription.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

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
    final semantic = Theme.of(context).extension<AppColors>()!;
    final total =
        subs.isEmpty ? 0.0 : subs.map((e) => e.amount).reduce((a, b) => a + b);

    return AppleScaffold(
      title: "Subscriptions",
      subtitle: "Monthly Recurring",
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      slivers: [
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AppleGlassCard(
                padding: EdgeInsets.zero,
                gradient: LinearGradient(
                  colors: [
                    semantic.primary,
                    semantic.primary.withValues(alpha: 0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MONTHLY BURN",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_long_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (subs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                  child: Text("No subscriptions tracked",
                      style: TextStyle(color: Colors.grey))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = subs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppleGlassCard(
                        padding: EdgeInsets.zero,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddSubscriptionScreen(
                                          subscription: s)));
                              load();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: semantic.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.subscriptions_rounded,
                                        color: semantic.primary, size: 24),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: semantic.text),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          DateHelper.formatDue(s.billingDate,
                                              prefix: "Next"),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: semantic.secondaryText,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(s.amount),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: semantic.text),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _delete(s.id),
                                        child: Text(
                                          "Remove",
                                          style: TextStyle(
                                              color: semantic.overspent
                                                  .withValues(alpha: 0.8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: subs.length,
                ),
              ),
            ),
        ],
      ],
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
