import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CupertinoColors.systemBackground,
        foregroundColor: CupertinoColors.label,
        elevation: 0,
      ),
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: CupertinoColors.label,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(isLight: true),
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CupertinoColors.systemBlue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        foregroundColor: CupertinoColors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: CupertinoColors.white,
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(isLight: false),
      elevatedButtonTheme: _elevatedButtonTheme,
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isLight}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isLight
          ? CupertinoColors.systemGrey6
          : CupertinoColors.darkBackgroundGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: isLight
            ? BorderSide.none
            : const BorderSide(color: CupertinoColors.systemGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: isLight
            ? BorderSide.none
            : const BorderSide(color: CupertinoColors.systemGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: CupertinoColors.systemBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: CupertinoColors.systemRed,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: CupertinoColors.systemBlue,
      foregroundColor: CupertinoColors.white,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
