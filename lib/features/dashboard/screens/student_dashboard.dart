import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/futuristic_bottom_nav.dart';
import '../../analytics/screens/cognitive_analytics_screen.dart';
import '../../performance/screens/performance_insights_screen.dart';
import '../../recommendations/screens/ai_recommendation_screen.dart';
import '../../settings/screens/ai_settings_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CognitiveAnalyticsScreen(),
    const PerformanceInsightsScreen(),
    const AiRecommendationScreen(),
    const AiSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background effects
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),
          
          // The views with a simple FadeIndexedStack behavior
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _pages[_currentIndex],
          ),
          
          // Floating Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FuturisticBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
