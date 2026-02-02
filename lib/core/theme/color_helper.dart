import 'package:flutter/material.dart';
import 'package:trueledger/core/utils/hash_utils.dart';

class ColorHelper {
  static const List<Color> palette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFD946EF), // Fuchsia
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
  ];

  static Color getColorForName(String name) {
    if (name.isEmpty) return palette[0];
    final hash = generateStableHash(name);
    return palette[hash % palette.length];
  }
}
