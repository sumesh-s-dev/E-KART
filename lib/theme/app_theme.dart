import 'package:flutter/material.dart';

final Color _primaryColor = Color(0xFF2196F3); // Blue accent
final Color _backgroundColor = Color(0xFFF7F9FB); // Soft white
final Color _surfaceColor = Color(0xFFFFFFFF);
final Color _onPrimary = Colors.white;
final Color _onBackground = Color(0xFF222222);
final Color _grey = Color(0xFFB0BEC5);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: _primaryColor,
    onPrimary: _onPrimary,
    secondary: _grey,
    onSecondary: _onBackground,
    error: Colors.redAccent,
    onError: Colors.white,
    background: _backgroundColor,
    onBackground: _onBackground,
    surface: _surfaceColor,
    onSurface: _onBackground,
  ),
  scaffoldBackgroundColor: _backgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: _surfaceColor,
    elevation: 0,
    iconTheme: IconThemeData(color: _onBackground),
    titleTextStyle: TextStyle(
      color: _onBackground,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _primaryColor, width: 2),
    ),
    hintStyle: TextStyle(color: _grey),
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryColor,
      foregroundColor: _onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      padding: EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _primaryColor,
      textStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  cardTheme: CardTheme(
    color: _surfaceColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.all(8),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _surfaceColor,
    selectedItemColor: _primaryColor,
    unselectedItemColor: _grey,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: _primaryColor,
  ),
  fontFamily: 'Roboto',
);
