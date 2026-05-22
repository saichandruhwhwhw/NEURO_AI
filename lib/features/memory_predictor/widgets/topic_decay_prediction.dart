import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/glass_container.dart';

class TopicDecayPrediction extends StatelessWidget {
  const TopicDecayPrediction({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final topics = studentProvider.memoryTopics;

    // Sort topics by retention ascending (lowest retention = highest decay first)
    final sortedTopics = List<Map<String, dynamic>>.from(topics);
    sortedTopics.sort((a, b) {
      double retA = a['retentionPercent']?.toDouble() ?? 100.0;
      double retB = b['retentionPercent']?.toDouble() ?? 100.0;
      return retA.compareTo(retB);
    });

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'TOPIC DECAY WARNING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI PREDICTION',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (sortedTopics.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No decay telemetry recorded.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTopics.length > 3 ? 3 : sortedTopics.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 30),
                itemBuilder: (context, index) {
                  final t = sortedTopics[index];
                  final String topicName = t['topic'] ?? 'Concept';
                  final double retention = t['retentionPercent']?.toDouble() ?? 80.0;
                  final double urgency = (100.0 - retention) / 100.0;

                  Color urgencyColor = Colors.greenAccent;
                  String timeframe = 'stable';
                  if (urgency > 0.4) {
                    urgencyColor = Colors.redAccent;
                    timeframe = 'within 24 hours';
                  } else if (urgency > 0.2) {
                    urgencyColor = Colors.orangeAccent;
                    timeframe = 'within 3 days';
                  } else {
                    urgencyColor = Colors.yellowAccent;
                    timeframe = 'within 1 week';
                  }

                  return _buildDecayItem(
                    topic: topicName,
                    timeframe: timeframe,
                    urgency: urgency,
                    color: urgencyColor,
                    icon: Icons.psychology_alt,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecayItem({
    required String topic,
    required String timeframe,
    required double urgency,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You may forget $topic $timeframe.',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: urgency,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 6)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(urgency * 100).toInt()}% risk',
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
