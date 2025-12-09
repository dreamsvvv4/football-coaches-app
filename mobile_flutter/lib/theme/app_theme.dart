import 'package:flutter/material.dart';

/// 🎨 **ADVANCED DESIGN SYSTEM - Premium Sports App**
/// Inspired by OneFootball, FIFA, NBA apps with modern branding
class AppTheme {
  // ========== BRAND COLORS ==========
  static const primaryGreen = Color(0xFF0E7C61);
  static const secondaryTeal = Color(0xFF14B8A6);
  static const accentOrange = Color(0xFFFF6B00);
  static const accentBlue = Color(0xFF0066CC);
  
  // ========== SEMANTIC COLORS ==========
  static const success = Color(0xFF2F9F85);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFD64550);
  static const info = Color(0xFF3B82F6);
  
  // ========== NEUTRAL PALETTE ==========
  static const surface = Color(0xFFF2F5F9);
  static const surfaceLight = Color(0xFFFAFBFC);
  static const surfaceDark = Color(0xFFE5E9F0);
  
  static const textPrimary = Color(0xFF102A43);
  static const textSecondary = Color(0xFF486581);
  static const textTertiary = Color(0xFF829AB1);
  
  // ========== DARK MODE COLORS ==========
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  
  // ========== GRADIENTS ==========
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E7C61), Color(0xFF14B8A6)],
  );
  
  static const accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B00), Color(0xFFFF8E42)],
  );
  
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E7C61), Color(0xFF14B8A6), Color(0xFF0066CC)],
  );
  
  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  // ========== TYPOGRAPHY ==========
  static const fontFamily = 'Inter'; // Modern, readable font
  
  static TextTheme buildTextTheme(Color primaryColor) {
    return TextTheme(
      // Display styles - Large hero text
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: primaryColor,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: primaryColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.2,
      ),
      
      // Headline styles - Section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      
      // Title styles - Cards, list items
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.1,
      ),
      
      // Body styles - Paragraph text
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      
      // Label styles - Buttons, chips
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ========== SPACING SYSTEM ==========
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;
  static const double space3xl = 48.0;
  static const double space4xl = 64.0;

  // ========== RADIUS ==========
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 32.0;

  // ========== ELEVATION (Shadows) ==========
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.16),
      blurRadius: 30,
      offset: const Offset(0, 20),
    ),
  ];
  
  static List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.3),
      blurRadius: 40,
      spreadRadius: -5,
      offset: const Offset(0, 10),
    ),
  ];

  // ========== LIGHT THEME ==========
  static ThemeData lightTheme() {
    final textTheme = buildTextTheme(textPrimary);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryTeal,
        tertiary: accentOrange,
        error: error,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      fontFamily: fontFamily,
      
      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 24),
      ),
      
      // ========== CARDS ==========
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // ========== CHIPS ==========
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE0ECF8),
        selectedColor: primaryGreen.withValues(alpha: 0.18),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      
      // ========== INPUT FIELDS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: primaryGreen.withValues(alpha: 0.5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: error.withValues(alpha: 0.5), width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary.withValues(alpha: 0.7),
        ),
      ),
      
      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      
      // ========== NAVIGATION BAR ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryGreen.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen, size: 24);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      
      // ========== ELEVATED BUTTON ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryGreen.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== OUTLINED BUTTON ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: BorderSide(color: primaryGreen.withValues(alpha: 0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== TEXT BUTTON ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== DIALOG ==========
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
      ),
      
      // ========== BOTTOM SHEET ==========
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius2xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      dividerColor: Colors.black.withValues(alpha: 0.06),
    );
  }

  // ========== DARK THEME ==========
  static ThemeData darkTheme() {
    final textTheme = buildTextTheme(darkTextPrimary);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondaryTeal,
        brightness: Brightness.dark,
        primary: secondaryTeal,
        secondary: primaryGreen,
        tertiary: accentOrange,
        error: error,
        surface: darkSurface,
        onPrimary: darkBackground,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      fontFamily: fontFamily,
      
      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: darkTextPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
      ),
      
      // ========== CARDS ==========
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: darkSurfaceVariant.withValues(alpha: 0.5), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // ========== CHIPS ==========
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: secondaryTeal.withValues(alpha: 0.24),
        labelStyle: textTheme.labelMedium?.copyWith(color: darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      
      // ========== INPUT FIELDS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: darkSurfaceVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: darkSurfaceVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: secondaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: darkTextSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: darkTextSecondary.withValues(alpha: 0.7),
        ),
      ),
      
      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryTeal,
        foregroundColor: darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      
      // ========== NAVIGATION BAR ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: secondaryTeal.withValues(alpha: 0.24),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: secondaryTeal, size: 24);
          }
          return IconThemeData(color: darkTextSecondary, size: 24);
        }),
      ),
      
      // ========== ELEVATED BUTTON ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryTeal,
          foregroundColor: darkBackground,
          elevation: 0,
          shadowColor: secondaryTeal.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== OUTLINED BUTTON ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryTeal,
          side: BorderSide(color: secondaryTeal.withValues(alpha: 0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== TEXT BUTTON ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // ========== DIALOG ==========
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
      ),
      
      // ========== BOTTOM SHEET ==========
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius2xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      dividerColor: darkSurfaceVariant.withValues(alpha: 0.5),
    );
  }
}
