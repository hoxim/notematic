import 'package:flutter/material.dart';

const noteColors = [
  // Each entry: {'light': Color, 'dark': Color}
  {'light': Color(0xFFFFF59D), 'dark': Color(0xFF7E7E3A)}, // Yellow
  {'light': Color(0xFF90CAF9), 'dark': Color(0xFF274472)}, // Blue
  {'light': Color(0xFFA5D6A7), 'dark': Color(0xFF356859)}, // Green
  {'light': Color(0xFFEF9A9A), 'dark': Color(0xFF7B3B3B)}, // Red
  {'light': Color(0xFFCE93D8), 'dark': Color(0xFF5E366E)}, // Purple
  {'light': Color(0xFFE0E0E0), 'dark': Color(0xFF424242)}, // Grey
];

Color getNotebookColor(int colorIndex, bool isDark) {
  final idx = colorIndex % noteColors.length;
  return isDark ? noteColors[idx]['dark']! : noteColors[idx]['light']!;
}

Color getTextColor(Color bg, bool isDark) {
  // If background is dark, use white; if light, use black
  return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
      ? Colors.white
      : Colors.black;
}
