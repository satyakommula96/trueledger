class QuickAddPreset {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String? note;
  final String? paymentMethod;

  QuickAddPreset({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.note,
    this.paymentMethod,
  });
}

class PersonalizationSettings {
  final bool personalizationEnabled;
  final bool rememberLastUsed;
  final bool timeOfDaySuggestions;
  final bool shortcutSuggestions;
  final bool baselineReflections;
  final String? preferredReminderTime; // Format: "HH:mm" or null
  final int? payDay; // 1-31 or null

  PersonalizationSettings({
    this.personalizationEnabled = true,
    this.rememberLastUsed = true,
    this.timeOfDaySuggestions = true,
    this.shortcutSuggestions = true,
    this.baselineReflections = true,
    this.preferredReminderTime,
    this.payDay,
  });

  PersonalizationSettings copyWith({
    bool? personalizationEnabled,
    bool? rememberLastUsed,
    bool? timeOfDaySuggestions,
    bool? shortcutSuggestions,
    bool? baselineReflections,
    String? preferredReminderTime,
    int? payDay,
  }) {
    return PersonalizationSettings(
      personalizationEnabled:
          personalizationEnabled ?? this.personalizationEnabled,
      rememberLastUsed: rememberLastUsed ?? this.rememberLastUsed,
      timeOfDaySuggestions: timeOfDaySuggestions ?? this.timeOfDaySuggestions,
      shortcutSuggestions: shortcutSuggestions ?? this.shortcutSuggestions,
      baselineReflections: baselineReflections ?? this.baselineReflections,
      preferredReminderTime:
          preferredReminderTime ?? this.preferredReminderTime,
      payDay: payDay ?? this.payDay,
    );
  }
}

class PersonalizationSignal {
  final String key;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic> meta;

  PersonalizationSignal({
    required this.key,
    required this.reason,
    required this.timestamp,
    this.meta = const {},
  });
}
