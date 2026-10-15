import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  // Local student state
  int coins = 350;
  int xp = 1200;
  int rankPoints = 450; // Bronze: 0-200, Silver: 201-400, Gold: 401-650, Platinum: 651-900, Diamond: 901-1200, Elite: 1201-1600, Master: 1601+
  int winStreak = 4;
  int dailyStreakCount = 7;
  
  // Powerups inventory
  Map<String, int> powerups = {
    'hint': 2,
    '50_50': 1,
    'double_points': 3,
    'freeze_timer': 1,
    'skip': 0,
    'time_boost': 2,
  };

  // Daily quests tracking
  List<Map<String, dynamic>> dailyQuests = [
    {'id': 'win_bot', 'desc': 'Win 2 matches against AI Bot', 'target': 2, 'current': 1, 'rewardXP': 100, 'rewardCoins': 50, 'completed': false},
    {'id': 'high_acc', 'desc': 'Achieve >85% accuracy in any battle', 'target': 1, 'current': 0, 'rewardXP': 150, 'rewardCoins': 80, 'completed': false},
    {'id': 'use_powerup', 'desc': 'Use 3 powerups in live battles', 'target': 3, 'current': 1, 'rewardXP': 80, 'rewardCoins': 40, 'completed': false},
  ];

  // Achievements
  List<Map<String, dynamic>> achievements = [
    {'id': 'first_win', 'title': 'First Blood', 'desc': 'Win your first battle.', 'unlocked': true},
    {'id': '10_wins', 'title': 'Rising Star', 'desc': 'Win 10 battles.', 'unlocked': false},
    {'id': 'dept_champ', 'title': 'Department Champion', 'desc': 'Win 5 department wars.', 'unlocked': false},
    {'id': 'tourney_win', 'title': 'Tournament Victor', 'desc': 'Win a 8-player bracket.', 'unlocked': false},
  ];

  // Store Inventory tracking
  List<String> unlockedThemes = ['Cyber Neon', 'Dark Matter'];
  String activeTheme = 'Cyber Neon';
  List<String> unlockedAvatars = ['default_bot.png'];
  String activeAvatar = 'default_bot.png';

  // Active multiplayer room state
  StreamSubscription? _roomSub;
  Map<String, dynamic>? activeRoom;
  bool isSearching = false;

  // Department scores
  Map<String, int> departmentScores = {
    'CSE': 1420,
    'IT': 1380,
    'AIDS': 1490,
    'ECE': 1210,
    'MECH': 980,
    'CIVIL': 850,
  };

  // Global leaderboard
  List<Map<String, dynamic>> leaderboard = [];

  // Question bank mapped by department
  final Map<String, List<Map<String, dynamic>>> _departmentQuestions = {
    'IT': [
      {'question': 'Which keyword is used to handle exceptions in Java?', 'options': ['try', 'catch', 'throw', 'All of the above'], 'correctIndex': 3},
      {'question': 'What does DCCN stand for?', 'options': ['Data Computer Network', 'Data Communication and Computer Networks', 'Digital Computer Network', 'None'], 'correctIndex': 1},
      {'question': 'Which protocol is used for secure communication over internet?', 'options': ['HTTP', 'FTP', 'HTTPS', 'SMTP'], 'correctIndex': 2},
    ],
    'CSE': [
      {'question': 'What is the time complexity of searching in a balanced BST?', 'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'], 'correctIndex': 1},
      {'question': 'Which phase of compiler generates target code?', 'options': ['Lexical', 'Syntax', 'Semantic', 'Code Generation'], 'correctIndex': 3},
      {'question': 'What avoids deadlock in OS?', 'options': ['Bankers Algorithm', 'Round Robin', 'FCFS', 'SJF'], 'correctIndex': 0},
    ],
    'AIDS': [
      {'question': 'Which activation function is used to prevent vanishing gradients?', 'options': ['Sigmoid', 'Tanh', 'ReLU', 'Softmax'], 'correctIndex': 2},
      {'question': 'What does SVM stand for in ML?', 'options': ['Support Vector Machine', 'Simple Vector Math', 'Static Variable Model', 'System Virtual Machine'], 'correctIndex': 0},
    ],
    'ECE': [
      {'question': 'In a D flip-flop, what does the D stand for?', 'options': ['Data', 'Delay', 'Digital', 'Both A and B'], 'correctIndex': 3},
      {'question': 'What is the base of Hexadecimal system?', 'options': ['2', '8', '10', '16'], 'correctIndex': 3},
    ],
    'MECH': [
      {'question': 'Which law of thermodynamics defines entropy?', 'options': ['Zeroth', 'First', 'Second', 'Third'], 'correctIndex': 2},
      {'question': 'What does CAD stand for?', 'options': ['Computer Aided Design', 'Car Auto Design', 'Computer Architecture Design', 'None'], 'correctIndex': 0},
    ],
    'CIVIL': [
      {'question': 'What is the standard size of a modular brick?', 'options': ['19x9x9 cm', '20x10x10 cm', '22x11x7 cm', 'None'], 'correctIndex': 0},
    ],
    'GENERAL': [
      {'question': 'A train traveling at 60 km/h passes a post in 9 seconds. Train length?', 'options': ['120m', '150m', '180m', '200m'], 'correctIndex': 1},
      {'question': 'According to Ebbinghaus, when does the steepest drop in memory recall happen?', 'options': ['First 20 mins', 'First 2 hrs', 'First 24 hrs', 'First week'], 'correctIndex': 0},
    ]
  };

  BattleProvider() {
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    leaderboard = [
      {'name': 'Alex Mercer', 'dept': 'CSE', 'wins': 142, 'accuracy': 92, 'speed': 1.8, 'rank': 'Cognitive Master'},
      {'name': 'Marcus Vance', 'dept': 'AIDS', 'wins': 128, 'accuracy': 89, 'speed': 2.1, 'rank': 'Elite'},
      {'name': 'Elena Rostova', 'dept': 'ECE', 'wins': 115, 'accuracy': 91, 'speed': 1.9, 'rank': 'Elite'},
      {'name': 'Sarah Connor', 'dept': 'IT', 'wins': 98, 'accuracy': 85, 'speed': 2.3, 'rank': 'Diamond'},
      {'name': 'T-800 Solver', 'dept': 'CSE', 'wins': 92, 'accuracy': 98, 'speed': 1.1, 'rank': 'Cognitive Master'},
    ];
  }

  // --- STORE ACTIONS ---
  bool buyItem(String itemId, int cost, String type) {
    if (coins >= cost) {
      coins -= cost;
      if (type == 'powerup') {
        powerups[itemId] = (powerups[itemId] ?? 0) + 1;
      } else if (type == 'theme') {
        unlockedThemes.add(itemId);
      } else if (type == 'avatar') {
        unlockedAvatars.add(itemId);
      }
      notifyListeners();
      return true;
    }
    return false;
  }
  
  void setActiveTheme(String theme) {
    if (unlockedThemes.contains(theme)) {
      activeTheme = theme;
      notifyListeners();
    }
  }

  void setActiveAvatar(String avatar) {
    if (unlockedAvatars.contains(avatar)) {
      activeAvatar = avatar;
      notifyListeners();
    }
  }

  void unlockAchievement(String achId) {
    var ach = achievements.firstWhere((a) => a['id'] == achId, orElse: () => {});
    if (ach.isNotEmpty && ach['unlocked'] == false) {
      ach['unlocked'] = true;
      notifyListeners();
    }
  }

  // --- POWERUP SHOP ACTIONS ---

  void usePowerup(String powerupId) {
    if ((powerups[powerupId] ?? 0) > 0) {
      powerups[powerupId] = powerups[powerupId]! - 1;
      
      // Update Quest progress if using in game
      var quest = dailyQuests.firstWhere((q) => q['id'] == 'use_powerup');
      if (quest['current'] < quest['target']) {
        quest['current'] += 1;
        if (quest['current'] == quest['target']) {
          quest['completed'] = true;
          coins += quest['rewardCoins'] as int;
          xp += quest['rewardXP'] as int;
        }
      }
      notifyListeners();
    }
  }

  // --- QUEST COMPLETIONS ---
  void incrementQuestProgress(String questId, int val) {
    var quest = dailyQuests.firstWhere((q) => q['id'] == questId);
    if (!quest['completed'] && quest['current'] < quest['target']) {
      quest['current'] += val;
      if (quest['current'] >= quest['target']) {
        quest['completed'] = true;
        coins += quest['rewardCoins'] as int;
        xp += quest['rewardXP'] as int;
      }
      notifyListeners();
    }
  }

  // --- MULTIPLAYER ROOM ENGINE ---

  // 1. Create Room on Firestore
  Future<String> createRoom(String subject, String studentId, String studentName, {String mode = '1v1'}) async {
    isSearching = true;
    notifyListeners();

    String roomId = "room_${_random.nextInt(8999) + 1000}";
    
    // Choose 10 random questions from bank based on subject or dept
    List<Map<String, dynamic>> pool = _departmentQuestions[subject] ?? _departmentQuestions['GENERAL']!;
    List<Map<String, dynamic>> selectedQuestions = List.from(pool);
    selectedQuestions.shuffle();
    if (selectedQuestions.length > 10) {
      selectedQuestions = selectedQuestions.sublist(0, 10);
    }

    final roomDoc = {
      'roomId': roomId,
      'subject': subject,
      'mode': mode,
      'status': 'waiting',
      'currentQuestionIndex': 0,
      'questions': selectedQuestions,
      'player1': {
        'uid': studentId,
        'name': studentName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.90,
        'answers': [], // list of bools
      },
      'player2': null,
      'player3': null, // For 2v2 Team mode
      'player4': null, // For 2v2 Team mode
      'team1Score': 0,
      'team2Score': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('battle_rooms').doc(roomId).set(roomDoc);
    subscribeToRoom(roomId);
    
    return roomId;
  }

  // 2. Join Room on Firestore
  Future<bool> joinRoom(String roomId, String studentId, String studentName) async {
    isSearching = true;
    notifyListeners();

    DocumentReference ref = _firestore.collection('battle_rooms').doc(roomId);
    DocumentSnapshot snap = await ref.get();

    if (snap.exists) {
      var data = snap.data() as Map<String, dynamic>;
      
      var newPlayer = {
        'uid': studentId,
        'name': studentName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.88,
        'answers': [],
      };

      if (data['mode'] == '1v1' || data['mode'] == 'voice') {
        if (data['status'] == 'waiting' && data['player2'] == null) {
          await ref.update({
            'player2': newPlayer,
            'status': 'countdown' // Trigger countdown for both
          });
          subscribeToRoom(roomId);
          return true;
        }
      } else if (data['mode'] == '2v2') {
        if (data['status'] == 'waiting') {
          if (data['player2'] == null) {
            await ref.update({'player2': newPlayer});
          } else if (data['player3'] == null) {
            await ref.update({'player3': newPlayer});
          } else if (data['player4'] == null) {
            await ref.update({
              'player4': newPlayer,
              'status': 'countdown'
            });
          }
          subscribeToRoom(roomId);
          return true;
        }
      }
    }

    isSearching = false;
    notifyListeners();
    return false;
  }

  // 3. Listen to Active Room changes
  void subscribeToRoom(String roomId) {
    _roomSub?.cancel();
    _roomSub = _firestore.collection('battle_rooms').doc(roomId).snapshots().listen((snap) {
      if (snap.exists) {
        activeRoom = snap.data();
        isSearching = false;
        notifyListeners();
      }
    });
  }

  // 4. Submit Answer during battle
  Future<void> submitAnswer(String studentId, int questionIndex, bool isCorrect, double responseTime, double focusVal) async {
    if (activeRoom == null) return;
    String roomId = activeRoom!['roomId'];
    DocumentReference ref = _firestore.collection('battle_rooms').doc(roomId);

    Map<String, dynamic> room = Map.from(activeRoom!);
    bool isPlayer1 = room['player1']['uid'] == studentId;

    String playerKey = isPlayer1 ? 'player1' : 'player2';
    var player = Map<String, dynamic>.from(room[playerKey]);

    List<dynamic> answers = List.from(player['answers']);
    if (answers.length > questionIndex) return; // Already answered this

    answers.add(isCorrect);
    
    // Score Calculation:
    // Base correct = 10 pts.
    // Reaction Speed Bonus: if answered within 2s +5 pts.
    int pts = 0;
    if (isCorrect) {
      pts = 10;
      if (responseTime < 2.0) pts += 5;
    }

    player['score'] = (player['score'] as int) + pts;
    player['answers'] = answers;
    
    // Recalculate average speed & accuracy
    int totalAnswers = answers.length;
    int correctCount = answers.where((a) => a == true).length;
    player['accuracy'] = ((correctCount / totalAnswers) * 100).toInt();
    
    double prevSpeed = player['speed']?.toDouble() ?? 0.0;
    player['speed'] = (prevSpeed * (totalAnswers - 1) + responseTime) / totalAnswers;
    player['focus'] = focusVal;

    // Update locally
    room[playerKey] = player;

    // Check if both answered current question
    var opponentKey = isPlayer1 ? 'player2' : 'player1';
    var opponent = room[opponentKey];

    bool opponentAnswered = opponent != null && (opponent['answers'] as List).length > questionIndex;
    int nextIndex = room['currentQuestionIndex'];

    if (opponentAnswered || room['status'] == 'bot_active') {
      // Both answered (or playing against bot), advance question index
      nextIndex = questionIndex + 1;
      if (nextIndex >= 10) {
        room['status'] = 'completed';
      }
    }

    await ref.update({
      playerKey: player,
      'currentQuestionIndex': nextIndex,
      'status': room['status'],
    });
  }

  // 5. Leave Room / Clear State
  void leaveRoom() {
    _roomSub?.cancel();
    activeRoom = null;
    isSearching = false;
    notifyListeners();
  }

  // --- LOCAL AI BOT BATTLE SIMULATOR ---
  void startBotBattle(String difficulty, String studentId, String studentName) {
    isSearching = true;
    notifyListeners();

    // Select questions
    List<Map<String, dynamic>> pool = _departmentQuestions['GENERAL']!;
    List<Map<String, dynamic>> selectedQuestions = List.from(pool);
    selectedQuestions.shuffle();
    if (selectedQuestions.length > 10) {
      selectedQuestions = selectedQuestions.sublist(0, 10);
    }

    String botName = "Neuro-Bot v1.0";
    double botAccuracy = 0.50; // Easy
    double minSpeed = 3.0;
    double maxSpeed = 6.0;

    if (difficulty == 'Medium') {
      botName = "Cognitive-Cortex";
      botAccuracy = 0.70;
      minSpeed = 2.0;
      maxSpeed = 4.5;
    } else if (difficulty == 'Hard') {
      botName = "Cybernetic-Brain";
      botAccuracy = 0.88;
      minSpeed = 1.2;
      maxSpeed = 3.0;
    } else if (difficulty == 'Expert') {
      botName = "Alpha-Synapse AI";
      botAccuracy = 0.96;
      minSpeed = 0.6;
      maxSpeed = 1.8;
    }

    activeRoom = {
      'roomId': 'local_bot_match',
      'subject': 'AI Neural Training',
      'status': 'bot_active',
      'currentQuestionIndex': 0,
      'questions': selectedQuestions,
      'player1': {
        'uid': studentId,
        'name': studentName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.92,
        'answers': [],
      },
      'player2': {
        'uid': 'ai_bot_opponent',
        'name': botName,
        'score': 0,
        'accuracy': 0,
        'speed': 0.0,
        'focus': 0.95,
        'answers': [],
      },
      'bot_params': {
        'accuracy': botAccuracy,
        'minSpeed': minSpeed,
        'maxSpeed': maxSpeed,
      }
    };

    isSearching = false;
    notifyListeners();

    // Start bot solver trigger
    _runBotSimulation();
  }

  void _runBotSimulation() async {
    while (activeRoom != null && activeRoom!['status'] == 'bot_active') {
      int currIdx = activeRoom!['currentQuestionIndex'];
      if (currIdx >= 10) {
        activeRoom!['status'] = 'completed';
        notifyListeners();
        break;
      }

      var bot = activeRoom!['player2'];
      List<dynamic> botAnswers = List.from(bot['answers']);
      
      // If bot hasn't answered current index yet
      if (botAnswers.length <= currIdx) {
        var params = activeRoom!['bot_params'];
        double speedSec = params['minSpeed'] + _random.nextDouble() * (params['maxSpeed'] - params['minSpeed']);
        
        await Future.delayed(Duration(milliseconds: (speedSec * 1000).toInt()));
        
        if (activeRoom == null || activeRoom!['status'] != 'bot_active' || activeRoom!['currentQuestionIndex'] != currIdx) {
          continue;
        }

        // Generate bot answer correctness
        bool botCorrect = _random.nextDouble() < params['accuracy'];
        botAnswers.add(botCorrect);
        
        int botPts = 0;
        if (botCorrect) {
          botPts = 10;
          if (speedSec < 2.0) botPts += 5;
        }

        bot['score'] = (bot['score'] as int) + botPts;
        bot['answers'] = botAnswers;
        
        int total = botAnswers.length;
        int corrects = botAnswers.where((a) => a == true).length;
        bot['accuracy'] = ((corrects / total) * 100).toInt();
        
        double prevS = bot['speed']?.toDouble() ?? 0.0;
        bot['speed'] = (prevS * (total - 1) + speedSec) / total;

        activeRoom!['player2'] = bot;
        
        // If player 1 also answered, we advance index
        var player1 = activeRoom!['player1'];
        if ((player1['answers'] as List).length > currIdx) {
          activeRoom!['currentQuestionIndex'] = currIdx + 1;
          if (activeRoom!['currentQuestionIndex'] >= 10) {
            activeRoom!['status'] = 'completed';
          }
        }
        notifyListeners();
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // --- POST-MATCH REWARDS DISPATCH ---
  Future<Map<String, dynamic>> finalizeMatchRewards(String studentId, bool didUserWin, int userScore, int userAccuracy, double userSpeed) async {
    int earnedXP = 50 + (userScore * 1.5).toInt();
    int earnedCoins = 20 + (userScore * 0.8).toInt();
    int rpChange = didUserWin ? 25 : -10;

    if (didUserWin) {
      earnedXP += 100; // Win bonus
      earnedCoins += 50;
      winStreak += 1;
      
      // Update Quests progress
      incrementQuestProgress('win_bot', 1);
    } else {
      winStreak = 0;
    }

    if (userAccuracy > 85) {
      incrementQuestProgress('high_acc', 1);
    }
    
    // Unlock achievements
    if (winStreak == 1) unlockAchievement('first_win');
    if (winStreak == 10) unlockAchievement('10_wins');

    xp += earnedXP;
    coins += earnedCoins;
    rankPoints = (rankPoints + rpChange).clamp(0, 5000);

    // Save final stats to Firestore
    try {
      final studentRef = _firestore.collection(DatabaseService.colStudents).doc(studentId);
      final profileSnap = await studentRef.get();
      if (profileSnap.exists) {
        var profile = profileSnap.data() as Map<String, dynamic>;
        
        // Recalculate cognitive score based on match performance
        double prevCognitive = profile['cognitiveScore']?.toDouble() ?? 90.0;
        // Accuracy and speed feed into new cognitive score
        double matchCognitiveContribution = (userAccuracy * 0.7) + ((10.0 - userSpeed.clamp(1.0, 10.0)) * 3.0);
        double finalCognitive = (prevCognitive * 0.95) + (matchCognitiveContribution * 0.05);

        await studentRef.update({
          'cognitiveScore': double.parse(finalCognitive.toStringAsFixed(1)),
          'learningStreak': didUserWin ? (profile['learningStreak'] ?? 0) + 1 : profile['learningStreak'],
        });

        // Add cognitive score history log
        await _firestore.collection(DatabaseService.colCognitiveScores).add({
          'studentId': studentId,
          'score': double.parse(finalCognitive.toStringAsFixed(1)),
          'attendanceVal': profile['attendanceRate'] ?? 95.0,
          'quizVal': userAccuracy.toDouble(),
          'focusVal': 0.92,
          'activityVal': (userScore * 2.0).clamp(0, 100),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("BattleProvider: Error writing rewards to Firestore: $e");
    }

    notifyListeners();
    
    return {
      'xp': earnedXP,
      'coins': earnedCoins,
      'rp': rpChange,
      'winStreak': winStreak,
    };
  }

  // --- DEPARTMENT MATCH STANDINGS UPDATE ---
  void logDepartmentWarMatch(String userDept, String opponentDept, bool didUserWin) {
    if (didUserWin) {
      departmentScores[userDept] = (departmentScores[userDept] ?? 0) + 30;
    } else {
      departmentScores[opponentDept] = (departmentScores[opponentDept] ?? 0) + 30;
      departmentScores[userDept] = (departmentScores[userDept] ?? 0) + 10; // consolidation points
    }
    notifyListeners();
  }
}
