import 'package:flutter/material.dart';

ThemeData themeSchema = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    shadowColor: Colors.transparent,
    elevation: 0.0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          elevation: 10,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero
          ),
          textStyle: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold))),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
);