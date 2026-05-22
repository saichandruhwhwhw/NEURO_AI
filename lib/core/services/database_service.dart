import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection names
  static const String colUsers = 'users';
  static const String colStudents = 'students';
  static const String colFaculty = 'faculty';
  static const String colAdmin = 'admin';
  static const String colAttendance = 'attendance';
  static const String colCognitiveScores = 'cognitive_scores';
  static const String colFocusLogs = 'focus_logs';
  static const String colMemoryData = 'memory_data';
  static const String colBurnoutData = 'burnout_data';
  static const String colPlacementData = 'placement_data';
  static const String colSkills = 'skills';
  static const String colRecommendations = 'recommendations';
  static const String colReports = 'reports';
  static const String colNotifications = 'notifications';
  static const String colTimetables = 'timetables';

  // --- Generic Helpers ---
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }

  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _db.collection(collection).snapshots();
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _db.collection(collection).doc(docId).get();
  }

  // --- Student Seed Logic ---
  Future<void> seedInitialStudentData(String uid, String email, String fullName, String studentId, String department, String year) async {
    try {
      debugPrint("DatabaseService: Seeding initial data for student: $uid");

      // 1. users and students profile
      final studentProfile = {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'studentId': studentId,
        'department': department,
        'year': year,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'cognitiveScore': 94.2,
        'focusLevel': 88.0,
        'attendanceRate': 95.0,
        'learningStreak': 14,
        'cognitiveRank': 3,
        'cgpa': 9.2,
        'targetRole': 'Data Scientist',
      };

      await setDocument(colUsers, uid, studentProfile);
      await setDocument(colStudents, uid, studentProfile);

      // 2. Seed cognitive_scores history for the trend charts
      final double focusScore = 0.88;
      final double activityScore = 85.0;
      final double quizScore = 90.0;
      final double attendanceVal = 95.0;

      for (int i = 0; i < 5; i++) {
        await addDocument(colCognitiveScores, {
          'studentId': uid,
          'score': 85.0 + (i * 2.1),
          'attendanceVal': attendanceVal,
          'quizVal': quizScore - (5 - i * 2),
          'focusVal': focusScore - (4 - i) * 0.05,
          'activityVal': activityScore + (i * 2),
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5 - i))),
        });
      }

      // 3. Seed focus logs
      await addDocument(colFocusLogs, {
        'studentId': uid,
        'focusScore': 0.88,
        'emotion': 'Focused',
        'engagementScore': 0.90,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. Seed memory retention topics
      final topics = [
        {'topic': 'Quantum Mechanics Intro', 'lastStudied': 2, 'revisions': 3},
        {'topic': 'Advanced Data Structures', 'lastStudied': 4, 'revisions': 1},
        {'topic': 'AI Optimization Models', 'lastStudied': 1, 'revisions': 5},
      ];

      for (var t in topics) {
        await addDocument(colMemoryData, {
          'studentId': uid,
          'topic': t['topic'],
          'lastStudied': Timestamp.fromDate(DateTime.now().subtract(Duration(days: t['lastStudied'] as int))),
          'revisionCount': t['revisions'],
          'decayRate': 0.15,
          'forgettingProbability': 0.22,
          'reminders': ['Review before class tomorrow'],
        });
      }

      // 5. Seed burnout telemetry
      await setDocument(colBurnoutData, uid, {
        'studentId': uid,
        'studyDurationMinutes': 240,
        'inactivityMinutes': 30,
        'productivityScore': 85.0,
        'burnoutProbability': 0.35,
        'recoveryRecommended': 'Practice mindfulness for 15 minutes',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 6. Seed placement analytics
      await setDocument(colPlacementData, uid, {
        'studentId': uid,
        'resumeUrl': 'sample_resume.pdf',
        'parsedSkills': ['Python', 'SQL', 'TensorFlow', 'Data Visualizations'],
        'aptitudeScore': 85,
        'placementProbability': 0.82,
        'careerSuggestions': ['AI Research Associate', 'Quantitative Analyst', 'Data Engineer'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 7. Seed master skills comparison
      await setDocument(colSkills, uid, {
        'studentId': uid,
        'skillsList': ['Python', 'SQL', 'TensorFlow', 'Data Visualizations'],
        'targetRole': 'Data Scientist',
        'missingSkills': ['Machine Learning Deployment', 'Cloud Architecture', 'Big Data Engineering'],
      });

      // 8. Seed recommendations
      await addDocument(colRecommendations, {
        'studentId': uid,
        'recommendationText': 'Increase revision intervals for Advanced Data Structures to combat memory decay.',
        'type': 'academic',
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await addDocument(colRecommendations, {
        'studentId': uid,
        'recommendationText': 'High continuous screen activity detected. Take a 10-minute focus break.',
        'type': 'wellness',
        'isCompleted': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 9. Seed notifications
      await addDocument(colNotifications, {
        'userId': uid,
        'message': 'Welcome to NeuroLearn AI command node. Setup complete.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 10. Seed timetable
      await setDocument(colTimetables, uid, {
        'studentId': uid,
        'schedule': {
          'Monday': [
            {'time': '09:00 - 10:30', 'subject': 'Quantum Computing', 'room': 'Lab Alpha'},
            {'time': '11:00 - 12:30', 'subject': 'Neural Networks', 'room': 'Lecture Hall B'},
          ],
          'Tuesday': [
            {'time': '10:00 - 11:30', 'subject': 'Cloud Engineering', 'room': 'Virtual Sandbox'},
            {'time': '13:00 - 14:30', 'subject': 'Cyber Security', 'room': 'Security Suite'},
          ],
          'Wednesday': [
            {'time': '09:00 - 10:30', 'subject': 'Quantum Computing', 'room': 'Lab Alpha'},
            {'time': '14:00 - 15:30', 'subject': 'AI Capstone Project', 'room': 'Nexus Room'},
          ],
          'Thursday': [
            {'time': '11:00 - 12:30', 'subject': 'Neural Networks', 'room': 'Lecture Hall B'},
            {'time': '13:00 - 14:30', 'subject': 'Cyber Security', 'room': 'Security Suite'},
          ],
          'Friday': [
            {'time': '10:00 - 11:30', 'subject': 'Cloud Engineering', 'room': 'Virtual Sandbox'},
            {'time': '14:00 - 15:30', 'subject': 'AI Ethics & Seminars', 'room': 'Auditorium C'},
          ],
        }
      });

      debugPrint("DatabaseService: Seeding completed successfully.");
    } catch (e) {
      debugPrint("DatabaseService: Error seeding student data: $e");
    }
  }

  // --- Specific CRUD operations ---
  Future<void> submitAttendance(String studentId, String studentName, String courseId, String status) async {
    await addDocument(colAttendance, {
      'studentId': studentId,
      'studentName': studentName,
      'courseId': courseId,
      'status': status,
      'date': Timestamp.now(),
    });
  }

  Future<void> submitQuizScore(String studentId, String courseId, double score) async {
    await addDocument(colReports, {
      'studentId': studentId,
      'courseId': courseId,
      'score': score,
      'type': 'academic_quiz',
      'timestamp': Timestamp.now(),
    });
  }
}
