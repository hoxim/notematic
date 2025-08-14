import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final ThemeData appLightTheme = ThemeData.light().copyWith(
  // Use Lato font family
  textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),

  // Main color palette for light mode
  colorScheme: ColorScheme.light(
    primary: kPink, // Main accent color (buttons, highlights)
    secondary: kPink, // Secondary accent color
    surface: kVeryLightGray, // Background for cards, sheets, dialogs
    onPrimary: kWhite, // Text/icons on primary color
    onSecondary: kWhite, // Text/icons on secondary color
    onSurface: kBlack, // Text/icons on background
    outline: kBlack.withValues(alpha: 0.26), // Borders, outlines
  ),
  // Card widget background and shape
  cardTheme: CardThemeData(
    color: kVeryLightGray, // Card background color
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16))),
    elevation: 4,
  ),
  // AppBar background color
  appBarTheme: AppBarTheme(
    backgroundColor: kVeryLightGray, // AppBar background
    elevation: 0,
  ),
  // Drawer background color
  drawerTheme: DrawerThemeData(
    backgroundColor: kVeryLightGray, // Drawer background
  ),
  // Scaffold background color (main app background)
  scaffoldBackgroundColor: kPink,
  // ElevatedButton default style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPink, // Button background
      foregroundColor: kWhite, // Button text/icon color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  // Input fields (TextField, etc.)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kVeryLightGray, // Input background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(color: kBlack), // Label text color
    hintStyle:
        TextStyle(color: kBlack.withValues(alpha: 0.54)), // Hint text color
  ),
);
