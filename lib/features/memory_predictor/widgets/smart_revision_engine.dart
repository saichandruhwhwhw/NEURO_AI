import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../dashboard/widgets/glass_container.dart';

class SmartRevisionEngine extends StatefulWidget {
  const SmartRevisionEngine({super.key});

  @override
  State<SmartRevisionEngine> createState() => _SmartRevisionEngineState();
}

class _SmartRevisionEngineState extends State<SmartRevisionEngine> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final topics = studentProvider.memoryTopics;

    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pulse(
                  infinite: true,
                  child: const Icon(Icons.bolt, color: AppColors.primaryNeon),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'SMART REVISION ENGINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (topics.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No study topics tracked yet.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final t = topics[index];
                  final String docId = t['docId'] ?? '';
                  final String topicName = t['topic'] ?? 'Unknown Topic';
                  final int count = t['revisionCount'] ?? 0;
                  final double retention = t['retentionPercent']?.toDouble() ?? 80.0;

                  Color itemColor = AppColors.primaryNeon;
                  if (retention < 60.0) {
                    itemColor = Colors.redAccent;
                  } else if (retention < 80.0) {
                    itemColor = Colors.orangeAccent;
                  }

                  return _buildEngineTask(
                    title: topicName,
                    subtitle: "Revision count: $count. Retention level: ${retention.toInt()}%",
                    icon: Icons.menu_book,
                    color: itemColor,
                    actionLabel: 'REVISE',
                    onTap: () {
                      if (docId.isNotEmpty) {
                        studentProvider.reviseTopic(docId);
                      }
                    },
                  );
                },
              ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            const Text(
              "TRACK NEW TOPIC",
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _topicController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter topic name...",
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryNeon),
                    onPressed: () {
                      final name = _topicController.text.trim();
                      if (name.isNotEmpty) {
                        studentProvider.addTopic(name);
                        _topicController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineTask({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: color.withValues(alpha: 0.2),
      highlightColor: color.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
