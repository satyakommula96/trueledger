import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';

final investmentsProvider = FutureProvider<InvestmentData>((ref) async {
  final repo = ref.watch(financialRepositoryProvider);
  final investments = await repo.getInvestments();

  final totalValue =
      investments.fold<double>(0, (sum, item) => sum + item.amount);

  // Calculate distribution
  final Map<String, double> distribution = {};
  for (var inv in investments) {
    distribution[inv.type] = (distribution[inv.type] ?? 0) + inv.amount;
  }

  return InvestmentData(
    investments: investments,
    totalValue: totalValue,
    distribution: distribution,
  );
});

class InvestmentData {
  final List<Asset> investments;
  final double totalValue;
  final Map<String, double> distribution;

  InvestmentData({
    required this.investments,
    required this.totalValue,
    required this.distribution,
  });
}
