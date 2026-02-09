import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'dart:math' as math;

enum PayoffStrategy { snowball, avalanche }

class DebtPayoffPlannerScreen extends ConsumerStatefulWidget {
  const DebtPayoffPlannerScreen({super.key});

  @override
  ConsumerState<DebtPayoffPlannerScreen> createState() =>
      _DebtPayoffPlannerScreenState();
}

class _DebtPayoffPlannerScreenState
    extends ConsumerState<DebtPayoffPlannerScreen> {
  PayoffStrategy _strategy = PayoffStrategy.avalanche;
  double _extraMonthly = 0.0;
  List<Loan> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(financialRepositoryProvider);
      final data = await repo.getLoans();
      setState(() {
        _loans = data.where((l) => l.remainingAmount > 0).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("DEBT PAYOFF PLANNER"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: semantic.primary))
          : _buildBody(semantic),
    );
  }

  Widget _buildBody(AppColors semantic) {
    if (_loans.isEmpty) {
      return Center(
        child: Text("NO ACTIVE DEBT. YOU ARE FREE!",
            style: TextStyle(
                color: semantic.secondaryText, fontWeight: FontWeight.bold)),
      );
    }

    final simulation = _simulatePayoff();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(simulation, semantic),
          const SizedBox(height: 32),
          _buildExtraPaymentSlider(semantic),
          const SizedBox(height: 32),
          _buildStrategyToggle(semantic),
          const SizedBox(height: 32),
          _buildPayoffOrder(simulation, semantic),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(_PayoffSimulation sim, AppColors semantic) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [semantic.primary, semantic.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: semantic.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Text("DEBT FREE BY",
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(
            sim.debtFreeDate.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("MONTHS", "${sim.totalMonths}"),
              _buildStat("INTEREST",
                  CurrencyFormatter.format(sim.totalInterest, compact: true)),
              _buildStat("SAVED",
                  CurrencyFormatter.format(sim.interestSaved, compact: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildExtraPaymentSlider(AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            semantic, "BOOST PAYOFF", "EXTRA MONTHLY CONTRIBUTION"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: semantic.surfaceCombined.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: semantic.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("EXTRA PAYMENT",
                      style: TextStyle(
                          color: semantic.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                  Text(CurrencyFormatter.format(_extraMonthly),
                      style: TextStyle(
                          color: semantic.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              Slider(
                value: _extraMonthly,
                min: 0,
                max: 100000,
                divisions: 100,
                activeColor: semantic.primary,
                inactiveColor: semantic.divider,
                onChanged: (val) => setState(() => _extraMonthly = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyToggle(AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            semantic, "PAYOFF STRATEGY", "CHOOSE YOUR APPROACH"),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStrategyBtn("AVALANCHE", "Highest interest first",
                PayoffStrategy.avalanche, semantic),
            const SizedBox(width: 12),
            _buildStrategyBtn("SNOWBALL", "Lowest balance first",
                PayoffStrategy.snowball, semantic),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategyBtn(
      String title, String sub, PayoffStrategy s, AppColors semantic) {
    final isSelected = _strategy == s;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _strategy = s),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? semantic.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? semantic.primary : semantic.divider,
                width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? semantic.primary
                          : semantic.secondaryText)),
              const SizedBox(height: 4),
              Text(sub,
                  style:
                      TextStyle(fontSize: 10, color: semantic.secondaryText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoffOrder(_PayoffSimulation sim, AppColors semantic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            semantic, "PAYOFF SEQUENCE", "PROJECTED MILESTONES"),
        const SizedBox(height: 16),
        ...sim.payoffMilestones.map((m) => _buildMilestoneNode(m, semantic)),
      ],
    );
  }

  Widget _buildMilestoneNode(_Milestone m, AppColors semantic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: semantic.primary, shape: BoxShape.circle),
                ),
                Expanded(child: Container(width: 2, color: semantic.divider)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.date.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: semantic.primary,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(m.loanName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: semantic.text)),
                  const SizedBox(height: 2),
                  Text("Paid off after ${m.months} months",
                      style: TextStyle(
                          fontSize: 12, color: semantic.secondaryText)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(AppColors semantic, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sub.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                color: semantic.secondaryText,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
        Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: semantic.text,
                letterSpacing: -0.5)),
      ],
    );
  }

  _PayoffSimulation _simulatePayoff() {
    // 1. Sort loans based on strategy
    final sortedLoans = List<Loan>.from(_loans);
    if (_strategy == PayoffStrategy.snowball) {
      sortedLoans
          .sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));
    } else {
      sortedLoans.sort((a, b) => b.interestRate.compareTo(a.interestRate));
    }

    // 2. Base simulation (No extra)
    final baseResult = _runSimulation(sortedLoans, 0);
    // 3. User simulation (With extra)
    final userResult = _runSimulation(sortedLoans, _extraMonthly);

    return _PayoffSimulation(
      totalMonths: userResult.months,
      debtFreeDate: _monthsToDate(userResult.months),
      totalInterest: userResult.interest,
      interestSaved: math.max(0, baseResult.interest - userResult.interest),
      payoffMilestones: userResult.milestones,
    );
  }

  _SimResult _runSimulation(List<Loan> loans, double extraMoney) {
    double interest = 0;
    int months = 0;
    final milestones = <_Milestone>[];

    // Create work copies
    var balances = loans.map((l) => l.remainingAmount.toDouble()).toList();
    var emis = loans.map((l) => l.emi.toDouble()).toList();
    var rates = loans.map((l) => l.interestRate.toDouble() / 100 / 12).toList();

    while (balances.any((b) => b > 0) && months < 600) {
      // Max 50 years to avoid infinite loop
      months++;
      double availableExtra = extraMoney;

      for (int i = 0; i < balances.length; i++) {
        if (balances[i] <= 0) continue;

        // Apply interest
        final intPart = balances[i] * rates[i];
        interest += intPart;
        balances[i] += intPart;

        // Apply EMI
        double payment = math.min(balances[i], emis[i]);
        balances[i] -= payment;

        // If loan finished, record milestone
        if (balances[i] <= 0) {
          milestones.add(_Milestone(
              loanName: loans[i].name,
              months: months,
              date: _monthsToDate(months)));
          // Rollover EMI of finished loan to the next loan in strategy
          // For simplicity in this local sim, we add it to the 'extra' for next loop iteration
          // but better logic: apply it immediately to the NEXT loan in the same loop if possible.
          // let's just keep it simple: any finished loan's EMI becomes extra for NEXT month.
          // Wait, actually 'availableExtra' should include finished EMIs.
        }
      }

      // Apply extra money to the TOP loan in strategy
      for (int i = 0; i < balances.length; i++) {
        if (balances[i] > 0) {
          double payment = math.min(balances[i], availableExtra);
          balances[i] -= payment;
          availableExtra -= payment;

          if (balances[i] <= 0) {
            milestones.add(_Milestone(
                loanName: loans[i].name,
                months: months,
                date: _monthsToDate(months)));
          }
          if (availableExtra <= 0) break;
        }
      }

      // Calculate how many EMIs are now "freed up"
      for (int i = 0; i < balances.length; i++) {
        if (balances[i] <= 0) {
          extraMoney += emis[i];
          emis[i] = 0; // Don't add it multiple times
        }
      }
    }

    return _SimResult(
        months: months, interest: interest, milestones: milestones);
  }

  String _monthsToDate(int months) {
    final now = DateTime.now();
    final future = DateTime(now.year, now.month + months, now.day);
    return "${_monthName(future.month)} ${future.year}";
  }

  String _monthName(int m) {
    const names = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    return names[m - 1];
  }
}

class _PayoffSimulation {
  final int totalMonths;
  final String debtFreeDate;
  final double totalInterest;
  final double interestSaved;
  final List<_Milestone> payoffMilestones;

  _PayoffSimulation({
    required this.totalMonths,
    required this.debtFreeDate,
    required this.totalInterest,
    required this.interestSaved,
    required this.payoffMilestones,
  });
}

class _SimResult {
  final int months;
  final double interest;
  final List<_Milestone> milestones;
  _SimResult(
      {required this.months, required this.interest, required this.milestones});
}

class _Milestone {
  final String loanName;
  final int months;
  final String date;
  _Milestone(
      {required this.loanName, required this.months, required this.date});
}
