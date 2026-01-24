import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/data/repositories/financial_repository_impl.dart';
import 'package:truecash/domain/repositories/i_financial_repository.dart';

final financialRepositoryProvider = Provider<IFinancialRepository>((ref) {
  return FinancialRepositoryImpl();
});
