import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/retirement_provider.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:trueledger/presentation/providers/privacy_provider.dart';
import 'package:trueledger/core/constants/widget_keys.dart';
import 'package:trueledger/l10n/app_localizations.dart';

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
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.retirement),
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
                _buildCorpusHero(context, data.totalCorpus, semantic, isPrivate)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuint),
                const SizedBox(height: 48),
                _buildSectionHeader(semantic, l10n.myAccounts, l10n.breakdown),
                const SizedBox(height: 24),
                ...data.accounts.map((acc) =>
                    _buildAccountCard(context, acc, semantic, isPrivate)),
                const SizedBox(height: 48),
                _buildSectionHeader(
                  semantic,
                  l10n.futureWealth,
                  l10n.projection,
                  trailing: Text(
                    "${data.projections.length - 1} ${l10n.yearsLabel}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: semantic.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildProjectionChart(
                    context, data.projections, semantic, isPrivate),
                const SizedBox(height: 48),
                _buildInsightCard(context, data.totalCorpus, semantic),
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
        Expanded(
          child: Column(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing,
        ],
      ],
    );
  }

  Widget _buildCorpusHero(
      BuildContext context, double total, AppColors semantic, bool isPrivate) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: semantic.primary.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            // Base Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    semantic.primary,
                    semantic.primary.withValues(alpha: 0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Mesh Circles
            _buildMeshCircle(
                -50, -50, 250, Colors.white.withValues(alpha: 0.1)),
            _buildMeshCircle(
                120, 100, 200, Colors.blue.withValues(alpha: 0.15)),

            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.retirementReady,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.totalRetirementCorpus.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(total, isPrivate: isPrivate),
                      key: WidgetKeys.retirementCorpusValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
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

  Widget _buildMeshCircle(double top, double left, double size, Color color) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(
      BuildContext context, dynamic acc, AppColors semantic, bool isPrivate) {
    return Container(
      key: WidgetKeys.retirementAccountItem(acc.id),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider, width: 1.5),
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.name.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: semantic.text,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.latency(
                      DateFormat('dd MMM yyyy').format(acc.lastUpdated)),
                  style: TextStyle(
                    fontSize: 9,
                    color: semantic.secondaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(acc.balance, isPrivate: isPrivate),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: semantic.text,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionChart(BuildContext context,
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
            AppLocalizations.of(context)!.estimatedCorpus(
                CurrencyFormatter.format(maxVal, isPrivate: isPrivate)),
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
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
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
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.projectionSettings,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5),
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    child: _buildSimpleField(context, l10n.currentAgeLabel,
                        ageController, l10n.yearsLabel),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSimpleField(context, l10n.retirementAgeLabel,
                        retAgeController, l10n.yearsLabel),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSimpleField(
                  context, l10n.expectedReturn, rateController, l10n.percentPa),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
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
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(l10n.updateTargets,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 2)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleField(BuildContext context, String label,
      TextEditingController controller, String suffix) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            filled: true,
            fillColor: semantic.surfaceCombined.withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: semantic.divider, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: semantic.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
      BuildContext context, double corpus, AppColors semantic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: semantic.income.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: semantic.income.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: semantic.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.tips_and_updates_rounded,
                color: semantic.income, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.wealthAdvisory,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: semantic.secondaryText,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  corpus > 10000000
                      ? AppLocalizations.of(context)!.optimalTrajectory
                      : AppLocalizations.of(context)!.velocityAdjustment,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: semantic.text,
                    height: 1.5,
                    letterSpacing: -0.2,
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
