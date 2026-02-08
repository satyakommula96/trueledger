import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:intl/intl.dart';
import 'package:trueledger/core/providers/shared_prefs_provider.dart';

final personalizationServiceProvider = Provider<PersonalizationService>((ref) {
  return PersonalizationService(ref.watch(sharedPreferencesProvider));
});

class PersonalizationService {
  final SharedPreferences _prefs;

  // Keys
  static const String _settingsKey = 'personalization_settings';
  static const String _presetsKey = 'quick_add_presets';
  static const String _lastUsedKey = 'last_used_values';
  static const String _signalsKey = 'personalization_signals';
  static const String _cooldownsKey = 'personalization_cooldowns';

  PersonalizationService(this._prefs);

  // --- Settings ---
  PersonalizationSettings getSettings() {
    final jsonStr = _prefs.getString(_settingsKey);
    if (jsonStr == null) return PersonalizationSettings();
    try {
      return PersonalizationSettings.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return PersonalizationSettings();
    }
  }

  Future<void> updateSettings(PersonalizationSettings settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // --- Last Used Memory ---
  Future<void> recordUsage({
    required String category,
    required String? paymentMethod,
    String? merchant,
    double? amount,
    String? note,
  }) async {
    final settings = getSettings();
    if (!settings.personalizationEnabled || !settings.rememberLastUsed) return;

    final data = {
      'category': category,
      'paymentMethod': paymentMethod,
      'merchant': merchant,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_lastUsedKey, jsonEncode(data));

    // Also record as a signal for pattern detection
    await recordSignal(
      key: 'transaction_added',
      reason: 'User added a transaction',
      meta: {
        'category': category,
        'paymentMethod': paymentMethod,
        'merchant': merchant,
        'amount': amount,
        'note': note,
        'hour': DateTime.now().hour,
      },
    );
  }

  Map<String, String?> getLastUsed() {
    final settings = getSettings();
    if (!settings.rememberLastUsed) return {};

    final jsonStr = _prefs.getString(_lastUsedKey);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return {
        'category': decoded['category'] as String?,
        'paymentMethod': decoded['paymentMethod'] as String?,
        'merchant': decoded['merchant'] as String?,
      };
    } catch (_) {
      return {};
    }
  }

  // --- Presets ---
  List<QuickAddPreset> getPresets() {
    final List<String>? jsonList = _prefs.getStringList(_presetsKey);
    if (jsonList == null) return [];
    return jsonList.map((s) => QuickAddPreset.fromJson(jsonDecode(s))).toList();
  }

  Future<void> addPreset(QuickAddPreset preset) async {
    final presets = getPresets();
    presets.add(preset);
    await _savePresets(presets);
  }

  Future<void> removePreset(String id) async {
    final presets = getPresets();
    presets.removeWhere((p) => p.id == id);
    await _savePresets(presets);
  }

