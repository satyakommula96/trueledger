// import 'package:flutter/material.dart'; // Removed

enum InsightType { warning, success, info, prediction }

enum InsightPriority { high, medium, low }

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
  final String value;
  final num? currencyValue;
  final double confidence;
  final InsightGroup group;

  AIInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.value,
    this.currencyValue,
    this.confidence = 0.85,
    required this.group,
  });
}
