import 'package:flutter/material.dart';

import 'package:truecash/domain/models/models.dart';
import 'package:truecash/core/utils/currency_helper.dart';
import 'package:truecash/core/utils/date_helper.dart';
import 'package:truecash/core/theme/theme.dart';
import 'add_loan.dart';
import 'edit_loan.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/repository_providers.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  List<Loan> loans = [];
  bool _isLoading = true;

  Future<void> load() async {
    final repo = ref.read(financialRepositoryProvider);
    final data = await repo.getLoans();
    if (mounted) {
      setState(() {
        loans = data;
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
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      24, 24, 24, 100 + MediaQuery.of(context).padding.bottom),
                  itemCount: loans.length,
                  itemBuilder: (_, i) {
                    final l = loans[i];
                    final total = l.totalAmount.toDouble();
                    final remaining = l.remainingAmount.toDouble();
                    final emi = l.emi.toDouble();
                    final progress = total == 0 ? 0.0 : remaining / total;

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditLoanScreen(loan: l)));
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: semantic.surfaceCombined,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        l.loanType == 'Individual'
                                            ? Icons.person_rounded
                                            : Icons.account_balance_rounded,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: semantic.overspent
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(l.loanType.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              color: semantic.overspent)),
                                    ),
                                  ],
                                ),
                                Text(
                                    DateHelper.formatDue(l.dueDate,
                                        prefix: l.loanType == 'Individual'
                                            ? "DUE"
                                            : "NEXT EMI"),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: semantic.secondaryText)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(l.name.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        CurrencyHelper.format(
                                            remaining.toInt()),
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5)),
                                    Text(
                                        l.loanType == 'Individual'
                                            ? "Borrowed Amount"
                                            : "Remaining Balance",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: semantic.secondaryText,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                if (l.loanType != 'Individual')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(CurrencyHelper.format(emi.toInt()),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800)),
                                      Text("Monthly EMI",
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
                                value: total == 0 ? 0 : 1 - progress,
                                backgroundColor: semantic.divider,
                                color: semantic.overspent,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (l.loanType != 'Individual')
                                  Text("${l.interestRate}% APR",
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: semantic.secondaryText)),
                                Text(
                                    "TOTAL: ${CurrencyHelper.format(total.toInt())}",
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: semantic.secondaryText)),
                              ],
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
