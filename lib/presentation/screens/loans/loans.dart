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
import 'package:trueledger/core/theme/color_helper.dart';
import 'package:trueledger/l10n/app_localizations.dart';
import 'package:trueledger/presentation/components/apple_style.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AppleScaffold(
      title: l10n.borrowingsAndLoans,
      subtitle: l10n.debtManagement,
      floatingActionButton: FloatingActionButton(
        backgroundColor: semantic.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddLoanScreen()));
          load();
        },
        child: const Icon(Icons.add_rounded, size: 32),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : loans.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(semantic))
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        _buildTotalSummaryCard(semantic),
                        const SizedBox(height: 24),
                        _buildPlannerBanner(context, semantic),
                        const SizedBox(height: 48),
                        AppleSectionHeader(
                          title: l10n.activeLoans,
                          subtitle: l10n.activeWithCount(loans.length),
                        ),
                        const SizedBox(height: 20),
                        ...loans.asMap().entries.map((entry) =>
                            _buildLoanCard(entry.value, entry.key, semantic)),
                      ]),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppColors semantic) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_rounded,
              size: 64, color: semantic.divider.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          Text(
            l10n.noActiveBorrowings,
            style: TextStyle(
                color: semantic.text,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.debtFreeMessage,
            style: TextStyle(
                color: semantic.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
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

    return AppleGlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => EditLoanScreen(loan: l)));
            load();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: barColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(_getAccountIcon(l.name, l.loanType),
                          size: 20, color: barColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.name.toUpperCase(),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: semantic.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _localizeLoanType(l.loanType, context)
                                .toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: semantic.secondaryText,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: semantic.divider, size: 20),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.remaining.toUpperCase(),
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: semantic.secondaryText,
                              letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.format(remaining),
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: semantic.text,
                              letterSpacing: -1),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1))),
                          child: Text(
                            DateHelper.formatDue(l.dueDate,
                                    prefix: l.loanType == 'Individual'
                                        ? l10n.due
                                        : l10n.emi)
                                .toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: semantic.secondaryText),
                          ),
                        ),
                        if (l.loanType != 'Individual') ...[
                          const SizedBox(height: 8),
                          Text(CurrencyFormatter.format(emi),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: barColor)),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                          color: semantic.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    AnimatedContainer(
                      duration: 1200.ms,
                      curve: Curves.easeOutQuart,
                      height: 6,
                      width: (MediaQuery.of(context).size.width - 88) *
                          (total == 0 ? 0.0 : 1 - progress).clamp(0.01, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          barColor,
                          barColor.withValues(alpha: 0.7)
                        ]),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                              color: barColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.percentRepaid(
                          ((1 - progress) * 100).toStringAsFixed(0)),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: barColor),
                    ),
                    Text(
                      l10n.ofAmount(CurrencyFormatter.format(total)),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: semantic.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * index).ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint);
  }

  Widget _buildTotalSummaryCard(AppColors semantic) {
    double totalRemaining =
        loans.fold(0, (sum, item) => sum + item.remainingAmount);

    return AppleGlassCard(
      padding: const EdgeInsets.all(32),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          semantic.overspent.withValues(alpha: 0.15),
          semantic.overspent.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.totalBorrowings.toUpperCase(),
            style: TextStyle(
                color: semantic.overspent.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalRemaining, compact: false),
            style: TextStyle(
                color: semantic.overspent,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -2),
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .scale(duration: 800.ms, curve: Curves.easeOutQuint),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint);
  }

  Widget _buildPlannerBanner(BuildContext context, AppColors semantic) {
    final l10n = AppLocalizations.of(context)!;
    return AppleGlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DebtPayoffPlannerScreen())),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: semantic.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: semantic.primary, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.payoffStrategy.toUpperCase(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: semantic.secondaryText,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(l10n.activeDebtPayoffPlan,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: semantic.text)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: semantic.divider),
              ],
            ),
          ),
        ),
      ),
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
    if (lower.contains('hdfc')) return SimpleIcons.hdfcbank;
    if (lower.contains('icici')) return SimpleIcons.icicibank;
    if (lower.contains('apple')) return SimpleIcons.apple;
    if (lower.contains('amazon')) return SimpleIcons.amazon;
    if (lower.contains('paypal')) return SimpleIcons.paypal;
    return Icons.account_balance_rounded;
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
