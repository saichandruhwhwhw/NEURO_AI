import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/providers/student_provider.dart';

class SmartPlacementInsights extends StatelessWidget {
  const SmartPlacementInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final double placementProb = (provider.placementData['placementProbability']?.toDouble() ?? 0.82) * 100;
        final int aptitudeScore = provider.placementData['aptitudeScore']?.toInt() ?? 85;
        final List<dynamic> missingSkillsRaw = provider.skillsData['missingSkills'] ?? ['Machine Learning Deployment', 'Cloud Architecture', 'Big Data Engineering'];
        final List<String> missingSkills = missingSkillsRaw.map((s) => s.toString()).toList();

        List<Map<String, dynamic>> insights = [];

        if (placementProb >= 80) {
          insights.add({
            'message': "Recruitment outlook is highly favorable. High compatibility indices.",
            'color': Colors.greenAccent,
          });
        } else {
          insights.add({
            'message': "Placement readiness is in optimization phase. Close gaps to elevate match index.",
            'color': Colors.orangeAccent,
          });
        }

        if (missingSkills.isNotEmpty) {
          insights.add({
            'message': "Core skill gap: recommended to acquire ${missingSkills.take(2).join(' & ')}.",
            'color': Colors.redAccent,
          });
        } else {
          insights.add({
            'message': "Neural skill comparison indicates complete target alignment.",
            'color': Colors.cyanAccent,
          });
        }

        if (aptitudeScore >= 80) {
          insights.add({
            'message': "Aptitude performance is strong. Mental agility matches requirements.",
            'color': Colors.purpleAccent,
          });
        } else {
          insights.add({
            'message': "Recommend practicing mental agility modules to boost aptitude rating.",
            'color': Colors.orangeAccent,
          });
        }

        return Column(
          children: insights.asMap().entries.map((entry) {
            int idx = entry.key;
            var data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildInsight(data['message'], data['color'], idx * 150),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInsight(String message, Color color, int delayMs) {
    return FadeInLeft(
      delay: Duration(milliseconds: delayMs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(Icons.insights, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
