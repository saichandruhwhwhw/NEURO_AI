import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryNeon,
      textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
    );
  }
}
