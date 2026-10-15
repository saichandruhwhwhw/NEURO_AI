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
    final placementData = studentProvider.placementData;
    
    // Compute prediction inputs
    List<double> cgpaHistory = [];
    List<double> attendanceHistory = [];
    if (studentProvider.cognitiveHistory.isNotEmpty) {
      for (var doc in studentProvider.cognitiveHistory) {
        double score = doc['score']?.toDouble() ?? 80.0;
        double att = doc['attendanceVal']?.toDouble() ?? 95.0;
        cgpaHistory.add(score / 10.0);
        attendanceHistory.add(att);
      }
    } else {
      cgpaHistory = [8.5, 8.8, 9.0, 9.2];
      attendanceHistory = [90, 92, 94, 95];
    }
    
    var predictionResult = AIEngine.predictAcademicTrend(
      cgpaHistory: cgpaHistory,
      attendanceHistory: attendanceHistory,
    );
    
    double projCgpa = predictionResult['projectedCGPA'] ?? 9.4;
    String trajectory = predictionResult['trajectory'] ?? 'High';
    double placeProb = (placementData['placementProbability']?.toDouble() ?? 0.88) * 100.0;
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
                        Expanded(child: _buildMainPrediction(projCgpa, profile)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildSecondaryPredictions(placeProb, trajectory)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMainPrediction(projCgpa, profile),
                        const SizedBox(height: 24),
                        _buildSecondaryPredictions(placeProb, trajectory),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPrediction(double projCgpa, Map<String, dynamic>? profile) {
    double currentCgpa = profile?['cgpa']?.toDouble() ?? 9.2;
    double focusLevel = profile?['focusLevel']?.toDouble() ?? 88.0;
    
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
                    RadarEntry(value: currentCgpa / 2.0),
                    const RadarEntry(value: 4.2),
                    const RadarEntry(value: 4.0),
                    RadarEntry(value: focusLevel / 20.0),
                    const RadarEntry(value: 4.5),
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
            'Predicted CGPA: ${projCgpa.toStringAsFixed(2)}',
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

  Widget _buildSecondaryPredictions(double placeProb, String trajectory) {
    return Column(
      children: [
        _buildPredictionCard(
          icon: Icons.work,
          title: 'Placement Readiness',
          value: '${placeProb.toInt()}%',
          color: Colors.greenAccent,
          warning: null,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          icon: Icons.trending_up,
          title: 'Success Trajectory',
          value: trajectory,
          color: AppColors.secondaryNeon,
          warning: null,
        ),
        const SizedBox(height: 12),
        _buildPredictionCard(
          icon: Icons.warning_amber_rounded,
          title: 'Weak Subject Warning',
          value: 'Math (Calculus)',
          color: Colors.redAccent,
          warning: 'Action required to maintain CGPA',
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
