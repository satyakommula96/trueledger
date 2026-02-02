import 'package:flutter/material.dart';

import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/core/theme/color_helper.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  List<Loan> loans = [];
  bool _isLoading = true;

  Future<void> load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data = await repo.getLoans();
      if (mounted) {
        setState(() {
          loans = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading loans: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load loans: $e")),
        );
      }
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
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("BORROWINGS & LOANS")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddLoanScreen()));
          load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : loans.isEmpty
              ? Center(
                  child: Text("NO ACTIVE BORROWINGS.",
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
                    ...loans.asMap().entries.map((entry) {
                      final i = entry.key;
                      final l = entry.value;
                      final total = l.totalAmount.toDouble();
                      final remaining = l.remainingAmount.toDouble();
                      final emi = l.emi.toDouble();
                      final progress = total == 0 ? 0.0 : remaining / total;
                      final loanColor = ColorHelper.getColorForName(l.name);

                      // If more than 90% of the loan is remaining, show it as "high debt" (red)
                      final isHighDebt = progress > 0.9;
                      final barColor =
                          isHighDebt ? semantic.overspent : loanColor;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: HoverWrapper(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EditLoanScreen(loan: l)));
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
                                        l.loanType == 'Individual'
                                            ? Icons.person_rounded
                                            : Icons.account_balance_rounded,
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
                                          Text(l.name.toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5)),
                                          const SizedBox(height: 2),
                                          Text(l.loanType.toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                  color: semantic.secondaryText,
                                                  letterSpacing: 1)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: semantic.divider
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                          DateHelper.formatDue(l.dueDate,
                                                  prefix:
                                                      l.loanType == 'Individual'
                                                          ? "DUE"
                                                          : "EMI")
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: semantic.secondaryText)),
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
                                          Text("REMAINING",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: semantic.secondaryText,
                                                  letterSpacing: 1)),
                                          const SizedBox(height: 4),
                                          Text(
                                              CurrencyFormatter.format(
                                                  remaining.toInt()),
                                              style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -1)),
                                        ],
                                      ),
                                    ),
                                    if (l.loanType != 'Individual')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text("EMI",
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: semantic.secondaryText,
                                                  letterSpacing: 1)),
                                          const SizedBox(height: 4),
                                          Text(
                                              CurrencyFormatter.format(
                                                  emi.toInt()),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: barColor)),
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
                                              (total == 0 ? 0.0 : 1 - progress)
                                                  .clamp(0.01, 1.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            barColor,
                                            barColor.withValues(alpha: 0.6),
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
                                    Text(
                                        "${((1 - progress) * 100).toStringAsFixed(0)}% REPAID",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: barColor,
                                            letterSpacing: 0.5)),
                                    Text(
                                        "OF ${CurrencyFormatter.format(total.toInt())}",
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: semantic.secondaryText,
                                            letterSpacing: 0.5)),
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
    double totalRemaining = 0;
    for (var loan in loans) {
      totalRemaining += loan.remainingAmount;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.overspent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.overspent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text("TOTAL BORROWINGS",
              style: TextStyle(
                color: semantic.overspent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalRemaining.toInt(), compact: false),
            style: TextStyle(
              color: semantic.overspent,
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
