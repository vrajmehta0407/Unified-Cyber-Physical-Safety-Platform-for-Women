import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ═══════════════════════════════════════════════
  //  LIGHT THEME (Premium, Eye-catching, Modern)
  // ═══════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.lightSurface,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
            titleLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
            bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
            bodySmall: TextStyle(color: AppColors.lightTextHint),
            labelLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.lightBorder),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurfaceAlt,
          hintStyle: GoogleFonts.outfit(color: AppColors.lightTextHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.primary : AppColors.lightTextHint),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.lightBorder),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.lightDivider, thickness: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.lightTextHint,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightCard,
          contentTextStyle: GoogleFonts.outfit(color: AppColors.lightTextPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),
      );

  // ═══════════════════════════════════════════════
  //  DARK THEME (Premium Deep Purple-Navy)
  // ═══════════════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
          onError: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          const TextTheme(
            displayLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
            headlineSmall: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
            titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
            bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
            bodySmall: TextStyle(color: AppColors.darkTextHint),
            labelLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.darkBorder),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          hintStyle: GoogleFonts.outfit(color: AppColors.darkTextHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.primary : AppColors.darkTextSecondary),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.darkBorder),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkCard,
          contentTextStyle: GoogleFonts.outfit(color: AppColors.darkTextPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

