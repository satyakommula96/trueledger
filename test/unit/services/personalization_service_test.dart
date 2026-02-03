import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/services/personalization_service.dart';
import 'package:trueledger/domain/models/models.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late PersonalizationService service;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.setStringList(any(), any()))
        .thenAnswer((_) async => true);
    service = PersonalizationService(mockPrefs);
  });

  group('PersonalizationService - Settings', () {
    test('getSettings returns defaults when nothing is saved', () {
      final settings = service.getSettings();
      expect(settings.rememberLastUsed, true);
      expect(settings.timeOfDaySuggestions, true);
      expect(settings.shortcutSuggestions, true);
      expect(settings.payDay, isNull);
    });

    test('updateSettings saves to prefs', () async {
      final newSettings = PersonalizationSettings(
        rememberLastUsed: false,
        payDay: 15,
      );
      await service.updateSettings(newSettings);
      verify(() => mockPrefs.setString(any(), any())).called(1);
    });
  });

  group('PersonalizationService - Signals & Presets', () {
    test('recordSignal saves to string list', () async {
      await service.recordSignal(key: 'test', reason: 'test');
      verify(() =>
              mockPrefs.setStringList(any(that: contains('signals')), any()))
          .called(1);
    });

    test('addPreset saves to string list', () async {
      final preset =
          QuickAddPreset(id: '1', title: 'Test', amount: 100, category: 'Food');
      await service.addPreset(preset);
      verify(() =>
              mockPrefs.setStringList(any(that: contains('presets')), any()))
          .called(1);
    });
  });

  group('PersonalizationService - Last Used', () {
    test('recordUsage saves last used data', () async {
      await service.recordUsage(
        category: 'Food',
        paymentMethod: 'UPI',
        merchant: 'Starbucks',
      );

      verify(() => mockPrefs.setString(
            any(that: contains('last_used')),
            any(that: contains('Food')),
          )).called(1);
    });
  });

  group('PersonalizationService - Suggestions', () {
    test('getSuggestedCategoryForTime returns based on frequency after 14 days',
        () async {
      final now = DateTime.now();
      // Need 5+ signals spanning 14+ days
      final signals = List.generate(
          6,
          (i) => {
                'key': 'transaction_added',
                'reason': 'test',
                // Explicitly set the hour to match the test requirement
                'timestamp': DateTime(now.year, now.month, now.day, 8)
                    .subtract(Duration(days: i * 3))
                    .toIso8601String(),
                'meta': {'category': 'Breakfast'},
              });

      when(() => mockPrefs.getStringList(any(that: contains('signals'))))
          .thenReturn(signals.map((s) => jsonEncode(s)).toList());

      final suggestion = service.getSuggestedCategoryForTime(8);
      expect(suggestion, 'Breakfast');
    });

    test('findShortcutSuggestion detects repeated merchants/amounts with notes',
        () {
      final signals = List.generate(
          3,
          (i) => {
                'key': 'transaction_added',
                'reason': 'test',
                'timestamp': DateTime.now().toIso8601String(),
                'meta': {'note': 'Gym', 'amount': 2000, 'category': 'Health'},
              });

      when(() => mockPrefs.getStringList(any(that: contains('signals'))))
          .thenReturn(signals.map((s) => jsonEncode(s)).toList());

      final shortcut = service.findShortcutSuggestion();
      expect(shortcut, isNotNull);
      expect(shortcut!.title, 'Gym');
    });
  });

  group('PersonalizationService - Opt-out Enforcement', () {
    test('getLastUsed returns empty if rememberLastUsed is disabled', () async {
      // 1. Save dummy data
      when(() => mockPrefs.getString(any(that: contains('last_used'))))
          .thenReturn(jsonEncode({'category': 'Food'}));

      // 2. Disable feature in settings
      final settings = PersonalizationSettings(rememberLastUsed: false);
      when(() => mockPrefs.getString(any(that: contains('settings'))))
          .thenReturn(jsonEncode(settings.toJson()));

      // 3. Verify
      final lastUsed = service.getLastUsed();
      expect(lastUsed, isEmpty);
    });

    test('recordSignal is a no-op if all features are disabled', () async {
      // Disable all features
      final settings = PersonalizationSettings(
        rememberLastUsed: false,
        timeOfDaySuggestions: false,
        shortcutSuggestions: false,
        baselineReflections: false,
      );
      when(() => mockPrefs.getString(any(that: contains('settings'))))
          .thenReturn(jsonEncode(settings.toJson()));

      await service.recordSignal(key: 'test', reason: 'test');

      // Should never call setStringList for signals
      verifyNever(
          () => mockPrefs.setStringList(any(that: contains('signals')), any()));
    });

    test(
        'generateBaselineReflections returns empty if baselineReflections is disabled',
        () {
      // 1. Provide enough data for reflections
      final signals = List.generate(
          20,
          (i) => {
                'key': 'transaction_added',
                'reason': 'test',
                'timestamp': DateTime.now()
                    .subtract(Duration(days: i + 1))
                    .toIso8601String(),
                'meta': {'amount': 1000},
              });
      when(() => mockPrefs.getStringList(any(that: contains('signals'))))
          .thenReturn(signals.map((s) => jsonEncode(s)).toList());

      // 2. Disable feature in settings
      final settings = PersonalizationSettings(baselineReflections: false);
      when(() => mockPrefs.getString(any(that: contains('settings'))))
          .thenReturn(jsonEncode(settings.toJson()));

      // 3. Verify
      final reflections = service.generateBaselineReflections();
      expect(reflections, isEmpty);
    });
  });
}
