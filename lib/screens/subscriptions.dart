import 'package:flutter/material.dart';
import '../logic/financial_repository.dart';
import '../models/models.dart';
import 'add_subscription.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> subs = [];
  bool _isLoading = true;

  Future<void> load() async {
    final repo = FinancialRepository();
    final data = await repo.getSubscriptions();
    if (mounted) setState(() { subs = data; _isLoading = false; });
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = subs.isEmpty ? 0 : subs.map((e) => e.amount).reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text("SUBSCRIPTIONS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.onSurface,
        foregroundColor: colorScheme.surface,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()));
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
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.06)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("MONTHLY BURN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Colors.grey)),
                Text("₹$total", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
              ],
            ),
          ),
          Expanded(
            child: subs.isEmpty
                ? const Center(child: Text("Empty stream", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: subs.length,
                    itemBuilder: (context, i) {
                      final s = subs[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.onSurface.withOpacity(0.06)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.subscriptions_rounded, color: colorScheme.onSecondaryContainer, size: 20),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                                  Text("Billed on: ${s.billingDate}", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Text("₹${s.amount}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () => _delete(s.id),
                              icon: Icon(Icons.remove_circle_outline, color: colorScheme.onSurface.withOpacity(0.3), size: 18),
                            )
                          ],
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
        content: const Text("This subscription will no longer be tracked in your monthly burn."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("KEEP")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("REMOVE", style: TextStyle(color: Colors.grey))),
        ],
      )
    );
    if (confirmed == true) {
      final repo = FinancialRepository();
      await repo.deleteItem('subscriptions', id);
      load();
    }
  }
}
