import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:ui';

class FuturisticBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FuturisticBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FuturisticBottomNav> createState() => _FuturisticBottomNavState();
}

class _FuturisticBottomNavState extends State<FuturisticBottomNav> {
  final List<IconData> _icons = [
    Icons.psychology, // Cognitive Analytics
    Icons.auto_graph_rounded, // Performance Insights
    Icons.lightbulb, // AI Recommendation
    Icons.settings_suggest, // AI Settings
  ];

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNeon.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _icons.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNeon.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryNeon.withValues(alpha: 0.5),
                    blurRadius: 15,
                  )
                ]
              : [],
        ),
        child: Icon(
          _icons[index],
          color: isSelected ? AppColors.primaryNeon : Colors.white54,
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }
}
