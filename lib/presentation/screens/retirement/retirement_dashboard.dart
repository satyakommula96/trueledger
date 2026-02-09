import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/retirement_provider.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/constants/widget_keys.dart';

class RetirementDashboard extends ConsumerWidget {
  const RetirementDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retirementAsync = ref.watch(retirementProvider);
    final isPrivate = ref.watch(privacyProvider);
    final semantic = Theme.of(context).extension<AppColors>()!;

    return retirementAsync.when(
      loading: () => Scaffold(
        backgroundColor: semantic.surfaceCombined,
        body: Center(child: CircularProgressIndicator(color: semantic.primary)),
      ),
      error: (err, stack) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (data) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("RETIREMENT"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showProjectionSettings(context, ref),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 80, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCorpusHero(data.totalCorpus, semantic, isPrivate)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 48),
                _buildSectionHeader(semantic, "MY ACCOUNTS", "BREAKDOWN"),
                const SizedBox(height: 24),
                ...data.accounts
                    .map((acc) => _buildAccountCard(acc, semantic, isPrivate)),
                const SizedBox(height: 48),
                _buildSectionHeader(
                  semantic,
                  "FUTURE WEALTH",
                  "PROJECTION",
                  trailing: Text(
                    "${data.projections.length - 1} YEARS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: semantic.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProjectionChart(data.projections, semantic, isPrivate),
                const SizedBox(height: 48),
                _buildInsightCard(data.totalCorpus, semantic),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(AppColors semantic, String title, String sub,
      {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sub.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  color: semantic.secondaryText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: semantic.text,
                  letterSpacing: -0.5),
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildCorpusHero(double total, AppColors semantic, bool isPrivate) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            semantic.primary.withValues(alpha: 0.9),
            semantic.primary.withValues(alpha: 0.7),
            semantic.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: semantic.primary.withValues(alpha: 0.20),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.0,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded,
                            size: 12, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "RETIREMENT READY",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "TOTAL CORPUS",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(total, isPrivate: isPrivate),
                      key: WidgetKeys.retirementCorpusValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
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

  Widget _buildAccountCard(dynamic acc, AppColors semantic, bool isPrivate) {
    return Container(
      key: WidgetKeys.retirementAccountItem(acc.id),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantic.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.account_balance_rounded,
                color: semantic.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Last updated: ${acc.lastUpdated}",
                  style: TextStyle(
                    fontSize: 11,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(acc.balance, isPrivate: isPrivate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: semantic.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionChart(
      List<Map<String, dynamic>> data, AppColors semantic, bool isPrivate) {
    if (data.isEmpty) return const SizedBox();

    final maxVal = data.last['balance'] as double;
    final int step = (data.length / 5).ceil().clamp(1, 10);

    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                if (entry.key % step != 0 && entry.key != data.length - 1) {
                  return const SizedBox();
                }
                final balance = (entry.value['balance'] as num).toDouble();
                final heightFactor = maxVal == 0 ? 0.0 : balance / maxVal;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: 1.seconds,
                          curve: Curves.easeOutBack,
                          height: 120 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                semantic.primary,
                                semantic.primary.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        child: Text(
                          "AGE ${entry.value['age']}",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: semantic.primary.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        "'${entry.value['year'].toString().substring(2)}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: semantic.secondaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Estimated corpus at retirement: ${CurrencyFormatter.format(maxVal, isPrivate: isPrivate)}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: semantic.secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showProjectionSettings(BuildContext context, WidgetRef ref) {
    final settings = ref.read(retirementSettingsProvider);
    final ageController =
        TextEditingController(text: settings.currentAge.toString());
    final retAgeController =
        TextEditingController(text: settings.retirementAge.toString());
    final rateController =
        TextEditingController(text: settings.annualReturnRate.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 48),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PROJECTION SETTINGS",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child:
                      _buildSimpleField("Current Age", ageController, "Years"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleField(
                      "Retirement Age", retAgeController, "Years"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSimpleField("Expected Return Rate", rateController, "% p.a."),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final newSettings = settings.copyWith(
                    currentAge: int.tryParse(ageController.text),
                    retirementAge: int.tryParse(retAgeController.text),
                    annualReturnRate: double.tryParse(rateController.text),
                  );
                  ref
                      .read(retirementSettingsProvider.notifier)
                      .updateSettings(newSettings);
                  ref.invalidate(dashboardProvider);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).extension<AppColors>()!.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("UPDATE TARGETS",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleField(
      String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(double corpus, AppColors semantic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: semantic.income.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: semantic.income.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantic.income.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.eco_rounded, color: semantic.income, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SMART ADVICE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: semantic.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  corpus > 10000000
                      ? "You're doing great! Keep your contributions steady to beat inflation."
                      : "Consider increasing your monthly NPS/PPF contributions by 10% this year.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: semantic.text,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
