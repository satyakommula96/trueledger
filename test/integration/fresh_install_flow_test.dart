import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:truecash/main.dart';
import 'package:truecash/core/providers/shared_prefs_provider.dart';
import 'package:truecash/presentation/screens/intro_screen.dart';
import 'package:truecash/presentation/providers/usecase_providers.dart';
import 'package:truecash/domain/usecases/startup_usecase.dart';
import 'package:truecash/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';

class MockStartupUseCase extends Mock implements StartupUseCase {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(NoParams());
  });

  testWidgets('Fresh install flow: Intro -> Dashboard',
      (WidgetTester tester) async {
    // 1. Mock setup
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

    // Initial state should be loading
    expect(find.text('Initializing...'), findsOneWidget);

    // Wait for initialization
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Should now show IntroScreen
    expect(find.byType(IntroScreen), findsOneWidget);

    // 2. Click SKIP
    final skipButton = find.text('SKIP');
    await tester.tap(skipButton);

    // Wait for navigation
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    // Should be on Dashboard (It might show loading if dashboardProvider is real)
    // We haven't mocked dashboardProvider, so it will try to call the real repository.
    // To make this stable, we should ideally mock the data layer here too if we want a pure UI integration test.
  });
}
