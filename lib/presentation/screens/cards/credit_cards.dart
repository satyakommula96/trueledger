import 'package:flutter/material.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/presentation/screens/cards/edit_card.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/core/theme/color_helper.dart';

class CreditCardsScreen extends ConsumerStatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  ConsumerState<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends ConsumerState<CreditCardsScreen> {
  List<CreditCard> cards = [];
  bool _isLoading = true;

  Future<void> load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data = await repo.getCreditCards();
      if (mounted) {
        setState(() {
          cards = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading credit cards: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load cards: $e")),
        );
      }
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
                "Current Balance: ${CurrencyFormatter.format(card.statementBalance.toInt())}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Amount",
                border: const OutlineInputBorder(),
                prefixText: CurrencyFormatter.symbol,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (card.minDue > 0)
                  TextButton(
                    onPressed: () => controller.text = card.minDue.toString(),
                    child: Text(
                        "Min Due (${CurrencyFormatter.format(card.minDue)})"),
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
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                      24, 24, 24, 100 + MediaQuery.of(context).padding.bottom),
                  children: [
                    _buildTotalSummaryCard(semantic),
                    const SizedBox(height: 24),
                    ...cards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      final limit = c.creditLimit.toDouble();
                      final stmt = c.statementBalance.toDouble();
                      final util = limit == 0 ? 0.0 : (stmt / limit) * 100;

                      final isHighUtil = util > 30;
                      final isOverUtil = util > 80;
                      final cardColor = ColorHelper.getColorForName(c.bank);

                      final barColor = isOverUtil
                          ? semantic.overspent
                          : isHighUtil
                              ? semantic.warning
                              : cardColor;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: HoverWrapper(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditCreditCardScreen(card: c)));
                            load();
                          },
                          borderRadius: 24,
                          glowColor: barColor.withValues(alpha: 0.5),
                          glowOpacity: 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color:
                                      semantic.divider.withValues(alpha: 0.5)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.surface,
                                  semantic.surfaceCombined
                                      .withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: barColor.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.credit_card_rounded,
                                        size: 20,
                                        color: barColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.bank.toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5)),
                                          const SizedBox(height: 2),
                                          Text("CREDIT CARD",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: semantic.secondaryText,
                                                  letterSpacing: 1)),
                                        ],
                                      ),
                                    ),
                                    if (isHighUtil)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isOverUtil
                                                  ? semantic.overspent
                                                  : semantic.warning)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                                isOverUtil
                                                    ? Icons
                                                        .error_outline_rounded
                                                    : Icons
                                                        .warning_amber_rounded,
                                                size: 12,
                                                color: isOverUtil
                                                    ? semantic.overspent
                                                    : semantic.warning),
                                            const SizedBox(width: 4),
                                            Text(
                                                isOverUtil
                                                    ? "OVER LIMIT"
                                                    : "HIGH UTIL",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                    color: isOverUtil
                                                        ? semantic.overspent
                                                        : semantic.warning)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("CURRENT BALANCE",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: semantic.secondaryText,
                                                  letterSpacing: 1)),
                                          const SizedBox(height: 4),
                                          Text(
                                              CurrencyFormatter.format(
                                                  stmt.toInt()),
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -1)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text("DUE IN",
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                color: semantic.secondaryText,
                                                letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        Text(
                                            DateHelper.formatDue(c.dueDate)
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: isOverUtil
                                                    ? semantic.overspent
                                                    : isHighUtil
                                                        ? semantic.warning
                                                        : semantic
                                                            .warning)), // Keep warning color for due dates generally
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: semantic.divider
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: 1000.ms,
                                      height: 8,
                                      width:
                                          (MediaQuery.of(context).size.width -
                                                  96) *
                                              (util / 100).clamp(0.01, 1.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            barColor,
                                            barColor.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: barColor.withValues(
                                                  alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${util.toStringAsFixed(1)}% UTILIZED",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: barColor,
                                            letterSpacing: 0.5)),
                                    Text(
                                        "OF ${CurrencyFormatter.format(limit.toInt())}",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: semantic.secondaryText,
                                            letterSpacing: 0.5)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showPayDialog(c),
                                        icon:
                                            const Icon(Icons.payment, size: 16),
                                        label: const Text("RECORD PAYMENT"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor:
                                              const Color(0xFF064E3B),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (100 * i).ms).slideY(
                          begin: 0.1, end: 0, curve: Curves.easeOutQuint);
                    }),
                  ],
                ),
    );
  }

  Widget _buildTotalSummaryCard(AppColors semantic) {
    double totalBalance = 0;
    for (var card in cards) {
      totalBalance += card.statementBalance;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text("TOTAL CARDS DEBT",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalBalance.toInt(), compact: false),
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