  Future<void> _savePresets(List<QuickAddPreset> presets) async {
    final List<String> jsonList =
        presets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_presetsKey, jsonList);
  }

  // --- Signals & Patterns ---
  Future<void> recordSignal({
    required String key,
    required String reason,
    Map<String, dynamic> meta = const {},
  }) async {
    final settings = getSettings();
    if (!settings.personalizationEnabled) return;

    // Only record signals if at least one feature that needs them is enabled
    final anyFeatureEnabled = settings.rememberLastUsed ||
        settings.timeOfDaySuggestions ||
        settings.shortcutSuggestions ||
        settings.baselineReflections;

    if (!anyFeatureEnabled) return;

    final signals = _getSignals();
    signals.insert(
        0,
        PersonalizationSignal(
          key: key,
          reason: reason,
          timestamp: DateTime.now(),
          meta: meta,
        ));

    // Keep only last 200 signals to avoid bloating storage
    if (signals.length > 200) {
      signals.removeRange(200, signals.length);
    }

    await _prefs.setStringList(
        _signalsKey, signals.map((s) => jsonEncode(s.toJson())).toList());
  }

  List<PersonalizationSignal> _getSignals() {
    final List<String>? jsonList = _prefs.getStringList(_signalsKey);
    if (jsonList == null) return [];
    return jsonList
        .map((s) => PersonalizationSignal.fromJson(jsonDecode(s)))
        .toList();
  }

  // --- Trust & Control ---
  Future<void> resetPersonalization() async {
    await _prefs.remove(_lastUsedKey);
    await _prefs.remove(_signalsKey);
    await _prefs.remove(_cooldownsKey);
  }

  /// Finds suggested defaults based on time of day (Phase 5.2 requirement)
  String? getSuggestedCategoryForTime(int hour) {
    final settings = getSettings();
    if (!settings.timeOfDaySuggestions) return null;

    final signals = _getSignals()
        .where((s) => s.key == 'transaction_added')
        .where(
            (s) => (s.timestamp.hour - hour).abs() <= 1) // Within 1 hour window
        .toList();

    if (signals.length < 5) return null; // Minimum 5 entries required

    // Spec: Observed over ≥ 14 days
    final earliest = signals.last.timestamp;
    if (DateTime.now().difference(earliest).inDays < 14) return null;

    // Count occurrences of each category
    final Map<String, int> counts = {};
    for (final s in signals) {
      final cat = s.meta['category'] as String?;
      if (cat != null) {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;

    final best = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (best.value >= 5) {
      if (isSnoozed('tod_${best.key}')) return null;
      return best.key;
    }
    return null;
  }

  // --- Cooldowns ---
  bool isSnoozed(String key) {
    final Map<String, dynamic> cooldowns = _getCooldowns();
    final untilStr = cooldowns[key];
    if (untilStr == null) return false;
    try {
      final until = DateTime.parse(untilStr);
      return DateTime.now().isBefore(until);
    } catch (_) {
      return false;
    }
  }

  Future<void> snoozeSuggestion(String key, {int days = 30}) async {
    final Map<String, dynamic> cooldowns = _getCooldowns();
    cooldowns[key] = DateTime.now().add(Duration(days: days)).toIso8601String();
    await _prefs.setString(_cooldownsKey, jsonEncode(cooldowns));
  }

  /// Finds suggested shortcuts based on repetition (Phase 5.2 requirement)
  QuickAddPreset? findShortcutSuggestion() {
    final settings = getSettings();
    if (!settings.shortcutSuggestions) return null;

    final signals =
        _getSignals().where((s) => s.key == 'transaction_added').toList();

    if (signals.length < 3) return null;

    // Count occurrences of (Note, Category, Amount) combos
    final Map<String, int> counts = {};
    final Map<String, PersonalizationSignal> signalMap = {};

    for (final s in signals) {
      final String? note = s.meta['note'];
      final String? cat = s.meta['category'];
      final double? amount = (s.meta['amount'] as num?)?.toDouble();

      if (note != null && cat != null && amount != null && note.isNotEmpty) {
        final key = '$note|$cat|$amount';
        counts[key] = (counts[key] ?? 0) + 1;
        signalMap[key] = s;
      }
    }

    if (counts.isEmpty) return null;

    final best = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Suggest if used 3+ times and not already a preset
    if (best.value >= 3) {
      if (isSnoozed('shortcut_${best.key}')) return null;

      final existingPresets = getPresets();
      final parts = best.key.split('|');
      final note = parts[0];
      final cat = parts[1];
      final amount = double.parse(parts[2]);

      final alreadyPreset = existingPresets.any((p) =>
          p.title.toLowerCase() == note.toLowerCase() ||
          (p.category == cat && p.amount == amount));

      if (!alreadyPreset) {
        return QuickAddPreset(
          id: 'suggested_${best.key}',
          title: note,
          category: cat,
          amount: amount,
          note: note,
        );
      }
    }

    return null;
  }

  /// Generates self-comparisons based on history (Phase 5.3 requirement)
  List<String> generateBaselineReflections() {
    final settings = getSettings();
    if (!settings.baselineReflections) return [];

    final signals =
        _getSignals().where((s) => s.key == 'transaction_added').toList();

    if (signals.length < 15) {
      return []; // Minimum data required (~3 weeks if daily)
    }

    final now = DateTime.now();
    final todayWeekday = now.weekday;

    // Filter signals for the same weekday
    final sameWeekdaySignals =
        signals.where((s) => s.timestamp.weekday == todayWeekday).toList();

    if (sameWeekdaySignals.length < 3) return [];

    // Calculate average for this weekday
    final double total =
        sameWeekdaySignals.fold(0.0, (sum, s) => sum + (s.meta['amount'] ?? 0));
    final average = total / sameWeekdaySignals.length;

    // Get today's total so far
    final todaySignals = signals
        .where((s) =>
            s.timestamp.day == now.day &&
            s.timestamp.month == now.month &&
            s.timestamp.year == now.year)
        .toList();
    final todayTotal =
        todaySignals.fold(0.0, (sum, s) => sum + (s.meta['amount'] ?? 0));

    final List<String> reflections = [];
    if (todayTotal > average * 1.5) {
      reflections.add(
          "Your spending is slightly higher than your usual ${DateFormat('EEEE').format(now)}.");
    } else if (todayTotal < average * 0.5 && todayTotal > 0) {
      reflections.add(
          "You're spending less than your usual ${DateFormat('EEEE').format(now)} baseline.");
    }

    return reflections;
  }

  Map<String, dynamic> _getCooldowns() {
    final jsonStr = _prefs.getString(_cooldownsKey);
    if (jsonStr == null) return {};
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return {};
    }
  }
}
