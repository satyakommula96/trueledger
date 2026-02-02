/// Insight display types
enum InsightType { warning, success, info, prediction }

/// Insight Priority with STRICT enforcement rules.
///
/// **DISPLAY POLICY (ENFORCED IN IntelligenceService._applyPriorityLogic):**
/// - `high`: EXACTLY 1 shown if any exist. Interrupts user attention.
/// - `medium`: Max 2 shown only if NO high exists. Passive display.
/// - `low`: NEVER auto-shown on main surface. User-initiated only (details tab).
///
/// **CRITICAL RULE:** Low priority insights are FILTERED OUT by InsightSurface.main.
/// If you see a `low` insight on the dashboard, the system is broken.
///
/// **DO NOT** rely on enum index for ordering. Use explicit weight map if needed.
enum InsightPriority {
  high, // Critical: Can interrupt attention (max 1)
  medium, // Normal: Passive display (max 2)
  low // Passive: User-initiated exploration only (never auto-shown)
}

/// Surface where insights are displayed
/// - `main`: Dashboard (filters out low priority)
/// - `details`: Insights detail screen (shows all priorities)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'priority': priority.name,
        'surface': surface.name,
        'value': value,
        'currencyValue': currencyValue,
        'confidence': confidence,
        'group': group.name,
        'cooldown_ms': cooldown.inMilliseconds,
        'lastShownAt': lastShownAt?.toIso8601String(),
      };

  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: InsightType.values.byName(json['type']),
        priority: InsightPriority.values.byName(json['priority']),
        surface: InsightSurface.values.byName(json['surface'] ?? 'main'),
        value: json['value'],
        currencyValue: json['currencyValue'],
        confidence: json['confidence'],
        group: InsightGroup.values.byName(json['group']),
        cooldown: Duration(milliseconds: json['cooldown_ms'] ?? 604800000),
        lastShownAt: json['lastShownAt'] != null
            ? DateTime.parse(json['lastShownAt'])
            : null,
      );

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
