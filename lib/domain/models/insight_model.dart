/// Insight display types
enum InsightType { warning, success, info, prediction }

/// Insight Priority with STRICT enforcement rules.
enum InsightPriority {
  high, // Critical: Can interrupt attention (max 1)
  medium, // Normal: Passive display (max 2)
  low // Passive: User-initiated exploration only (never auto-shown)
}

/// Surface where insights are displayed
enum InsightSurface { main, details }

/// Insight grouping for cooldown management
enum InsightGroup {
  trend,
  behavioral,
  critical,
}

class AIInsight {
  final String id;
  final String title;
  final String body;
  final InsightType type;
  final InsightPriority priority;
  final InsightSurface surface;
  final String value;
  final num? currencyValue;
  final double confidence;
  final InsightGroup group;
  final Duration cooldown;
  final DateTime? lastShownAt;

  /// Priority weights for explicit ordering (DO NOT use enum.index)
  static const Map<InsightPriority, int> priorityWeights = {
    InsightPriority.high: 100,
    InsightPriority.medium: 50,
    InsightPriority.low: 10,
  };

  AIInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.surface = InsightSurface.main,
    required this.value,
    this.currencyValue,
    this.confidence = 0.85,
    required this.group,
    this.cooldown = const Duration(days: 7),
    this.lastShownAt,
  });

  AIInsight withLastShownAt(DateTime? timestamp) {
    return AIInsight(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      surface: surface,
      value: value,
      currencyValue: currencyValue,
      confidence: confidence,
      group: group,
      cooldown: cooldown,
      lastShownAt: timestamp,
    );
  }
}
