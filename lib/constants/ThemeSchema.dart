import 'package:flutter/material.dart';

ThemeData themeSchema = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: Colors.blue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    primary: Colors.blue,
    secondary: Colors.teal,
    background: Colors.white,
    surface: Colors.grey[100]!,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    shadowColor: Colors.transparent,
    elevation: 0.0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 5,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue, textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Colors.grey[300]!,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.blue,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.blue,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black),
    displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black),
  ),
);
