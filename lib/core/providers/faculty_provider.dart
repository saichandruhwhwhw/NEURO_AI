import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class FacultyProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> classReports = [];
  bool isLoading = false;

  StreamSubscription? _studentsSub;

  FacultyProvider() {
    _initFacultyData();
  }

  void _initFacultyData() {
    isLoading = true;
    notifyListeners();

    // Stream list of students from Firestore
    _studentsSub = FirebaseFirestore.instance
        .collection(DatabaseService.colStudents)
        .snapshots()
        .listen((snap) {
      students = snap.docs.map((d) {
        var data = d.data();
        data['uid'] = d.id;
        return data;
      }).toList();
      notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _studentsSub?.cancel();
    super.dispose();
  }

  // --- Dynamic Actions ---

  // A. Mark attendance and update student average attendanceRate
  Future<void> logStudentAttendance(String studentId, String studentName, String status) async {
    // status = 'Present', 'Absent', 'Late'
    await _dbService.submitAttendance(studentId, studentName, 'CS-501', status);

    // Calculate new average attendance rate
    // Fetch all attendance for student
    var snap = await FirebaseFirestore.instance
        .collection(DatabaseService.colAttendance)
        .where('studentId', isEqualTo: studentId)
        .get();

    if (snap.docs.isNotEmpty) {
      int total = snap.docs.length;
      int presentCount = snap.docs.where((d) => d.data()['status'] == 'Present' || d.data()['status'] == 'Late').length;
      double newRate = (presentCount / total) * 100.0;

      // Update student profile
      await _dbService.setDocument(DatabaseService.colStudents, studentId, {
        'attendanceRate': double.parse(newRate.toStringAsFixed(1)),
      });
    }
  }

  // B. Enter quiz marks and update student CGPA
  Future<void> submitStudentGrades(String studentId, double marksObtained) async {
    // Log the quiz score in reports
    await _dbService.addDocument(DatabaseService.colReports, {
      'studentId': studentId,
      'quizScore': marksObtained,
      'type': 'quiz_score',
      'courseId': 'CS-501',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Recalculate CGPA (mapping 0-100 marks to 10.0 scale)
    double newCGPA = (marksObtained / 10.0).clamp(0.0, 10.0);

    // Fetch student's current CGPA to smooth it out
    DocumentSnapshot doc = await _dbService.getDocument(DatabaseService.colStudents, studentId);
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      double currentCGPA = data['cgpa']?.toDouble() ?? 9.0;
      // Weighted average: 80% old CGPA + 20% new quiz score
      double updatedCGPA = (currentCGPA * 0.8) + (newCGPA * 0.2);

      await _dbService.setDocument(DatabaseService.colStudents, studentId, {
        'cgpa': double.parse(updatedCGPA.toStringAsFixed(2)),
      });

      // Add a cognitive score node reflecting the quiz result
      double attendance = data['attendanceRate']?.toDouble() ?? 95.0;
      double focus = data['focusLevel']?.toDouble() ?? 85.0;
      double activity = (data['learningStreak'] ?? 14) * 5.0 + 30.0;

      double newCognitiveIndex = (attendance * 0.2) + (marksObtained * 0.3) + (focus * 10.0 * 0.3 * 0.1) + (activity * 0.2);
      newCognitiveIndex = newCognitiveIndex.clamp(0, 100);

      await _dbService.addDocument(DatabaseService.colCognitiveScores, {
        'studentId': studentId,
        'score': double.parse(newCognitiveIndex.toStringAsFixed(1)),
        'attendanceVal': attendance,
        'quizVal': marksObtained,
        'focusVal': focus / 100.0,
        'activityVal': activity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _dbService.setDocument(DatabaseService.colStudents, studentId, {
        'cognitiveScore': double.parse(newCognitiveIndex.toStringAsFixed(1)),
      });
    }
  }

  // C. Upload assignment details
  Future<void> createAssignment(String title, String description, DateTime dueDate) async {
    await _dbService.addDocument(DatabaseService.colReports, {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'type': 'assignment_upload',
      'createdBy': 'Faculty Lead',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify all students
    for (var std in students) {
      await _dbService.addDocument(DatabaseService.colNotifications, {
        'userId': std['uid'],
        'message': "NEW ASSIGNMENT: $title. Submit by ${dueDate.toLocal().toString().substring(0,10)}",
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // D. Proactively trigger student alerts (e.g. attendance warning, focus booster)
  Future<void> sendStudentNotificationAlert(String studentId, String alertMessage) async {
    await _dbService.addDocument(DatabaseService.colNotifications, {
      'userId': studentId,
      'message': "FACULTY ADVISORY: $alertMessage",
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // E. Create Faculty Arena Battle Challenge
  Future<void> createFacultyChallenge(String subject, String challengeName) async {
    await FirebaseFirestore.instance.collection('faculty_challenges').add({
      'subject': subject,
      'challengeName': challengeName,
      'createdBy': 'Prof. Higgins',
      'joinedCount': 8,
      'active': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify all students of the challenge
    for (var std in students) {
      await _dbService.addDocument(DatabaseService.colNotifications, {
        'userId': std['uid'],
        'message': "ARENA CHALLENGE: Prof. Higgins posted '$challengeName'. Join Cognitive Battle Arena now!",
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // F. Compute AI Class Insights
  String calculateClassInsights() {
    if (students.isEmpty) return "Gathering student metrics...";
    double avgCognitive = students.map((s) => s['cognitiveScore']?.toDouble() ?? 0.0).reduce((a, b) => a + b) / students.length;
    double avgAttendance = students.map((s) => s['attendanceRate']?.toDouble() ?? 0.0).reduce((a, b) => a + b) / students.length;

    String rating = avgCognitive > 80 ? "EXCELLENT" : (avgCognitive > 65 ? "STABLE" : "ATTENTION REQUIRED");

    return "Classroom overall index: $rating. Avg Cognitive Score: ${avgCognitive.toStringAsFixed(1)}%. Avg Attendance Rate: ${avgAttendance.toStringAsFixed(1)}%. Core recommendations: Optimize focus times for laboratory sessions.";
  }
}
