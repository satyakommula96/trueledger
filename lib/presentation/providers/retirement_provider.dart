import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final retirementSettingsProvider =
    NotifierProvider<RetirementSettingsNotifier, RetirementSettings>(
        RetirementSettingsNotifier.new);

class RetirementSettingsNotifier extends Notifier<RetirementSettings> {
  static const _key = 'retirement_settings_v1';

  @override
  RetirementSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      try {
        return RetirementSettings.fromMap(jsonDecode(jsonString));
      } catch (_) {}
    }
    return RetirementSettings();
  }

  Future<void> updateSettings(RetirementSettings settings) async {
    state = settings;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, jsonEncode(settings.toMap()));
  }
}

final retirementProvider = FutureProvider<RetirementData>((ref) async {
  final repo = ref.watch(financialRepositoryProvider);
  final settings = ref.watch(retirementSettingsProvider);
  final accounts = await repo.getRetirementAccounts();

  final currentCorpus =
      accounts.fold<double>(0, (sum, item) => sum + item.balance);

  return RetirementData(
    accounts: accounts,
    totalCorpus: currentCorpus,
    projections: _calculateProjections(currentCorpus, settings),
  );
});

class RetirementData {
  final List<RetirementAccount> accounts;
  final double totalCorpus;
  final List<Map<String, dynamic>> projections;

  RetirementData({
    required this.accounts,
    required this.totalCorpus,
    required this.projections,
  });
}

List<Map<String, dynamic>> _calculateProjections(
    double corpus, RetirementSettings settings) {
  final List<Map<String, dynamic>> projections = [];
  final annualReturn = settings.annualReturnRate / 100;

  // Basic assumption for contribution: if they have accounts, they are contributing.
  // For now, let's stick to a fixed assumption or just growth of current corpus.
  // To keep it simple and accurate to "corpus growth", we'll just project current corpus.
  // We can add "Monthly Contribution" to settings later.
  const contribution = 0.0;

  double runningBalance = corpus;
  final currentYear = DateTime.now().year;
  final yearsToRetirement = settings.retirementAge - settings.currentAge;

  // We project up to retirement age, or at least 25 years.
  final projectionYears = yearsToRetirement > 0 ? yearsToRetirement : 25;

  for (int i = 0; i <= projectionYears; i++) {
    projections.add({
      'year': currentYear + i,
      'age': settings.currentAge + i,
      'balance': runningBalance,
    });

    runningBalance = (runningBalance + contribution) * (1 + annualReturn);
  }

  return projections;
}
