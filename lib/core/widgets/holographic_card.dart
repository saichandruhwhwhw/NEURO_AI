import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';
import '../theme/app_colors.dart'; // Ensure correct path

class HolographicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? glowColor;

  const HolographicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.onTap,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? AppColors.primaryNeon;
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: effectiveGlow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGlow.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: effectiveGlow.withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: content,
    );
  }
}
