import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:trueledger/l10n/app_localizations.dart';

class ScenarioScreen extends ConsumerStatefulWidget {
  const ScenarioScreen({super.key});

  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends ConsumerState<ScenarioScreen> {
  String? _selectedCategory;
  double _reductionPercent = 0.20; // Default 20% reduction

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceCombined,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          l10n.scenarioModeTitle,
          style: TextStyle(
              fontWeight: FontWeight.w900, color: semantic.text, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: dashboardAsync.when(
        data: (data) {
          final catSpending = data.categorySpending;
          if (catSpending.isEmpty) {
            return Center(
              child: Text(l10n.startLoggingToUseScenario,
                  style: TextStyle(color: semantic.secondaryText)),
            );
          }

          _selectedCategory ??= catSpending.first.category;

          final selectedCatData = catSpending.firstWhere(
            (e) => e.category == _selectedCategory,
            orElse: () =>
                CategorySpending(category: _selectedCategory!, total: 0),
          );
          final monthlyTotal = selectedCatData.total;
          final monthlySaving = (monthlyTotal * _reductionPercent).round();
          final yearlySaving = monthlySaving * 12;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 80, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.simulation,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: semantic.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.whatIfSavedMore,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: semantic.text,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuint),

                const SizedBox(height: 48),

                // Selector Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: semantic.surfaceCombined.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: semantic.divider, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.selectCategory,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: semantic.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: semantic.divider.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            dropdownColor: semantic.surfaceCombined,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: semantic.text,
                                fontSize: 16),
                            items: catSpending.map((c) {
                              final name = c.category;
                              return DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCategory = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 24),

                // Slider Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: semantic.surfaceCombined.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: semantic.divider, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.reductionPercent,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: semantic.secondaryText),
                          ),
                          Text(
                            "${(_reductionPercent * 100).toInt()}%",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: semantic.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          activeTrackColor: semantic.primary,
                          inactiveTrackColor: semantic.divider,
                          thumbColor: semantic.primary,
                          overlayColor: semantic.primary.withValues(alpha: 0.1),
                          valueIndicatorColor: semantic.primary,
                        ),
                        child: Slider(
                          value: _reductionPercent,
                          onChanged: (val) =>
                              setState(() => _reductionPercent = val),
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 48),

                // Impact Card (The Wow element)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: semantic.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: semantic.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.projectedYearlySavings,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyFormatter.format(yearlySaving, compact: false),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.scenarioImpactMessage(
                            _selectedCategory ?? "",
                            (_reductionPercent * 100).toInt(),
                            CurrencyFormatter.format(monthlySaving),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 800.ms)
                    .scale(curve: Curves.easeOutBack),

                const SizedBox(height: 48),

                Text(
                  l10n.wealthImpact,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 24),
                _ImpactTile(
                  semantic: semantic,
                  label: l10n.oneYearProgress,
                  value: "+${CurrencyFormatter.format(yearlySaving)}",
                  icon: Icons.auto_graph_rounded,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                _ImpactTile(
                  semantic: semantic,
                  label: l10n.fiveYearMilestones,
                  value: "+${CurrencyFormatter.format(yearlySaving * 5)}",
                  icon: Icons.account_balance_rounded,
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),
              ],
            ),
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: semantic.primary)),
        error: (err, stack) => Center(
            child: Text(l10n.simulationFailed(err.toString()),
                style: TextStyle(color: semantic.overspent))),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final AppColors semantic;
  final String label;
  final String value;
  final IconData icon;

  const _ImpactTile({
    required this.semantic,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: semantic.surfaceCombined.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: semantic.divider, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: semantic.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: semantic.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: semantic.text,
                  fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: semantic.success,
                fontSize: 18,
                letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }
}
