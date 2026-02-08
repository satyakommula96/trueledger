import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/cards/add_card.dart';
import 'package:trueledger/presentation/screens/cards/edit_card.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
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

  void _showPayDialog(CreditCard card, AppColors semantic) {
    final controller = TextEditingController();
    final isPrivate = ref.read(privacyProvider);

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: semantic.surfaceCombined.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(color: semantic.divider, width: 1.5)),
          title: Text(
            "RECORD PAYMENT",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: semantic.text,
                fontSize: 14,
                letterSpacing: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.bank.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: semantic.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: semantic.income.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: semantic.income.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded,
                          size: 16, color: semantic.income),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DUE BALANCE",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: semantic.secondaryText,
                                  letterSpacing: 1)),
                          Text(
                            CurrencyFormatter.format(card.statementBalance,
                                isPrivate: isPrivate),
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: semantic.income,
                                letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: TextStyle(
                    color: semantic.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18),
                decoration: InputDecoration(
                  labelText: "AMOUNT TO RECORD",
                  labelStyle: TextStyle(
                      color: semantic.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2),
                  filled: true,
                  fillColor: semantic.surfaceCombined.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: semantic.divider, width: 1.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: semantic.divider, width: 1.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          BorderSide(color: semantic.primary, width: 2)),
                  prefixIcon: Icon(Icons.currency_rupee_rounded,
                      size: 18, color: semantic.text),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (card.minDue > 0)
                    Expanded(
                      child: _buildPillAction(
                        "MIN: ${CurrencyFormatter.format(card.minDue, isPrivate: isPrivate)}",
                        () => controller.text = card.minDue.toString(),
                        semantic,
                      ),
                    ),
                  if (card.minDue > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _buildPillAction(
                      "FULL BALANCE",
                      () => controller.text = card.statementBalance.toString(),
                      semantic,
                    ),
                  ),
                ],
              )
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("CANCEL",
                          style: TextStyle(
                              color: semantic.secondaryText,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isEmpty) return;
                        final amount = double.tryParse(controller.text);
                        if (amount == null || amount <= 0) return;

                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);
                        try {
                          await ref
                              .read(financialRepositoryProvider)
                              .payCreditCardBill(card.id, amount);
                          load();
                        } catch (e) {
                          setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: semantic.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("RECORD",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillAction(String text, VoidCallback onTap, AppColors semantic) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: semantic.surfaceCombined.withValues(alpha: 0.5),
          border: Border.all(color: semantic.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final isPrivate = ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CARDS"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddCreditCardScreen()));
          load();
        },
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: semantic.primary))
          : _buildBody(semantic, isPrivate),
    );
  }

  Widget _buildBody(AppColors semantic, bool isPrivate) {
    if (cards.isEmpty) {
      return Center(
        child: Text(
          "NO CARDS REGISTERED",
          style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 100 + MediaQuery.of(context).padding.bottom),
      children: [
        _buildTotalSummaryCard(semantic, isPrivate),
        const SizedBox(height: 32),
        ...cards.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return _buildCardItem(c, i, semantic, isPrivate);
        }),
      ],
    );
  }

  Widget _buildCardItem(
      CreditCard c, int index, AppColors semantic, bool isPrivate) {
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
      padding: const EdgeInsets.only(bottom: 24),
      child: HoverWrapper(
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditCreditCardScreen(card: c)));
          load();
        },
        borderRadius: 32,
        glowColor: barColor.withValues(alpha: 0.3),
        glowOpacity: 0.05,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: semantic.divider, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: barColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.credit_card_rounded,
                              size: 20, color: barColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.bank.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: semantic.text,
                                    letterSpacing: -0.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "LIMIT: ${CurrencyFormatter.format(limit, isPrivate: isPrivate)}",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: semantic.secondaryText,
                                    letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        if (isHighUtil)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isOverUtil
                                      ? semantic.overspent
                                      : semantic.warning)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isOverUtil
                                  ? Icons.priority_high_rounded
                                  : Icons.warning_rounded,
                              size: 16,
                              color: isOverUtil
                                  ? semantic.overspent
                                  : semantic.warning,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "OUTSTANDING BALANCE",
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: semantic.secondaryText,
                                    letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyFormatter.format(stmt,
                                      isPrivate: isPrivate),
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: semantic.text,
                                      letterSpacing: -1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: semantic.divider.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "DUE IN",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: semantic.secondaryText,
                                    letterSpacing: 0.5),
                              ),
                              Text(
                                DateHelper.formatDue(c.dueDate).toUpperCase(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: semantic.warning),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: semantic.divider.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        AnimatedContainer(
                          duration: 1200.ms,
                          curve: Curves.easeOutCubic,
                          height: 8,
                          width: (MediaQuery.of(context).size.width - 96) *
                              (util / 100).clamp(0.01, 1.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                barColor,
                                barColor.withValues(alpha: 0.6)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: barColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${util.toStringAsFixed(1)}% UTILIZED",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: barColor,
                              letterSpacing: 0.5),
                        ),
                        Text(
                          "LEFT: ${CurrencyFormatter.format(limit - stmt, isPrivate: isPrivate)}",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color:
                                  semantic.secondaryText.withValues(alpha: 0.6),
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showPayDialog(c, semantic),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  color: semantic.primary.withValues(alpha: 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_rounded,
                          size: 18, color: semantic.primary),
                      const SizedBox(width: 12),
                      Text(
                        "RECORD PAYMENT",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: semantic.primary,
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _buildTotalSummaryCard(AppColors semantic, bool isPrivate) {
    double totalBalance = 0;
    for (var card in cards) {
      totalBalance += card.statementBalance;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            "TOTAL CARDS DEBT",
            style: TextStyle(
              color: semantic.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalBalance,
                compact: false, isPrivate: isPrivate),
            style: TextStyle(
              color: semantic.text,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(duration: 800.ms, curve: Curves.easeOutBack),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
  }
}
