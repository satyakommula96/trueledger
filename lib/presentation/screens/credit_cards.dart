import 'package:flutter/material.dart';

import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/theme/theme.dart';
import 'add_card.dart';
import 'edit_card.dart';
import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/utils/date_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class CreditCardsScreen extends ConsumerStatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  ConsumerState<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends ConsumerState<CreditCardsScreen> {
  List<CreditCard> cards = [];
  bool _isLoading = true;

  Future<void> load() async {
    final repo = ref.read(financialRepositoryProvider);
    final data = await repo.getCreditCards();
    if (mounted) {
      setState(() {
        cards = data;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void _showPayDialog(CreditCard card) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Record Payment - ${card.bank}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Current Balance: ${CurrencyHelper.format(card.statementBalance.toInt())}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Amount",
                border: const OutlineInputBorder(),
                prefixText: CurrencyHelper.symbol,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (card.minDue > 0)
                  TextButton(
                    onPressed: () => controller.text = card.minDue.toString(),
                    child:
                        Text("Min Due (${CurrencyHelper.format(card.minDue)})"),
                  ),
                TextButton(
                  onPressed: () =>
                      controller.text = card.statementBalance.toString(),
                  child: const Text("Full Balance"),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              final amount = int.tryParse(controller.text);
              if (amount == null || amount <= 0) return;

              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await ref
                  .read(financialRepositoryProvider)
                  .payCreditCardBill(card.id, amount);
              load();
            },
            child: const Text("RECORD"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("CARDS & LIMITS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddCreditCardScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty
              ? Center(
                  child: Text("NO CARDS REGISTERED.",
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)))
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      24, 24, 24, 100 + MediaQuery.of(context).padding.bottom),
                  itemCount: cards.length,
                  itemBuilder: (_, i) {
                    final c = cards[i];
                    final limit = c.creditLimit.toDouble();
                    final stmt = c.statementBalance.toDouble();
                    final minDue = c.minDue.toDouble();
                    final util = limit == 0 ? 0.0 : (stmt / limit) * 100;
                    final isHighUtil = util > 30;

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditCreditCardScreen(card: c)));
                        load();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: semantic.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.credit_card_rounded,
                                        size: 16,
                                        color: semantic.secondaryText),
                                    const SizedBox(width: 8),
                                    Text(c.bank.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2,
                                            color: semantic.secondaryText)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (isHighUtil)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Icon(Icons.warning_amber_rounded,
                                            color: semantic.warning, size: 18),
                                      ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (c.generationDate.isNotEmpty)
                                          Text(
                                              "BILL DATE: ${c.generationDate.split(' ')[0]} ${c.generationDate.split(' ')[1]}"
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      semantic.secondaryText)),
                                        Text(DateHelper.formatDue(c.dueDate),
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: semantic.secondaryText)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(CurrencyHelper.format(stmt.toInt()),
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: colorScheme.onSurface,
                                            letterSpacing: -1)),
                                    Text("Statement balance",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: semantic.secondaryText,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyHelper.format(minDue.toInt()),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isHighUtil
                                                ? semantic.warning
                                                : colorScheme.onSurface)),
                                    Text("Min. due",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: semantic.secondaryText,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: util / 100,
                                backgroundColor: semantic.divider,
                                color: isHighUtil
                                    ? semantic.warning
                                    : colorScheme.primary,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "LIMIT: ${CurrencyHelper.format(limit.toInt())}",
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: semantic.secondaryText,
                                        letterSpacing: 0.5)),
                                Text("${util.toStringAsFixed(1)}% UTILIZED",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: isHighUtil
                                            ? semantic.warning
                                            : semantic.secondaryText)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showPayDialog(c),
                                icon: const Icon(Icons.payment, size: 16),
                                label: const Text("RECORD PAYMENT"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  side: BorderSide(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
