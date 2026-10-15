import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/providers/battle_provider.dart';
import '../../cognitive_battle/screens/battle_match_screen.dart';

class DepartmentWarScreen extends StatelessWidget {
  const DepartmentWarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProv = Provider.of<StudentProvider>(context);
    final battleProv = Provider.of<BattleProvider>(context);
    String dept = studentProv.studentProfile?['department'] ?? 'IT';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("DEPARTMENT WAR"), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Defend $dept's Honor!", style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                battleProv.createRoom(dept, studentProv.studentProfile?['uid'] ?? 'u1', studentProv.studentProfile?['fullName'] ?? 'Player 1');
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BattleMatchScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              child: const Text("JOIN WARQUEUE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
