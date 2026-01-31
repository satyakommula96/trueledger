import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueledger/main.dart';

import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:trueledger/presentation/providers/boot_provider.dart';

class MockStartupUseCase extends Mock implements StartupUseCase {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(NoParams());
  });

  testWidgets('App load smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'intro_seen': false});
    final prefs = await SharedPreferences.getInstance();

    final mockStartup = MockStartupUseCase();
    when(() => mockStartup.call(any()))
        .thenAnswer((_) async => Success(StartupResult()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          startupUseCaseProvider.overrideWithValue(mockStartup),
          bootProvider.overrideWith((ref) => Future.value(null)), // No PIN
        ],
        child: const TrueLedgerApp(),
      ),
    );

    // Pump frames to allow initialization to finish
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify that the intro title is present
    expect(find.text('Track Your Wealth'), findsOneWidget);
  });
}
