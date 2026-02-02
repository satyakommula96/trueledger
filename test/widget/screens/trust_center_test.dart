import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/presentation/screens/settings/trust_center.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepo;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepo = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
  });

  testWidgets('TrustCenterScreen renders stats correctly',
      (WidgetTester tester) async {
    final stats = {
      'variable': 10,
      'fixed': 5,
      'income': 2,
      'budgets': 3,
      'total_records': 20,
    };

    when(() => mockRepo.getDatabaseStats()).thenAnswer((_) async => stats);
    when(() => mockPrefs.getString(any())).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepo),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          databaseStatsProvider.overrideWith((ref) async => stats),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const TrustCenterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Trust & Privacy"), findsOneWidget);
    expect(find.text("DATA HEALTH"), findsOneWidget);
    expect(find.text("Total Records"), findsOneWidget);
    expect(find.text("20"), findsOneWidget);
    expect(find.text("Privacy First"), findsOneWidget);
  });
}
