import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/battle_provider.dart';
import '../../../core/providers/student_provider.dart';
import '../../cognitive_battle/screens/battle_match_screen.dart';

class TeamBattleLobbyScreen extends StatefulWidget {
  const TeamBattleLobbyScreen({super.key});

  @override
  State<TeamBattleLobbyScreen> createState() => _TeamBattleLobbyScreenState();
}

class _TeamBattleLobbyScreenState extends State<TeamBattleLobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<BattleProvider>(context, listen: false);
      final studentProv = Provider.of<StudentProvider>(context, listen: false);
      prov.createRoom('GENERAL', studentProv.studentProfile?['uid'] ?? 'u1', studentProv.studentProfile?['fullName'] ?? 'Player 1', mode: '2v2');
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<BattleProvider>(context);
    final room = prov.activeRoom;

    if (room == null || prov.isSearching) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Pulse(infinite: true, child: const Icon(Icons.group_add, color: Colors.blueAccent, size: 80))),
      );
    }

    if (room['status'] == 'countdown' || room['status'] == 'active') {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BattleMatchScreen()));
       });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("2v2 TEAM LOBBY"), backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SQUAD MATCHMAKING", style: TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerSlot(room['player1'], Colors.blue),
                _buildPlayerSlot(room['player2'], Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            const Text("VS", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerSlot(room['player3'], Colors.red),
                _buildPlayerSlot(room['player4'], Colors.red),
              ],
            ),
            const SizedBox(height: 40),
            Pulse(infinite: true, child: const Text("Searching for operatives...", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSlot(Map<String, dynamic>? player, Color teamColor) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: teamColor.withValues(alpha: 0.1),
        border: Border.all(color: player != null ? teamColor : Colors.white24, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: player != null ? teamColor : Colors.white24, size: 40),
            const SizedBox(height: 10),
            Text(player != null ? player['name'] : "Waiting...", style: TextStyle(color: player != null ? Colors.white : Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
