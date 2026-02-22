import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/core/utils/date_helper.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/screens/loans/add_loan.dart';
import 'package:trueledger/presentation/screens/loans/edit_loan.dart';
import 'package:trueledger/presentation/screens/loans/debt_payoff_planner.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/components/hover_wrapper.dart';
import 'package:trueledger/core/theme/color_helper.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .failedToLoadLoans(e.toString()))),
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
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.borrowingsAndLoans),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddLoanScreen()));
          load();
        },
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: semantic.primary))
          : _buildBody(semantic),
    );
  }

  Widget _buildBody(AppColors semantic) {
    if (loans.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noActiveBorrowings,
          style: TextStyle(
            color: semantic.secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 100 + MediaQuery.of(context).padding.bottom),
      children: [
        _buildTotalSummaryCard(semantic),
        const SizedBox(height: 16),
        _buildPlannerBanner(context, semantic),
        const SizedBox(height: 32),
        ...loans.asMap().entries.map((entry) {
          final i = entry.key;
          final l = entry.value;
          return _buildLoanCard(l, i, semantic);
        }),
      ],
    );
  }

  IconData _getAccountIcon(String name, String type) {
    if (type == 'Individual') return Icons.person_rounded;

    final lower = name.toLowerCase();
    if (lower.contains('chase')) return SimpleIcons.chase;
    if (lower.contains('amex') || lower.contains('american express')) {
      return SimpleIcons.americanexpress;
    }
    if (lower.contains('visa')) return SimpleIcons.visa;
    if (lower.contains('mastercard')) return SimpleIcons.mastercard;
    if (lower.contains('discover')) return SimpleIcons.discover;
    if (lower.contains('diners')) return SimpleIcons.dinersclub;
    if (lower.contains('jcb')) return SimpleIcons.jcb;
    if (lower.contains('hsbc')) return SimpleIcons.hsbc;
    if (lower.contains('barclays')) return SimpleIcons.barclays;
    if (lower.contains('hdfc')) return SimpleIcons.hdfcbank;
    if (lower.contains('icici')) return SimpleIcons.icicibank;
    if (lower.contains('paytm')) return SimpleIcons.paytm;
    if (lower.contains('phonepe')) return SimpleIcons.phonepe;
    if (lower.contains('gpay') || lower.contains('google pay')) {
      return SimpleIcons.googlepay;
    }
    if (lower.contains('apple')) return SimpleIcons.apple;
    if (lower.contains('amazon')) return SimpleIcons.amazon;
    if (lower.contains('paypal')) return SimpleIcons.paypal;
    if (lower.contains('stripe')) return SimpleIcons.stripe;
    if (lower.contains('wise')) return SimpleIcons.wise;
    if (lower.contains('revolut')) return SimpleIcons.revolut;
    if (lower.contains('monzo')) return SimpleIcons.monzo;
    if (lower.contains('n26')) return SimpleIcons.n26;
    if (lower.contains('cash app') || lower.contains('cashapp')) {
      return SimpleIcons.cashapp;
    }

    return Icons.account_balance_rounded;
  }

  Widget _buildLoanCard(Loan l, int index, AppColors semantic) {
    final l10n = AppLocalizations.of(context)!;

    final total = l.totalAmount.toDouble();
    final remaining = l.remainingAmount.toDouble();
    final emi = l.emi.toDouble();
    final progress = total == 0 ? 0.0 : remaining / total;
    final loanColor = ColorHelper.getColorForName(l.name);
    final isHighDebt = progress > 0.9;
    final barColor = isHighDebt ? semantic.overspent : loanColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: HoverWrapper(
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditLoanScreen(loan: l)));
          load();
        },
        borderRadius: 28,
        glowColor: barColor.withValues(alpha: 0.3),
        glowOpacity: 0.05,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: semantic.divider, width: 1.5),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getAccountIcon(l.name, l.loanType),
                      size: 20,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.name.toUpperCase(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: semantic.text,
                              letterSpacing: 0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _localizeLoanType(l.loanType, context).toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: semantic.secondaryText,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.remaining,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: semantic.secondaryText,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.format(remaining),
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: semantic.text,
                                letterSpacing: -1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: semantic.divider.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateHelper.formatDue(l.dueDate,
                                    prefix: l.loanType == 'Individual'
                                        ? l10n.due
                                        : l10n.emi,
                                    todayLabel: l10n.dueTodayLabel,
                                    tomorrowLabel: l10n.dueTomorrowLabel,
                                    flexibleLabel: l10n.flexible,
                                    recurringLabel: l10n.recurring)
                                .toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: semantic.secondaryText),
                          ),
                        ),
                        if (l.loanType != 'Individual') ...[
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.emi,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: semantic.secondaryText,
                                letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(emi),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: barColor),
                          ),
                        ],
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
                        (total == 0 ? 0.0 : 1 - progress).clamp(0.01, 1.0),
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
                    AppLocalizations.of(context)!.percentRepaid(
                        ((1 - progress) * 100).toStringAsFixed(0)),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: barColor,
                        letterSpacing: 0.5),
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .ofAmount(CurrencyFormatter.format(total)),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: semantic.secondaryText.withValues(alpha: 0.6),
                        letterSpacing: 0.5),
                  ),
                ],
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

  Widget _buildTotalSummaryCard(AppColors semantic) {
    double totalRemaining = 0;
    for (var loan in loans) {
      totalRemaining += loan.remainingAmount;
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: semantic.overspent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: semantic.overspent.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.totalBorrowings,
            style: TextStyle(
              color: semantic.overspent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalRemaining, compact: false),
            style: TextStyle(
              color: semantic.overspent,
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

  Widget _buildPlannerBanner(BuildContext context, AppColors semantic) {
    return HoverWrapper(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const DebtPayoffPlannerScreen())),
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: semantic.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: semantic.primary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.auto_graph_rounded,
                  color: semantic.primary, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.strategy,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: semantic.secondaryText,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.debtPayoffPlanner,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: semantic.text)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: semantic.secondaryText),
          ],
        ),
      ),
    );
  }

  String _localizeLoanType(String type, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'Bank':
        return l10n.bankType;
      case 'Individual':
        return l10n.individualType;
      case 'Gold':
        return l10n.goldType;
      case 'Car':
        return l10n.carType;
      case 'Home':
        return l10n.homeType;
      case 'Education':
        return l10n.educationType;
      default:
        return type;
    }
  }
}
