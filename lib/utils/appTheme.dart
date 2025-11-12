import 'package:flutter/material.dart';
import 'color.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  primaryColor: AppColors.principal,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0, // 🔹 remove sombra
    iconTheme: IconThemeData(color: Colors.grey),
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.laranja,
      foregroundColor: Colors.white,
      minimumSize: const Size(200, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
  ),
);
