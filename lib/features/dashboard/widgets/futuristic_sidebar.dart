import 'package:flutter/material.dart';
import 'glass_container.dart';
import '../../../core/theme/app_colors.dart';

class FuturisticSidebar extends StatelessWidget {
  const FuturisticSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 80,
      height: double.infinity,
      borderRadius: 0,
      blur: 20,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _SidebarIcon(icon: Icons.auto_awesome, color: AppColors.primaryNeon, isActive: true),
          const SizedBox(height: 30),
          _SidebarIcon(icon: Icons.dashboard_rounded, color: Colors.white70),
          _SidebarIcon(icon: Icons.bar_chart_rounded, color: Colors.white70),
          _SidebarIcon(icon: Icons.psychology_rounded, color: Colors.white70),
          _SidebarIcon(icon: Icons.person_rounded, color: Colors.white70),
          const Spacer(),
          _SidebarIcon(icon: Icons.settings_rounded, color: Colors.white70),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isActive;

  const _SidebarIcon({
    required this.icon,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: isActive
          ? BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? color : color.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }
}
