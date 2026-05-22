import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import 'student_registration_screen.dart';
import 'faculty_registration_screen.dart';
import 'admin_registration_screen.dart';
import '../../dashboard/widgets/glass_container.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1B0B2E), AppColors.background],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  FadeInDown(
                    child: Column(
                      children: [
                        Pulse(
                          infinite: true,
                          child: const Icon(Icons.hub, color: AppColors.primaryNeon, size: 64),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'NEUROLEARN AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'SELECT YOUR NEURAL PATHWAY',
                          style: TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 800;
                      if (isWide) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: _buildRoleCard(context, 'STUDENT', Icons.psychology, AppColors.primaryNeon, 'Create Neural ID', const StudentRegistrationScreen())),
                            const SizedBox(width: 24),
                            Expanded(child: _buildRoleCard(context, 'FACULTY', Icons.supervised_user_circle, AppColors.accentPurple, 'Setup Academic Nexus', const FacultyRegistrationScreen())),
                            const SizedBox(width: 24),
                            Expanded(child: _buildRoleCard(context, 'ADMIN', Icons.admin_panel_settings, Colors.redAccent, 'Initialize Command Core', const AdminRegistrationScreen())),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildRoleCard(context, 'STUDENT', Icons.psychology, AppColors.primaryNeon, 'Create Neural ID', const StudentRegistrationScreen()),
                          const SizedBox(height: 24),
                          _buildRoleCard(context, 'FACULTY', Icons.supervised_user_circle, AppColors.accentPurple, 'Setup Academic Nexus', const FacultyRegistrationScreen()),
                          const SizedBox(height: 24),
                          _buildRoleCard(context, 'ADMIN', Icons.admin_panel_settings, Colors.redAccent, 'Initialize Command Core', const AdminRegistrationScreen()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, IconData icon, Color color, String subtitle, Widget targetScreen) {
    return FadeInUp(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        },
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: color, fontSize: 12, letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
