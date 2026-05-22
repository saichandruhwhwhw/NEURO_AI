import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/holographic_card.dart';
import '../../../core/widgets/futuristic_toast.dart';
import '../../../core/widgets/neon_progress_bar.dart';
import '../../../core/providers/student_provider.dart';
import '../../../core/providers/battle_provider.dart';
import 'battle_winner_screen.dart';

class BattleMatchScreen extends StatefulWidget {
  final bool isDeptMatch;
  const BattleMatchScreen({super.key, this.isDeptMatch = false});

  @override
  State<BattleMatchScreen> createState() => _BattleMatchScreenState();
}

class _BattleMatchScreenState extends State<BattleMatchScreen> with TickerProviderStateMixin {
  Timer? _questionTimer;
  int _secondsRemaining = 20;
  bool _isTimerFrozen = false;
  int _freezeRemaining = 0;
  
  // Powerup States for the current question
  List<int> _hiddenOptions = [];
  bool _hintUsed = false;
  bool _doublePointsUsed = false;

  // Local answer tracking to prevent double submission per question
  int _lastSubmittedIndex = -1;
  int _selectedOptionIndex = -1;
  bool _showCorrectness = false;
  DateTime? _questionStartTime;

  // Simulated Voice Mode State
  bool _isVoiceListening = false;
  String _voiceTranscription = "";
  double _voiceConfidence = 0.0;
  late AnimationController _waveController;

  // Camera Focus Score simulation
  double _simulatedFocus = 0.92;
  Timer? _focusTimer;

  // Countdown at start
  int _startCountdown = 3;
  Timer? _startCountdownTimer;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _startMatchflow();

