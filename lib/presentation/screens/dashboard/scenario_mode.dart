import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/core/utils/currency_formatter.dart';
import 'package:trueledger/presentation/providers/dashboard_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Scenario Mode",
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: dashboardAsync.when(
        data: (data) {
          final catSpending = data.categorySpending;
          if (catSpending.isEmpty) {
            return const Center(
                child: Text("Start logging to use Scenario Mode"));
          }

          _selectedCategory ??= catSpending.first['category'] as String;

          final selectedCatData = catSpending.firstWhere(
            (e) => e['category'] == _selectedCategory,
            orElse: () => {'total': 0},
          );
          final monthlyTotal = selectedCatData['total'] as int;
          final monthlySaving = (monthlyTotal * _reductionPercent).round();
          final yearlySaving = monthlySaving * 12;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WHAT IF SCANARIO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Simulate your financial future by adjusting today's habits.",
                  style: TextStyle(
                    fontSize: 16,
                    color: semantic.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Selector
                Text("Select Category",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: semantic.secondaryText)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: semantic.surfaceCombined,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: semantic.divider),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: catSpending.map((c) {
                        final name = c['category'] as String;
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

                const SizedBox(height: 32),

                // Reduction Slider
                Text("Reduction Amount: ${(_reductionPercent * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Slider(
                  value: _reductionPercent,
                  onChanged: (val) => setState(() => _reductionPercent = val),
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  activeColor: Colors.blue,
                ),

                const SizedBox(height: 48),

                // Impact Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "PROJECTED YEARLY SAVINGS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyFormatter.format(yearlySaving, compact: false),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "If you reduce your $_selectedCategory spending by ${(_reductionPercent * 100).toInt()}%, you'll have ${CurrencyFormatter.format(monthlySaving)} extra every month.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(delay: 200.ms),

                const SizedBox(height: 40),

                // Wealth Impact
                Text(
                  "WEALTH IMPACT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: semantic.secondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _ImpactRow(
                  label: "1 Year Progress",
                  value: "+${CurrencyFormatter.format(yearlySaving)}",
                  color: semantic.income,
                ),
                const SizedBox(height: 12),
                _ImpactRow(
                  label: "5 Year Progress",
                  value: "+${CurrencyFormatter.format(yearlySaving * 5)}",
                  color: semantic.income,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ImpactRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<AppColors>()!.surfaceCombined,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: color, fontSize: 18)),
        ],
      ),
    );
  }
}
