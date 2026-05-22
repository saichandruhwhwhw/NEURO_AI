import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/services/ai_engine.dart';
import 'glass_container.dart';
import 'package:fl_chart/fl_chart.dart';

class AiPredictionSection extends StatelessWidget {
  const AiPredictionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final profile = studentProvider.studentProfile;
    final currentCGPA = profile?['cgpa']?.toDouble() ?? 9.2;
    final attendanceRate = profile?['attendanceRate']?.toDouble() ?? 95.0;

    List<double> cgpaHistory = studentProvider.cognitiveHistory.map((d) => (d['quizVal']?.toDouble() ?? 90.0) / 10.0).toList();
    List<double> attendanceHistory = studentProvider.cognitiveHistory.map((d) => d['attendanceVal']?.toDouble() ?? 95.0).toList();

    if (cgpaHistory.isEmpty) {
      cgpaHistory = [currentCGPA - 0.2, currentCGPA - 0.1, currentCGPA];
    }
    if (attendanceHistory.isEmpty) {
      attendanceHistory = [attendanceRate - 1.0, attendanceRate - 0.5, attendanceRate];
    }

    final trend = AIEngine.predictAcademicTrend(
      cgpaHistory: cgpaHistory,
      attendanceHistory: attendanceHistory,
    );

    // Calculate Radar values (0-5 scale) based on actual student metrics
    final double cgpaVal = currentCGPA / 2.0; 
    final double placementVal = (studentProvider.placementData['placementProbability']?.toDouble() ?? 0.82) * 5.0;
    
    final skillsList = studentProvider.skillsData['skillsList'] as List<dynamic>? ?? [];
    final missingSkills = studentProvider.skillsData['missingSkills'] as List<dynamic>? ?? [];
    double skillsRatio = 0.8;
    if (skillsList.isNotEmpty || missingSkills.isNotEmpty) {
      final total = skillsList.length + missingSkills.length;
      skillsRatio = total > 0 ? skillsList.length / total : 0.8;
    }
    final double skillsVal = skillsRatio * 5.0;

    final double focusVal = (profile?['focusLevel']?.toDouble() ?? 88.0) / 20.0;
    final double cognitiveVal = (profile?['cognitiveScore']?.toDouble() ?? 94.2) / 20.0;

    final double projectedCgpa = trend['projectedCGPA'] ?? currentCGPA;

    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.online_prediction, color: AppColors.primaryNeon),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI PREDICTIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 500;
                return isWide 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildMainPrediction(cgpaVal, placementVal, skillsVal, focusVal, cognitiveVal, projectedCgpa)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildSecondaryPredictions(studentProvider, trend)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMainPrediction(cgpaVal, placementVal, skillsVal, focusVal, cognitiveVal, projectedCgpa),
                        const SizedBox(height: 24),
                        _buildSecondaryPredictions(studentProvider, trend),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPrediction(double cgpa, double placement, double skills, double focus, double cognitive, double projectedCgpa) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: RadarChart(
            RadarChartData(
              tickCount: 3,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              gridBorderData: const BorderSide(color: Colors.white10),
              radarBorderData: const BorderSide(color: Colors.transparent),
              titlePositionPercentageOffset: 0.2,
              getTitle: (index, angle) {
                const titles = ['CGPA', 'Placements', 'Skills', 'Focus', 'Growth'];
                return RadarChartTitle(
                  text: titles[index],
                  angle: angle,
                  positionPercentageOffset: 0.1,
                );
              },
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.primaryNeon.withValues(alpha: 0.2),
                  borderColor: AppColors.primaryNeon,
                  entryRadius: 3,
                  dataEntries: [
                    RadarEntry(value: cgpa),
                    RadarEntry(value: placement),
                    RadarEntry(value: skills),
                    RadarEntry(value: focus),
                    RadarEntry(value: cognitive),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryNeon.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Predicted CGPA: ${projectedCgpa.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.primaryNeon,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryPredictions(StudentProvider provider, Map<String, dynamic> trend) {
    final placementProb = (provider.placementData['placementProbability']?.toDouble() ?? 0.82) * 100;
    
    // Map trajectory to Success Probability
    String successProb = 'Stable';
    Color successColor = AppColors.secondaryNeon;
    if (trend['trajectory'] == 'Top Tier Growth') {
      successProb = 'High (94%)';
      successColor = Colors.greenAccent;
    } else if (trend['trajectory'] == 'Stable Growth') {
      successProb = 'Good (82%)';
      successColor = AppColors.secondaryNeon;
    } else {
      successProb = 'At-Risk (45%)';
      successColor = Colors.redAccent;
    }

    // Weak subjects warnings
    final missingSkills = provider.skillsData['missingSkills'] as List<dynamic>? ?? [];
    String weakSubject = 'None detected';
    String warningMsg = 'Profile aligns with target role expectations.';
    if (missingSkills.isNotEmpty) {
      weakSubject = missingSkills.first.toString();
      warningMsg = 'Improve skill gap in this area to optimize readiness.';
    }

    return Column(
      children: [
        _buildPredictionCard(
          icon: Icons.work,
          title: 'Placement Readiness',
          value: '${placementProb.toInt()}%',
          color: Colors.greenAccent,
          warning: null,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          icon: Icons.trending_up,
          title: 'Success Probability',
          value: successProb,
          color: successColor,
          warning: null,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          icon: Icons.warning_amber_rounded,
          title: 'Weak Subject Warning',
          value: weakSubject,
          color: missingSkills.isNotEmpty ? Colors.redAccent : Colors.greenAccent,
          warning: warningMsg,
        ),
      ],
    );
  }

  Widget _buildPredictionCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String? warning,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                if (warning != null) ...[
                  const SizedBox(height: 4),
                  Text(warning, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
