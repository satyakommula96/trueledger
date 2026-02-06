import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/presentation/screens/settings/personalization_settings.dart';
import 'package:trueledger/core/theme/theme.dart';
import 'package:trueledger/presentation/providers/repository_providers.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';

class MockPersonalizationService extends Mock
    implements PersonalizationService {}

class MockFinancialRepository extends Mock implements IFinancialRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(PersonalizationSettings());
  });

  late MockPersonalizationService mockService;
  late MockFinancialRepository mockRepo;

  setUp(() {
    mockService = MockPersonalizationService();
    mockRepo = MockFinancialRepository();

    when(() => mockService.getSettings()).thenReturn(PersonalizationSettings());
    when(() => mockService.getPresets()).thenReturn([
      QuickAddPreset(id: '1', title: 'Coffee', amount: 100, category: 'Food'),
    ]);
    when(() => mockService.updateSettings(any())).thenAnswer((_) async => {});
    when(() => mockService.removePreset(any())).thenAnswer((_) async => {});

    when(() => mockRepo.getCategories(any())).thenAnswer((_) async => [
          TransactionCategory(id: 1, name: 'Food', type: 'Variable'),
        ]);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        personalizationServiceProvider.overrideWithValue(mockService),
        financialRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const PersonalizationSettingsScreen(),
      ),
    );
  }

  group('PersonalizationSettingsScreen', () {
    testWidgets('displays settings toggles and presets', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('REMEMBER LAST-USED'), findsOneWidget);
      expect(find.text('BASELINE REFLECTIONS'), findsOneWidget);

      final coffeeFinder = find.text('COFFEE');
      await tester.scrollUntilVisible(coffeeFinder, 100);
      expect(coffeeFinder, findsOneWidget);
    });

    testWidgets('toggles setting calls updateSettings', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('TIME-OF-DAY SUGGESTIONS'));
      await tester.pumpAndSettle();

      verify(() => mockService.updateSettings(any())).called(1);
    });

    testWidgets('clicking delete on preset calls removePreset', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
      await tester.scrollUntilVisible(deleteIcon, 100);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      verify(() => mockService.removePreset('1')).called(1);
    });

    testWidgets('reset personalization shows dialog', (tester) async {
      when(() => mockService.resetPersonalization())
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final resetTile = find.text('RESET PERSONALIZATION');
      await tester.scrollUntilVisible(resetTile, 100);
      await tester.tap(resetTile);
      await tester.pumpAndSettle();

      expect(find.text('RESET PERSONALIZATION?'), findsOneWidget);
      await tester.tap(find.text('RESET'));
      await tester.pumpAndSettle();

      verify(() => mockService.resetPersonalization()).called(1);
    });
  });
}
