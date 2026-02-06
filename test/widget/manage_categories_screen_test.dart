import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/presentation/screens/settings/manage_categories.dart';
import 'package:trueledger/core/theme/theme.dart';

class MockFinancialRepository extends Mock implements IFinancialRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFinancialRepository mockRepository;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getBool(any())).thenReturn(false);

    // Default mock setup
    when(() => mockRepository.getCategories(any())).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        financialRepositoryProvider.overrideWithValue(mockRepository),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const ManageCategoriesScreen(),
      ),
    );
  }

  group('ManageCategoriesScreen', () {
    testWidgets('should display empty state when no categories exist',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('NO CATEGORIES YET'), findsOneWidget);
      expect(find.text('Add your first category for Variable'), findsOneWidget);
    });

    testWidgets('should display list of categories', (tester) async {
      final categories = [
        TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
        TransactionCategory(id: 2, name: 'Transport', type: 'Variable'),
      ];

      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => categories);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('FOOD'), findsOneWidget);
      expect(find.text('TRANSPORT'), findsOneWidget);
    });

    testWidgets('should add a new category', (tester) async {
      when(() => mockRepository.addCategory('New Cat', 'Variable'))
          .thenAnswer((_) async {});
      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New Cat');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      verify(() => mockRepository.addCategory('New Cat', 'Variable')).called(1);
    });

    testWidgets('should delete a category', (tester) async {
      final category =
          TransactionCategory(id: 1, name: 'Food', type: 'Variable');
      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => [category]);
      when(() => mockRepository.deleteCategory(1)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      verify(() => mockRepository.deleteCategory(1)).called(1);
    });

    testWidgets('should switch types', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('INCOME'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.getCategories('Income')).called(1);
    });
    testWidgets('should return the last added category name', (tester) async {
      String? returnedValue;
      await tester.pumpWidget(ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedValue = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen(
                              initialType: 'Variable')),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Verify we are on the ManageCategoriesScreen
      expect(find.byType(TextField), findsOneWidget);

      when(() => mockRepository.addCategory('Coffee', 'Variable'))
          .thenAnswer((_) async {});
      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => []);

      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Check if checkmark icon appears in actions
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_circle_rounded));
      await tester.pumpAndSettle();

      expect(returnedValue, 'Coffee');
    });

    testWidgets('should return an existing category name when selected',
        (tester) async {
      String? returnedValue;
      final categories = [
        TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
      ];

      when(() => mockRepository.getCategories('Variable'))
          .thenAnswer((_) async => categories);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          financialRepositoryProvider.overrideWithValue(mockRepository),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedValue = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageCategoriesScreen(
                              initialType: 'Variable')),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Tap the selection checkmark (the first one in the list)
      await tester.tap(find.byIcon(Icons.check_circle_outline_rounded).first);
      await tester.pumpAndSettle();

      expect(returnedValue, 'Food');
    });
  });
}
