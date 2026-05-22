import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/widgets/glass_container.dart';

class NeuralMemoryGraph extends StatelessWidget {
  const NeuralMemoryGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: AppColors.accentPink),
                const SizedBox(width: 10),
                const Text(
                  'NEURAL MEMORY GRAPH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Retention Curve',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() == 0) return const Text('Day 1', style: TextStyle(color: Colors.white54, fontSize: 10));
                          if (value.toInt() == 3) return const Text('Day 3', style: TextStyle(color: Colors.white54, fontSize: 10));
                          if (value.toInt() == 5) return const Text('Day 5', style: TextStyle(color: Colors.white54, fontSize: 10));
                          if (value.toInt() == 7) return const Text('Day 7', style: TextStyle(color: Colors.white54, fontSize: 10));
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 7,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    // Forgetting curve without revision (simulated)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 60),
                        FlSpot(2, 40),
                        FlSpot(3, 25),
                        FlSpot(5, 15),
                        FlSpot(7, 10),
                      ],
                      isCurved: true,
                      color: Colors.redAccent.withValues(alpha: 0.5),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dashArray: [5, 5],
                      dotData: const FlDotData(show: false),
                    ),
                    // Curve with AI Revision
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 60),
                        FlSpot(1.5, 100), // AI Revision happened here
                        FlSpot(3, 85),
                        FlSpot(4, 100), // AI Revision
                        FlSpot(5, 92),
                        FlSpot(7, 88),
                      ],
                      isCurved: true,
                      color: AppColors.primaryNeon,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (spot.y == 100 && spot.x > 0) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppColors.accentPink,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          }
                          return FlDotCirclePainter(radius: 0, color: Colors.transparent);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryNeon.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Actual Retention', AppColors.primaryNeon),
                const SizedBox(width: 16),
                _buildLegendItem('Expected Decay', Colors.redAccent.withValues(alpha: 0.5), isDashed: true),
                const SizedBox(width: 16),
                _buildLegendItem('AI Revision Point', AppColors.accentPink, isCircle: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false, bool isCircle = false}) {
    return Row(
      children: [
        if (isCircle)
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
        else if (isDashed)
          Text('- - -', style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 2))
        else
          Container(width: 12, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
