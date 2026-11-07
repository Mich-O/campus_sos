import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const ink = Color(0xFF0B1B2B), paper = Color(0xFFF3F5F7), surface = Colors.white;
  static const brand = Color(0xFF0B5D55), brandTint = Color(0xFFDDEBE8), lime = Color(0xFFC8F169);
  static const grey = Color(0xFF5B6B7B), track = Color(0xFFD5DCE3), border = Color(0x1F0B1B2B);
  static const segmentBg = Color(0xFFE3E8EE);
  static const gold = Color(0xFFD6A100), goldTint = Color(0xFFFBF0C2), blue = Color(0xFF2F6FEB);
  static const blueTint = Color(0xFFE1EBFC), green = Color(0xFF3F9B3A), greenTint = Color(0xFFE3F2E1);
  static const error = Color(0xFFB3261E);
}
class AppSpacing { AppSpacing._(); static const screen = 24.0, gap = 12.0, gapSm = 8.0, section = 24.0; }
class AppRadius { AppRadius._(); static const card = 20.0, input = 14.0, hero = 24.0, pill = 28.0, chip = 18.0; }
class AppText {
  AppText._();
  static final h1 = GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w700, height: 1.05, color: AppColors.ink);
  static final h2 = GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink);
  static final title = GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink);
  static final stat = GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink);
  static final body = GoogleFonts.manrope(fontSize: 15, height: 1.4, color: AppColors.ink);
  static final bodyBold = GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink);
  static final secondary = GoogleFonts.manrope(fontSize: 13, color: AppColors.grey);
  static final label = GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink);
  static final button = GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700);
  static final mono = GoogleFonts.dmMono(fontSize: 11, color: AppColors.grey);
}
ThemeData buildTheme() => ThemeData(
  useMaterial3: true, scaffoldBackgroundColor: AppColors.paper,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand).copyWith(primary: AppColors.brand, onPrimary: Colors.white, surface: AppColors.surface, onSurface: AppColors.ink),
  textTheme: TextTheme(bodyMedium: AppText.body, bodyLarge: AppText.body, titleMedium: AppText.title),
  inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    hintStyle: AppText.secondary.copyWith(fontSize: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.input), borderSide: const BorderSide(color: AppColors.brand, width: 1.5))),
);