    // Focus simulator ticks every 2.5 seconds
    _focusTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _simulatedFocus = (0.80 + Random().nextDouble() * 0.19).clamp(0.0, 1.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _focusTimer?.cancel();
    _startCountdownTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  void _startMatchflow() {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    final room = battleProv.activeRoom;

    if (room != null && room['status'] == 'countdown') {
      // Multiplayer countdown
      _startCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_startCountdown > 1) {
              _startCountdown--;
            } else {
              _startCountdownTimer?.cancel();
              _gameStarted = true;
              _initQuestionTimer();
            }
          });
        }
      });
    } else {
      // Local Bot match starts immediately or quick 1s count
      _gameStarted = true;
      _initQuestionTimer();
    }
  }

  void _initQuestionTimer() {
    _questionTimer?.cancel();
    setState(() {
      _secondsRemaining = 20;
      _isTimerFrozen = false;
      _freezeRemaining = 0;
      _hiddenOptions.clear();
      _hintUsed = false;
      _doublePointsUsed = false;
      _showCorrectness = false;
      _selectedOptionIndex = -1;
      _questionStartTime = DateTime.now();
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_isTimerFrozen) {
        setState(() {
          if (_freezeRemaining > 1) {
            _freezeRemaining--;
          } else {
            _isTimerFrozen = false;
          }
        });
        return;
      }

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _questionTimer?.cancel();
          _timeExpiredSubmit();
        }
      });
    });
  }

  void _timeExpiredSubmit() {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final studentId = studentProv.studentProfile?['uid'] ?? "student_user";
    final room = battleProv.activeRoom;
    if (room == null) return;

    int currIdx = room['currentQuestionIndex'];
    
    // Auto submit incorrect due to timeout
    battleProv.submitAnswer(
      studentId,
      currIdx,
      false,
      20.0,
      _simulatedFocus,
    );
  }

  void _handleOptionTap(int optionIndex, Map<String, dynamic> question) {
    if (_showCorrectness || _selectedOptionIndex != -1) return;

    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final studentId = studentProv.studentProfile?['uid'] ?? "student_user";
    final room = battleProv.activeRoom;
    if (room == null) return;

    int currIdx = room['currentQuestionIndex'];
    int correctIdx = question['correctIndex'] as int;
    bool isCorrect = optionIndex == correctIdx;

    final now = DateTime.now();
    double timeTaken = _questionStartTime != null 
        ? now.difference(_questionStartTime!).inMilliseconds / 1000.0 
        : 2.0;
    

    setState(() {
      _selectedOptionIndex = optionIndex;
      _showCorrectness = true;
    });

    // Submit answer to provider / firestore
    battleProv.submitAnswer(
      studentId,
      currIdx,
      isCorrect,
      timeTaken,
      _simulatedFocus,
    );

    // If double points powerup was active, double the reward locally or trigger extra toast
    if (_doublePointsUsed && isCorrect) {
      FuturisticToast.show(context, message: "CRITICAL HACK: Double Points active! (+20 Points)");
    }
  }

  // Powerup Activation Logic
  void _activateHint(Map<String, dynamic> question) {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['hint'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No Hint items in inventory.", isError: true);
      return;
    }

    if (_hintUsed) {
      FuturisticToast.show(context, message: "Hint already active on this question.", isError: true);
      return;
    }

    battleProv.usePowerup('hint');
    setState(() {
      _hintUsed = true;
    });
    FuturisticToast.show(context, message: "Synapse Scan: Correct answer highlighted in Gold!");
  }

  void _activate5050(Map<String, dynamic> question) {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['50_50'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No 50-50 items in inventory.", isError: true);
      return;
    }

    if (_hiddenOptions.isNotEmpty) {
      FuturisticToast.show(context, message: "Options already eliminated.", isError: true);
      return;
    }

    battleProv.usePowerup('50_50');
    
    int correctIdx = question['correctIndex'] as int;
    List<int> incorrectIndices = [];
    for (int i = 0; i < 4; i++) {
      if (i != correctIdx) incorrectIndices.add(i);
    }
    
    // Choose two random incorrect options to hide
    incorrectIndices.shuffle();
    setState(() {
      _hiddenOptions = [incorrectIndices[0], incorrectIndices[1]];
    });
    FuturisticToast.show(context, message: "Quantum Eraser: Two incorrect options deleted!");
  }

  void _activateDoublePoints() {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['double_points'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No Double Score items in inventory.", isError: true);
      return;
    }

    if (_doublePointsUsed) {
      FuturisticToast.show(context, message: "Multiplier already active.", isError: true);
      return;
    }

    battleProv.usePowerup('double_points');
    setState(() {
      _doublePointsUsed = true;
    });
    FuturisticToast.show(context, message: "Cognitive Surge: Core rewards doubled for this question!");
  }

  void _activateFreezeTimer() {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['freeze_timer'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No Freeze clock items in inventory.", isError: true);
      return;
    }

    if (_isTimerFrozen) {
      FuturisticToast.show(context, message: "Clock is already frozen.", isError: true);
      return;
    }

    battleProv.usePowerup('freeze_timer');
    setState(() {
      _isTimerFrozen = true;
      _freezeRemaining = 5;
    });
    FuturisticToast.show(context, message: "Temporal Freeze: Clock suspended for 5 seconds!");
  }

  void _activateSkip(Map<String, dynamic> question) {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['skip'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No Skip items in inventory.", isError: true);
      return;
    }

    battleProv.usePowerup('skip');
    FuturisticToast.show(context, message: "Quantum Leap: Bypassing question with positive points.");
    
    // Automatically submit correct answer with average speed
    final studentProv = Provider.of<StudentProvider>(context, listen: false);
    final studentId = studentProv.studentProfile?['uid'] ?? "student_user";
    final room = battleProv.activeRoom;
    if (room != null) {
      int currIdx = room['currentQuestionIndex'];
      battleProv.submitAnswer(
        studentId,
        currIdx,
        true,
        1.5,
        _simulatedFocus,
      );
    }
  }

  void _activateTimeBoost() {
    final battleProv = Provider.of<BattleProvider>(context, listen: false);
    if ((battleProv.powerups['time_boost'] ?? 0) <= 0) {
      FuturisticToast.show(context, message: "No Time Boost items in inventory.", isError: true);
      return;
    }

    battleProv.usePowerup('time_boost');
    setState(() {
      _secondsRemaining = (_secondsRemaining + 10).clamp(0, 30);
    });
    FuturisticToast.show(context, message: "Chronos Injection: +10 Seconds added to clock!");
  }

  // Voice Answer Mode Simulation
  void _triggerVoiceAnswerMode(Map<String, dynamic> question) {
    if (_showCorrectness || _isVoiceListening) return;

    setState(() {
      _isVoiceListening = true;
      _voiceTranscription = "Syncing acoustic node...";
      _voiceConfidence = 0.0;
    });

    // Simulate speech recognition
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      int correctIdx = question['correctIndex'] as int;
      String answerText = question['options'][correctIdx];

      setState(() {
        _voiceTranscription = '"$answerText"';
        _voiceConfidence = 0.94;
      });

      Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _isVoiceListening = false;
        });
        FuturisticToast.show(context, message: "Voice Command verified: $answerText (94% confidence)");
        _handleOptionTap(correctIdx, question);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final battleProv = Provider.of<BattleProvider>(context);
    
    final room = battleProv.activeRoom;

    // Safety check if room left
    if (room == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Lobby session terminated.", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Return to Arena"),
              ),
            ],
          ),
        ),
      );
    }

    // Check if game is completed -> Go to Winner Page
    if (room['status'] == 'completed') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BattleWinnerScreen(isDeptMatch: widget.isDeptMatch)),
        );
      });
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryNeon),
        ),
      );
    }

    // Pre-start Countdown screen
    if (!_gameStarted && room['status'] == 'countdown') {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF1B0836), Colors.black],
              radius: 1.3,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pulse(
                  infinite: true,
                  child: const Text(
                    "DUEL COMMENCING",
                    style: TextStyle(
                      color: AppColors.primaryNeon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Focus Shard: ${room['subject']}",
                  style: const TextStyle(color: Colors.white30, fontSize: 13),
                ),
                const SizedBox(height: 40),
                ZoomIn(
                  duration: const Duration(milliseconds: 500),
                  key: ValueKey(_startCountdown),
                  child: Text(
                    "$_startCountdown",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.w900,
                      fontFamily: "Outfit",
                      shadows: [
                        Shadow(color: AppColors.primaryNeon, blurRadius: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Main Game Mode UI
    final int questionIdx = room['currentQuestionIndex'];
    final List<dynamic> questionsList = room['questions'];
    
    // Safety clamp question index
    final clampedIdx = questionIdx.clamp(0, questionsList.length - 1);
    final question = questionsList[clampedIdx] as Map<String, dynamic>;
    final options = List<String>.from(question['options']);

    // Check if we advanced question -> Reset timer
    if (_lastSubmittedIndex != clampedIdx) {
      _lastSubmittedIndex = clampedIdx;
      // Triggers question timer reset safely
      Future.microtask(() => _initQuestionTimer());
    }

    // Players profiles
    final player1 = room['player1'];
    final player2 = room['player2'];

    final int p1Score = player1['score'] ?? 0;
    final int p2Score = player2 != null ? (player2['score'] ?? 0) : 0;
    final bool p1Leading = p1Score > p2Score;
    final bool p2Leading = p2Score > p1Score && player2 != null;

    final String p1Name = player1['name'] ?? "Player 1";
    final String p2Name = player2 != null ? player2['name'] : "Enlisting...";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Futuristic Cyber Grid background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF13092C), Colors.black],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header: Split Player Scores Dashboard
                _buildPlayersScoreboard(
                  p1Name: p1Name,
                  p2Name: p2Name,
                  p1Score: p1Score,
                  p2Score: p2Score,
                  p1Leading: p1Leading,
                  p2Leading: p2Leading,
                  player1: player1,
                  player2: player2,
                ),

                const SizedBox(height: 10),

                // Timer & Leading Status Progress Bar
                _buildMatchProgressBar(p1Score, p2Score, player2 != null),

                // Question Arena & Powerups
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Round Index
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentPurple.withValues(alpha: 0.15),
                              border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ROUND ${clampedIdx + 1} OF 10 | ${question['category'].toString().toUpperCase()}",
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question card
                        FadeInRight(
                          key: ValueKey(clampedIdx),
                          child: HolographicCard(
                            glowColor: widget.isDeptMatch ? Colors.redAccent : AppColors.primaryNeon,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question['question'],
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Multiple Choice Options
                        ...List.generate(options.length, (idx) {
                          if (_hiddenOptions.contains(idx)) {
                            return const SizedBox.shrink(); // Hidden by 50-50
                          }

                          final optText = options[idx];
                          final isCorrectIndex = idx == question['correctIndex'];
                          
                          Color borderColor = Colors.white24;
                          Color background = Colors.white.withValues(alpha: 0.03);
                          Widget? trailing;

                          if (_showCorrectness) {
                            if (isCorrectIndex) {
                              borderColor = Colors.greenAccent;
                              background = Colors.greenAccent.withValues(alpha: 0.15);
                              trailing = const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20);
                            } else if (idx == _selectedOptionIndex) {
                              borderColor = Colors.redAccent;
                              background = Colors.redAccent.withValues(alpha: 0.15);
                              trailing = const Icon(Icons.cancel, color: Colors.redAccent, size: 20);
                            }
                          } else {
                            if (_hintUsed && isCorrectIndex) {
                              // Glow gold for active Hint
                              borderColor = Colors.amber;
                              background = Colors.amber.withValues(alpha: 0.08);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: FadeInUp(
                              delay: Duration(milliseconds: idx * 50),
                              child: GestureDetector(
                                onTap: () => _handleOptionTap(idx, question),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: background,
                                    border: Border.all(color: borderColor, width: 1.5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: borderColor),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + idx),
                                            style: TextStyle(color: borderColor, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          optText,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                       ?trailing,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Powerups Hotbar Panel (Persistent at bottom)
                _buildPowerupHotbar(battleProv, question),
              ],
            ),
          ),

          // Speech Simulator Overlay
          if (_isVoiceListening)
            _buildVoiceOverlay(),
        ],
      ),
    );
  }

  // scoreboard Row Widget
  Widget _buildPlayersScoreboard({
    required String p1Name,
    required String p2Name,
    required int p1Score,
    required int p2Score,
    required bool p1Leading,
    required bool p2Leading,
    required dynamic player1,
    required dynamic player2,
  }) {
    final int p1Acc = player1['accuracy'] ?? 0;
    final double p1Speed = (player1['speed'] ?? 0.0).toDouble();

    final int p2Acc = player2 != null ? (player2['accuracy'] ?? 0) : 0;
    final double p2Speed = player2 != null ? (player2['speed'] ?? 0.0).toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Player 1 (Blue)
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
                    border: Border.all(
                      color: p1Leading ? AppColors.primaryNeon : Colors.white12,
                      width: p1Leading ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: AppColors.primaryNeon, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p1Name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("$p1Score PTS", style: const TextStyle(color: AppColors.primaryNeon, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Outfit")),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Acc: $p1Acc%", style: const TextStyle(color: Colors.white30, fontSize: 9)),
                          Text("Speed: ${p1Speed.toStringAsFixed(1)}s", style: const TextStyle(color: Colors.white30, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (p1Leading)
                  Positioned(
                    top: -12,
                    left: 12,
                    child: FadeInDown(
                      child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          // Player 2 (Red/Bot)
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0B24).withValues(alpha: 0.6),
                    border: Border.all(
                      color: p2Leading ? Colors.redAccent : Colors.white12,
                      width: p2Leading ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p2Name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("$p2Score PTS", style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Outfit")),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Acc: $p2Acc%", style: const TextStyle(color: Colors.white30, fontSize: 9)),
                          Text("Speed: ${p2Speed.toStringAsFixed(1)}s", style: const TextStyle(color: Colors.white30, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (p2Leading)
                  Positioned(
                    top: -12,
                    right: 12,
                    child: FadeInDown(
                      child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Progress connector bar showing current clock and relative score dominance
  Widget _buildMatchProgressBar(int p1Score, int p2Score, bool hasOpponent) {
    double dominance = 0.5;
    if (hasOpponent && (p1Score + p2Score) > 0) {
      dominance = p1Score / (p1Score + p2Score);
    }

    double timerProgress = _secondsRemaining / 20.0;
    Color timerColor = timerProgress > 0.5 
        ? AppColors.primaryNeon 
        : (timerProgress > 0.25 ? Colors.orangeAccent : Colors.redAccent);

    if (_isTimerFrozen) {
      timerColor = Colors.cyanAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left text
              Row(
                children: [
                  const Icon(Icons.camera_front, color: Colors.white54, size: 12),
                  const SizedBox(width: 4),
                  Text("Focus Index: ${(_simulatedFocus * 100).toInt()}%", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
              // Timer Clock
              Row(
                children: [
                  Icon(
                    _isTimerFrozen ? Icons.ac_unit : Icons.timer,
                    color: timerColor,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isTimerFrozen ? "FROZEN (${_freezeRemaining}s)" : "${_secondsRemaining}s remaining",
                    style: TextStyle(color: timerColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Timer bar
          NeonProgressBar(progress: timerProgress, color: timerColor, height: 4),
          const SizedBox(height: 8),
          // Score Dominance bar
          Row(
            children: [
              const Text("BLUE LEAD", style: TextStyle(color: AppColors.primaryNeon, fontSize: 8, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text("RED LEAD", style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: Row(
                children: [
                  Expanded(
                    flex: (dominance * 100).toInt(),
                    child: Container(color: AppColors.primaryNeon),
                  ),
                  Expanded(
                    flex: ((1.0 - dominance) * 100).toInt(),
                    child: Container(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Powerup Hotbar Panel
  Widget _buildPowerupHotbar(BattleProvider battleProv, Map<String, dynamic> question) {
    final list = [
      {'id': 'hint', 'name': 'Hint', 'icon': Icons.lightbulb, 'color': Colors.amber, 'action': () => _activateHint(question)},
      {'id': '50_50', 'name': '50-50', 'icon': Icons.difference, 'color': AppColors.primaryNeon, 'action': () => _activate5050(question)},
      {'id': 'double_points', 'name': '2x Score', 'icon': Icons.star_purple500, 'color': Colors.greenAccent, 'action': () => _activateDoublePoints()},
      {'id': 'freeze_timer', 'name': 'Freeze', 'icon': Icons.ac_unit, 'color': Colors.cyanAccent, 'action': () => _activateFreezeTimer()},
      {'id': 'skip', 'name': 'Skip', 'icon': Icons.skip_next, 'color': Colors.orangeAccent, 'action': () => _activateSkip(question)},
      {'id': 'time_boost', 'name': '+10s', 'icon': Icons.add_alarm, 'color': AppColors.accentPurple, 'action': () => _activateTimeBoost()},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C091D),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TACTICAL ARMORY HOTBAR", style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              GestureDetector(
                onTap: () => _triggerVoiceAnswerMode(question),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mic, color: Colors.redAccent, size: 10),
                      SizedBox(width: 4),
                      Text("VOICE ANSWER MODE", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: list.map((item) {
              final id = item['id'] as String;
              final name = item['name'] as String;
              final icon = item['icon'] as IconData;
              final color = item['color'] as Color;
              final action = item['action'] as VoidCallback;
              final count = battleProv.powerups[id] ?? 0;
              final hasItems = count > 0;

              return GestureDetector(
                onTap: hasItems && !_showCorrectness ? action : null,
                child: Opacity(
                  opacity: hasItems && !_showCorrectness ? 1.0 : 0.35,
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                              child: Text(
                                "$count",
                                style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(name, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // Voice Recognition Wave Widget Overlay
  Widget _buildVoiceOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.90),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Voice pulse indicator
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveController.value),
                  size: const Size(200, 80),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              "ACQUISITING VOICE DATAFRAME...",
              style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              _voiceTranscription.isEmpty ? "Speak your answer choice clearly..." : _voiceTranscription,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            if (_voiceConfidence > 0) ...[
              const SizedBox(height: 8),
              Text(
                "Confidence level: ${(_voiceConfidence * 100).toInt()}%",
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// Custom Speech wave painter
class WavePainter extends CustomPainter {
  final double progress;
  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double midY = size.height / 2;
    
    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x++) {
      double relativeX = x / size.width;
      // Make amplitude decay at boundaries
      double amplitude = 25 * sin(pi * relativeX);
      double y = midY + amplitude * sin(2 * pi * (relativeX * 3 - progress * 2));
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Overlay sub wave
    final paint2 = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final path2 = Path();
    path2.moveTo(0, midY);
    for (double x = 0; x <= size.width; x++) {
      double relativeX = x / size.width;
      double amplitude = 15 * sin(pi * relativeX);
      double y = midY - amplitude * sin(2 * pi * (relativeX * 4 + progress * 3));
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
