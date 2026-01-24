import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/main.dart';

import 'package:truecash/presentation/providers/usecase_providers.dart';
import 'package:truecash/domain/usecases/startup_usecase.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecash/core/providers/shared_prefs_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        .thenAnswer((_) async => const Success(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          startupUseCaseProvider.overrideWithValue(mockStartup),
        ],
        child: const TrueCashApp(),
      ),
    );

    // Pump frames to allow initialization to finish
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify that the intro title is present
    expect(find.text('Track Your Wealth'), findsOneWidget);
  });
}
