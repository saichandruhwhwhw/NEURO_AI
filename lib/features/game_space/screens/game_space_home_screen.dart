import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/battle_provider.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/widgets/holographic_card.dart';
import '../screens/voice_battle_screen.dart';
import '../screens/team_battle_lobby.dart';
import '../screens/department_war_screen.dart';
import '../screens/store_screen.dart';
import '../screens/achievements_screen.dart';
import '../../cognitive_battle/screens/battle_match_screen.dart';
import '../../cognitive_battle/screens/tournament_bracket_screen.dart';

class GameSpaceHomeScreen extends StatelessWidget {
  const GameSpaceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final battleProv = Provider.of<BattleProvider>(context);
    final studentProv = Provider.of<StudentProvider>(context);
    final studentName = studentProv.studentProfile?['fullName'] ?? "Player 1";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0B24),
        title: const Text(
          "🎮 AI COGNITIVE GAME SPACE",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF190C2C), Colors.black],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Banner
                  FadeInDown(
                    child: _buildProfileBanner(battleProv, studentName),
                  ),
                  const SizedBox(height: 30),

                  // 2. Esports Grid
                  FadeInUp(
                    child: _buildGameGrid(context, battleProv, studentProv),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBanner(BattleProvider prov, String name) {
    String rankName = "Bronze Challenger";
    Color rankColor = Colors.orange.shade700;
    int rp = prov.rankPoints;
    if (rp > 1600) { rankName = "Cognitive Master"; rankColor = Colors.redAccent; }
    else if (rp > 1200) { rankName = "Elite Architect"; rankColor = AppColors.accentPurple; }
    else if (rp > 900) { rankName = "Diamond Operator"; rankColor = AppColors.primaryNeon; }
    else if (rp > 650) { rankName = "Platinum Tactician"; rankColor = Colors.tealAccent.shade400; }
    else if (rp > 400) { rankName = "Gold Strategist"; rankColor = Colors.amber; }
    else if (rp > 200) { rankName = "Silver Specialist"; rankColor = Colors.grey.shade400; }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: rankColor.withValues(alpha: 0.5), width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: rankColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: rankColor.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: rankColor, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(rankName, style: TextStyle(color: rankColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text("${prov.xp} XP", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text("${prov.coins}", style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric("WINS", "${prov.rankPoints ~/ 20}", Colors.greenAccent),
              _buildStatMetric("STREAK", "${prov.winStreak}🔥", Colors.orangeAccent),
              _buildStatMetric("RANK PTS", "${prov.rankPoints}", rankColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildGameGrid(BuildContext context, BattleProvider battleProv, StudentProvider studentProv) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildModeCard(context, "1 VS 1 Battle", Icons.sports_kabaddi, AppColors.primaryNeon, () {
          // Quick mock matchmaking
          battleProv.createRoom('GENERAL', studentProv.studentProfile?['uid'] ?? 'u1', studentProv.studentProfile?['fullName'] ?? 'Player 1');
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BattleMatchScreen()));
        }),
        _buildModeCard(context, "Dept Battle", Icons.account_balance, Colors.orangeAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DepartmentWarScreen()));
        }),
        _buildModeCard(context, "Tournament", Icons.emoji_events, Colors.amber, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TournamentBracketScreen()));
        }),
        _buildModeCard(context, "AI Bot Battle", Icons.smart_toy, AppColors.secondaryNeon, () {
          battleProv.startBotBattle('Hard', studentProv.studentProfile?['uid'] ?? 'u1', studentProv.studentProfile?['fullName'] ?? 'Player 1');
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BattleMatchScreen()));
        }),
        _buildModeCard(context, "Team Mode", Icons.group_add, Colors.blueAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamBattleLobbyScreen()));
        }),
        _buildModeCard(context, "Voice Mode", Icons.mic, Colors.purpleAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceBattleScreen()));
        }),
        _buildModeCard(context, "Store", Icons.storefront, Colors.pinkAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen()));
        }),
        _buildModeCard(context, "Achievements", Icons.military_tech, Colors.tealAccent, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
        }),
      ],
    );
  }

  Widget _buildModeCard(BuildContext context, String title, IconData icon, Color glowColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: HolographicCard(
        glowColor: glowColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: glowColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                  )
                ]
              ),
              child: Icon(icon, color: glowColor, size: 35),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
