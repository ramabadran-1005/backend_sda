// lib/core/theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryGreen = Color(0xFF184D19);
const Color accentYellow = Color(0xFFFFC107);
const Color lightBackground = Color(0xFFF8F8F8);
const Color dangerRed = Colors.redAccent;


ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: primaryGreen),
      titleTextStyle: TextStyle(
        color: primaryGreen,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
    ),
  );
}

/* -------------------- ICON SIZES -------------------- */

const double sidebarIconSize = 20;
const double dashboardStatIconSize = 40;

/* -------------------- STANDARD TEXT STYLES -------------------- */

TextStyle titleStyle =
    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen);

TextStyle subtitleStyle =
    const TextStyle(fontSize: 14, color: Colors.black54);

TextStyle dangerText = const TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: dangerRed,
);
