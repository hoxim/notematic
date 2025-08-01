import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appDarkTheme = ThemeData.dark().copyWith(
  // Main color palette for dark mode
  colorScheme: ColorScheme.dark(
    primary: kPink, // Main accent color (buttons, highlights)
    secondary: kPink, // Secondary accent color
    surface: kDarkerGray, // Background for cards, sheets, dialogs
    onPrimary: kWhite, // Text/icons on primary color
    onSecondary: kWhite, // Text/icons on secondary color
    onSurface: kWhite, // Text/icons on surface color
    outline: kWhite.withValues(alpha: 0.24), // Borders, outlines
  ),
  // Card widget background and shape
  cardTheme: CardThemeData(
      color: kDarkGray, // Card background color
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32))),
      elevation: 0,
      margin: EdgeInsets.all(32)),

  // AppBar background color
  appBarTheme: AppBarTheme(
    backgroundColor: kDarkerGray, // AppBar background
    elevation: 0,
  ),
  // Drawer background color
  drawerTheme: DrawerThemeData(
    backgroundColor: kDarkerGray, // Drawer background
  ),
  // Scaffold background color (main app background)
  scaffoldBackgroundColor: kDarkGray,
  // ElevatedButton default style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return kDarkerGray; // Gdy wciśnięty
          }
          return kDarkGray; // Gdy nie wciśnięty
        },
      ),
      foregroundColor: WidgetStateProperty.all(kLightGray),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w200),
      ),
    ),
  ),
  // Input fields (TextField, etc.)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kDarkerGray, // Input background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(color: kWhite), // Label text color
    hintStyle:
        TextStyle(color: kWhite.withValues(alpha: 0.7)), // Hint text color
  ),
);
