import 'package:flutter/material.dart';

import 'app_dimens.dart';

// Definisi tema aplikasi Shoope (Material 3) dengan ukuran visual konsisten
class AppTheme {
  // Warna utama oranye Shopee
  static const Color primaryColor = Color(0xFFEE4D2D);
  // Warna latar belakang abu muda
  static const Color scaffoldBackgroundColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,

      // Default IconTheme
      iconTheme: const IconThemeData(size: AppDimens.iconLg),

      // Tema AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: AppDimens.iconLg),
        actionsIconTheme: IconThemeData(size: AppDimens.iconLg),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: AppDimens.fontHeader,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tema BottomNavigationBar
      // Tema BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xFF757575),
        selectedLabelStyle: TextStyle(fontSize: AppDimens.fontCaption),
        unselectedLabelStyle: TextStyle(fontSize: AppDimens.fontCaption),
        elevation: 8,
        selectedIconTheme: IconThemeData(size: AppDimens.iconLg),
        unselectedIconTheme: IconThemeData(size: AppDimens.iconLg),
      ),

      // Tema Card
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),

      // Tema Divider
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 0.5,
        color: Color(0xFFE0E0E0),
      ),

      // Tema ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.space12,
            horizontal: AppDimens.space16,
          ),
          textStyle: const TextStyle(
            fontSize: AppDimens.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.space12,
            horizontal: AppDimens.space16,
          ),
          textStyle: const TextStyle(
            fontSize: AppDimens.fontTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimens.fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Tema InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(AppDimens.space12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: AppDimens.fontBody,
        ),
      ),

      // Tema Teks
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: AppDimens.fontBody),
        titleMedium: TextStyle(
          fontSize: AppDimens.fontTitle,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(fontSize: AppDimens.fontCaption),
      ),
    );
  }
}
