import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:trueledger/main.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';
import 'package:trueledger/presentation/screens/startup/intro_screen.dart';
import 'package:trueledger/presentation/providers/usecase_providers.dart';
import 'package:trueledger/domain/usecases/startup_usecase.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueledger/domain/usecases/usecase_base.dart';

import 'package:trueledger/presentation/providers/boot_provider.dart';
import 'package:trueledger/presentation/providers/notification_provider.dart';
import 'package:trueledger/core/services/notification_service.dart';

class MockStartupUseCase extends Mock implements StartupUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService mockNotifications;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockNotifications = MockNotificationService();
    when(() => mockNotifications.requestPermissions())
        .thenAnswer((_) async => true);
  });

  testWidgets('Fresh install flow: Intro -> Dashboard',
      (WidgetTester tester) async {
    // 1. Mock setup
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
          notificationServiceProvider.overrideWithValue(mockNotifications),
          bootProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: const TrueLedgerApp(),
      ),
    );

    // Initial state should be loading
    expect(find.text('Initializing...'), findsOneWidget);

    // Wait for initialization
    await tester.pump(const Duration(seconds: 1));

    // Should now show IntroScreen
    expect(find.byType(IntroScreen), findsOneWidget);

    // 2. Enter name and click GET STARTED
    await tester.enterText(find.byType(TextField), 'Test User');
    await tester.pump();

    final getStartedButton = find.text('GET STARTED');
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);

    // Wait for navigation and animations
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Check if we reached the Dashboard area (or at least moved away from Intro)
    expect(find.byType(IntroScreen), findsNothing);
  });
}
