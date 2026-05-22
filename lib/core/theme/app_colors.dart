import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F0C29);
  static const Color primaryNeon = Color(0xFF00F2FE);
  static const Color secondaryNeon = Color(0xFF4FACFE);
  static const Color accentPurple = Color(0xFF9D50BB);
  static const Color accentPink = Color(0xFF6E48AA);
  
  static const Color glassBase = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNeon, secondaryNeon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
