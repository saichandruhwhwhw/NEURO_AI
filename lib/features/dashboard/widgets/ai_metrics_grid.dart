import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import 'glass_container.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

class AiMetricsGrid extends StatelessWidget {
  const AiMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final profile = studentProvider.studentProfile;

    // Pull values from Provider
    double cognitiveScore = profile?['cognitiveScore']?.toDouble() ?? 94.2;
    double focusLevel = profile?['focusLevel']?.toDouble() ?? 88.0;
    double attendanceRate = profile?['attendanceRate']?.toDouble() ?? 95.0;
    int learningStreak = profile?['learningStreak']?.toInt() ?? 14;
    int cognitiveRank = profile?['cognitiveRank']?.toInt() ?? 3;
    double currentCgpa = profile?['cgpa']?.toDouble() ?? 9.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        int crossAxisCount = width > 800 ? 3 : (width > 500 ? 2 : 1);
        double spacing = 16.0;
        double cardWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(width: cardWidth, height: 260, child: _buildCognitiveScore(cognitiveScore)),
            SizedBox(width: cardWidth, height: 260, child: _buildAcademicPerformance(currentCgpa, studentProvider.cognitiveHistory)),
            SizedBox(width: cardWidth, height: 260, child: _buildFocusLevel(focusLevel)),
            SizedBox(width: cardWidth, height: 260, child: _buildAttendance(attendanceRate)),
            SizedBox(width: cardWidth, height: 260, child: _buildLearningStreak(learningStreak)),
            SizedBox(width: cardWidth, height: 260, child: _buildAiRank(cognitiveRank)),
          ],
        );
      },
    );
  }

  Widget _buildCognitiveScore(double score) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'COGNITIVE SCORE',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: score / 100.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: AppColors.primaryNeon.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primaryNeon),
                      );
                    },
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeon.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: AppColors.primaryNeon, blurRadius: 10)],
                      ),
                    ),
                    const Text('INTEL', style: TextStyle(color: AppColors.primaryNeon, fontSize: 10)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Text(
              'Live Feed Sync',
              style: TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicPerformance(double currentCgpa, List<Map<String, dynamic>> history) {
    List<FlSpot> spots = [];
    if (history.isNotEmpty) {
      for (int i = 0; i < history.length; i++) {
        double val = history[i]['score']?.toDouble() ?? 80.0;
        spots.add(FlSpot(i.toDouble(), val / 10.0)); // Map to 0-10 scale
      }
    } else {
      spots = const [
        FlSpot(0, 7),
        FlSpot(1, 7.5),
        FlSpot(2, 7.2),
        FlSpot(3, 8.1),
        FlSpot(4, 8.5),
        FlSpot(5, 8.8),
        FlSpot(6, 9.2),
      ];
    }

    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACADEMIC TREND',
                  style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
                ),
                Icon(Icons.trending_up, color: AppColors.accentPurple.withValues(alpha: 0.8), size: 18),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.accentPurple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accentPurple.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current CGPA: ${currentCgpa.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusLevel(double focus) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FOCUS LEVEL',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
            ),
            const Spacer(),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: focus / 100.0),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 160,
                      child: CustomPaint(
                        painter: ArcPainter(
                          progress: value,
                          color: AppColors.secondaryNeon,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryNeon,
                          shadows: [Shadow(color: AppColors.secondaryNeon, blurRadius: 10)],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            const Text('Optimal Concentration', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendance(double attendance) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ATTENDANCE',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: attendance / 100.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${attendance.toInt()}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.greenAccent, blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Text('Safe Zone', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStreak(int streak) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LEARNING STREAK',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
            ),
            const Spacer(),
            Pulse(
              infinite: true,
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.orangeAccent,
                size: 64,
                shadows: [Shadow(color: Colors.deepOrange, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$streak DAYS',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
                shadows: [Shadow(color: Colors.deepOrange, blurRadius: 10)],
              ),
            ),
            const Spacer(),
            const Text('On Fire!', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRank(int rank) {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'COGNITIVE RANK',
              style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 2),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.hexagon_outlined,
                  color: AppColors.primaryNeon,
                  size: 100,
                ),
                Icon(
                  Icons.hexagon,
                  color: AppColors.primaryNeon.withValues(alpha: 0.2),
                  size: 100,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$rank',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: AppColors.primaryNeon, blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Text('Top 5% in Department', style: TextStyle(color: AppColors.primaryNeon, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
