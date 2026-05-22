import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/providers/battle_provider.dart';
import 'battle_match_screen.dart';

class TournamentBracketScreen extends StatefulWidget {
  const TournamentBracketScreen({super.key});

  @override
  State<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  // Simple structure for 8-player bracket
  // QF (4 matches) -> SF (2 matches) -> Finals (1 match) -> Champion
  final List<String> _qfPlayers = [
    "Alex Mercer", "Sarah Connor",
    "Elena Rostova", "Marcus Vance",
    "YOU (Player Node)", "T-800 Solver",
    "Alpha-Synapse AI", "Cybernetic-Brain"
  ];

  // Scores for matches
  final List<int?> _qfScores = [120, 95, 110, 85, null, null, 130, 105];
  final List<String?> _sfPlayers = ["Alex Mercer", "Elena Rostova", null, "Alpha-Synapse AI"];
  final List<int?> _sfScores = [115, 110, null, null];
  final List<String?> _finalsPlayers = ["Alex Mercer", null];
  final List<int?> _finalsScores = [null, null];
  String? _champion;

  bool _isUserMatchFinished = false;

  void _runSimulatedMatches() {
    // When user completes their match, we can simulate results of other ongoing brackets
    setState(() {
      _qfScores[4] = 145; // User score
      _qfScores[5] = 110; // T-800 Solver
      _sfPlayers[2] = "YOU (Player Node)";
      
      // SF Match 2 simulation
      _sfScores[2] = 150; // User score
      _sfScores[3] = 135; // Alpha-Synapse
      _finalsPlayers[1] = "YOU (Player Node)";

      // Final Match simulation
      _finalsScores[0] = 140; // Alex Mercer
      _finalsScores[1] = 155; // User score
      _champion = "YOU (Player Node)";
      _isUserMatchFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final battleProv = Provider.of<BattleProvider>(context);
    final studentProv = Provider.of<StudentProvider>(context);
    final studentName = studentProv.studentProfile?['fullName'] ?? "Player 1";

    // Update User Name node in bracket
    if (_qfPlayers[4] == "YOU (Player Node)") {
      _qfPlayers[4] = "$studentName (YOU)";
    }
    if (_sfPlayers[2] == "YOU (Player Node)") {
      _sfPlayers[2] = "$studentName (YOU)";
    }
    if (_finalsPlayers[1] == "YOU (Player Node)") {
      _finalsPlayers[1] = "$studentName (YOU)";
    }
    if (_champion == "YOU (Player Node)") {
      _champion = "$studentName (YOU)";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0B24),
        elevation: 0,
        title: const Text(
          "COGNITIVE ESPORTS TOURNAMENT",
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Matrix
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF160A2D), Colors.black],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Cup Card
                  FadeInDown(
                    child: _buildTournamentHeader(),
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Bracket View Scrollable
                  FadeInUp(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1: Quarterfinals
                          _buildBracketRoundColumn(
                            roundName: "QUARTERFINALS",
                            matchCount: 4,
                            childBuilder: (matchIdx) {
                              int p1Idx = matchIdx * 2;
                              int p2Idx = p1Idx + 1;
                              String p1 = _qfPlayers[p1Idx];
                              String p2 = _qfPlayers[p2Idx];
                              int? s1 = _qfScores[p1Idx];
                              int? s2 = _qfScores[p2Idx];
                              bool isUserMatch = matchIdx == 2; // Match 3 is user QF

                              return _buildMatchBracketCard(
                                player1: p1,
                                player2: p2,
                                score1: s1,
                                score2: s2,
                                isUserMatch: isUserMatch,
                                matchIdx: matchIdx,
                                round: 1,
                                studentName: studentName,
                                battleProv: battleProv,
                              );
                            },
                          ),
                          _buildConnectorLineColumn(),

                          // Column 2: Semifinals
                          _buildBracketRoundColumn(
                            roundName: "SEMIFINALS",
                            matchCount: 2,
                            childBuilder: (matchIdx) {
                              int p1Idx = matchIdx * 2;
                              int p2Idx = p1Idx + 1;
                              String p1 = _sfPlayers[p1Idx] ?? "TBD";
                              String p2 = _sfPlayers[p2Idx] ?? "TBD";
                              int? s1 = _sfScores[p1Idx];
                              int? s2 = _sfScores[p2Idx];
                              bool isUserMatch = matchIdx == 1 && _sfPlayers[2] != null;

                              return _buildMatchBracketCard(
                                player1: p1,
                                player2: p2,
                                score1: s1,
                                score2: s2,
                                isUserMatch: isUserMatch,
                                matchIdx: matchIdx,
                                round: 2,
                                studentName: studentName,
                                battleProv: battleProv,
                              );
                            },
                          ),
                          _buildConnectorLineColumn(),

                          // Column 3: Grand Finals
                          _buildBracketRoundColumn(
                            roundName: "GRAND FINALS",
                            matchCount: 1,
                            childBuilder: (matchIdx) {
                              String p1 = _finalsPlayers[0] ?? "TBD";
                              String p2 = _finalsPlayers[1] ?? "TBD";
                              int? s1 = _finalsScores[0];
                              int? s2 = _finalsScores[1];
                              bool isUserMatch = _finalsPlayers[1] != null;

                              return _buildMatchBracketCard(
                                player1: p1,
                                player2: p2,
                                score1: s1,
                                score2: s2,
                                isUserMatch: isUserMatch,
                                matchIdx: matchIdx,
                                round: 3,
                                studentName: studentName,
                                battleProv: battleProv,
                              );
                            },
                          ),
                          _buildConnectorLineColumn(),

                          // Column 4: Champion Crown
                          _buildChampionColumn(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_isUserMatchFinished)
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.greenAccent, size: 28),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("TOURNAMENT COMPLETE!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  SizedBox(height: 2),
                                  Text("You dominated the esports bracket. +200 RP & Trophy added to showcase.", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  // Reset bracket state
                                  _qfScores[4] = null;
                                  _qfScores[5] = null;
                                  _sfPlayers[2] = null;
                                  _sfScores[2] = null;
                                  _sfScores[3] = null;
                                  _finalsPlayers[1] = null;
                                  _finalsScores[0] = null;
                                  _finalsScores[1] = null;
                                  _champion = null;
                                  _isUserMatchFinished = false;
                                });
                                FuturisticToast.show(context, message: "Bracket refreshed. Challenge active!");
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                              child: const Text("REPLAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("COGNITIVE MAJESTIC CHAMPIONSHIP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text("Solve 10 questions each round. Win to advance through the esports brackets and claim the grand prize of 500 Coins & Trophies.", style: TextStyle(color: Colors.white30, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketRoundColumn({
    required String roundName,
    required int matchCount,
    required Widget Function(int matchIdx) childBuilder,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              roundName,
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 20),
          // Vertical layout spacing dependent on round depth
          Column(
            children: List.generate(matchCount, (idx) {
              double heightGap = 30.0;
              if (roundName == "SEMIFINALS") heightGap = 120.0;
              if (roundName == "GRAND FINALS") heightGap = 210.0;

              return Padding(
                padding: EdgeInsets.only(bottom: heightGap),
                child: childBuilder(idx),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLineColumn() {
    return SizedBox(
      width: 24,
      height: 380,
      child: Center(
        child: Container(
          width: 1.5,
          color: Colors.white10,
        ),
      ),
    );
  }

  Widget _buildMatchBracketCard({
    required String player1,
    required String player2,
    required int? score1,
    required int? score2,
    required bool isUserMatch,
    required int matchIdx,
    required int round,
    required String studentName,
    required BattleProvider battleProv,
  }) {
    bool hasWinner1 = score1 != null && score2 != null && score1 > score2;
    bool hasWinner2 = score1 != null && score2 != null && score2 > score1;

    Color p1Color = hasWinner1 ? Colors.greenAccent : (score1 != null ? Colors.white70 : Colors.white30);
    Color p2Color = hasWinner2 ? Colors.greenAccent : (score2 != null ? Colors.white70 : Colors.white30);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUserMatch ? const Color(0xFF1B0836) : const Color(0xFF0F0B24).withValues(alpha: 0.8),
        border: Border.all(
          color: isUserMatch ? AppColors.primaryNeon : Colors.white.withValues(alpha: 0.05),
          width: isUserMatch ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isUserMatch
            ? [BoxShadow(color: AppColors.primaryNeon.withValues(alpha: 0.15), blurRadius: 10)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  player1,
                  style: TextStyle(color: p1Color, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                score1 != null ? "$score1" : "-",
                style: TextStyle(color: p1Color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 6),
          // Player 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  player2,
                  style: TextStyle(color: p2Color, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                score2 != null ? "$score2" : "-",
                style: TextStyle(color: p2Color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          if (isUserMatch && score1 == null && score2 == null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Trigger match start in BattleMatchScreen
                battleProv.startBotBattle("Medium", "student_user", studentName);
                
                // Show notification and go
                FuturisticToast.show(context, message: "Syncing tournament match matrix...");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BattleMatchScreen()),
                ).then((_) {
                  // Simulate complete bracket tree after returning
                  _runSimulatedMatches();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNeon,
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: const Size(0, 24),
              ),
              child: const Text("PLAY NODE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildChampionColumn() {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(left: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "CHAMPION NODE",
              style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 120),
          _champion != null
              ? ZoomIn(
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 54),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.amber, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _champion!.toUpperCase(),
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_outline, color: Colors.white24, size: 30),
                  ),
                ),
        ],
      ),
    );
  }
}
