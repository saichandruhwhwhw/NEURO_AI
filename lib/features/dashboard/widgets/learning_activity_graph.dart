import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import 'glass_container.dart';
import 'package:fl_chart/fl_chart.dart';

class LearningActivityGraph extends StatelessWidget {
  const LearningActivityGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final burnoutData = studentProvider.burnoutData;
    
    double todayHours = (burnoutData['studyDurationMinutes']?.toDouble() ?? 240.0) / 60.0;
    double productivity = burnoutData['productivityScore']?.toDouble() ?? 85.0;
    
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                const Text(
                  'LEARNING ACTIVITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: 'This Week',
                  dropdownColor: AppColors.background,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                  items: ['This Week', 'Last Week', 'This Month'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.background.withValues(alpha: 0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.round()} hrs',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 == 0) {
                            return Text(
                              '${value.toInt()}h',
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarData(0, 4, isToday: false),
                    _buildBarData(1, 6, isToday: false),
                    _buildBarData(2, 5, isToday: false),
                    _buildBarData(3, todayHours > 0 ? todayHours : 8, isToday: true),
                    _buildBarData(4, 3, isToday: false),
                    _buildBarData(5, 7, isToday: false),
                    _buildBarData(6, 2, isToday: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryStat('Today Hours', '${todayHours.toStringAsFixed(1)}h', Colors.orangeAccent),
                _buildSummaryStat('Productivity', '${productivity.toInt()}%', AppColors.primaryNeon),
                _buildSummaryStat('Quizzes', '12', AppColors.accentPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarData(int x, double y, {bool isToday = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          gradient: LinearGradient(
            colors: isToday
                ? [AppColors.primaryNeon, AppColors.secondaryNeon]
                : [AppColors.accentPurple.withValues(alpha: 0.5), AppColors.accentPink.withValues(alpha: 0.5)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 5)],
          ),
        ),
      ],
    );
  }
}
