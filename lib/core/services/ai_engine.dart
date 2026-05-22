import 'dart:math' as math;

class AIEngine {
  // 1. Cognitive Calculator
  // Inputs: attendance (0-100), quiz score (0-100), focus (0-100), activity (0-100)
  // Outputs: cognitive score + insights + prediction
  static Map<String, dynamic> calculateCognitiveStatus({
    required double attendance,
    required double quizScore,
    required double focusLevel,
    required double activityScore,
  }) {
    // Multi-variable weighted cognitive index calculation
    // Attendance (20%), quiz score (30%), focus (30%), activity (20%)
    double score = (attendance * 0.2) + (quizScore * 0.3) + (focusLevel * 0.3) + (activityScore * 0.2);
    score = score.clamp(0, 100);

    String insight = "Cognitive balance is optimal. Keep up the steady engagement.";
    if (score > 90) {
      insight = "Excellent cognitive focus. Your synapses are firing in deep learning state.";
    } else if (score < 60) {
      insight = "Cognitive saturation alert. Consider taking a structured focus break.";
    } else if (focusLevel < 70) {
      insight = "Slight attention drift detected. Try changing study environments.";
    }

    String prediction = "Stable - projected to maintain a high level of academic understanding.";
    if (score < 70) {
      prediction = "At-risk of cognitive fatigue. Study intervals should be scheduled.";
    } else if (score > 92) {
      prediction = "High success trajectory. Likely to achieve top percentile outcomes.";
    }

    return {
      'score': double.parse(score.toStringAsFixed(1)),
      'insight': insight,
      'prediction': prediction,
    };
  }

  // 2. Memory Analyzer (Forgetting probability calculation)
  // Formula: R = e^(-t / S), S = stability = revisionCount * 1.5 + 1.0
  // Forgetting probability = 1.0 - R
  static Map<String, dynamic> analyzeMemoryStability({
    required DateTime lastStudied,
    required int revisionCount,
  }) {
    int daysElapsed = DateTime.now().difference(lastStudied).inDays;
    if (daysElapsed < 0) daysElapsed = 0;

    double stability = (revisionCount * 1.5) + 1.0;
    double retention = math.exp(-daysElapsed / stability);
    double forgettingProbability = 1.0 - retention;

    retention = (retention * 100).clamp(0, 100);
    forgettingProbability = (forgettingProbability * 100).clamp(0, 100);

    String actionRequired = "No immediate revision needed.";
    if (retention < 60) {
      actionRequired = "High decay risk! Immediate review recommended to anchor knowledge.";
    } else if (retention < 80) {
      actionRequired = "Moderate decay. Schedule a brief recap session soon.";
    }

    return {
      'retentionPercent': double.parse(retention.toStringAsFixed(1)),
      'forgettingPercent': double.parse(forgettingProbability.toStringAsFixed(1)),
      'stabilityIndex': stability,
      'actionRequired': actionRequired,
    };
  }

  // 3. Burnout Analyzer
  // Inputs: study duration (hours), inactivity (minutes), productivity score (0-100)
  static Map<String, dynamic> analyzeBurnout({
    required double studyDurationMinutes,
    required double inactivityMinutes,
    required double productivityScore,
  }) {
    // Normalise factors
    double durationWeight = (studyDurationMinutes / 480).clamp(0, 1); // 8 hours max
    double inactivityWeight = (inactivityMinutes / 120).clamp(0, 1); // 2 hours max
    double productivityWeight = (1 - (productivityScore / 100)).clamp(0, 1);

    // Calculate probability (longer study + low productivity + very low inactivity = higher burnout)
    double probability = (durationWeight * 0.45) + (inactivityWeight * 0.15) + (productivityWeight * 0.40);
    probability = (probability * 100).clamp(0, 100);

    String riskLevel = "Low Risk";
    String recoveryRecommendation = "Continue regular study cycles. You are pacing well.";
    if (probability > 75) {
      riskLevel = "Critical Risk";
      recoveryRecommendation = "High burnout risk. Take a complete 30-minute screen-free break. Engage in a calming activity.";
    } else if (probability > 50) {
      riskLevel = "Moderate Risk";
      recoveryRecommendation = "Pacing is slightly off. Shift to pomodoro (25 mins study, 5 mins rest) to restore cognitive energy.";
    }

    return {
      'probability': double.parse(probability.toStringAsFixed(1)),
      'riskLevel': riskLevel,
      'recoveryRecommendation': recoveryRecommendation,
    };
  }

  // 4. Placement Predictor
  // Inputs: user skills list, target role skills list, CGPA, aptitude test score (0-100)
  static Map<String, dynamic> predictPlacement({
    required List<String> userSkills,
    required List<String> targetRoleSkills,
    required double cgpa,
    required double aptitudeScore,
  }) {
    if (targetRoleSkills.isEmpty) {
      targetRoleSkills = ['Python', 'SQL', 'Machine Learning', 'Data Visualizations'];
    }

    // Skills match calculation
    int matchedSkillsCount = 0;
    List<String> missingSkills = [];

    for (var skill in targetRoleSkills) {
      bool matched = false;
      for (var userSkill in userSkills) {
        if (userSkill.trim().toLowerCase() == skill.trim().toLowerCase()) {
          matched = true;
          break;
        }
      }
      if (matched) {
        matchedSkillsCount++;
      } else {
        missingSkills.add(skill);
      }
    }

    double skillMatchRatio = targetRoleSkills.isNotEmpty ? matchedSkillsCount / targetRoleSkills.length : 0.0;
    double cgpaFactor = (cgpa / 10.0).clamp(0, 1);
    double aptitudeFactor = (aptitudeScore / 100.0).clamp(0, 1);

    // Dynamic placement score calculation
    double probability = (skillMatchRatio * 0.45) + (cgpaFactor * 0.35) + (aptitudeFactor * 0.20);
    probability = (probability * 100).clamp(0, 100);

    String careerDNAInsight = "Focus on bridging the skill gap to meet role requirements.";
    if (probability > 85) {
      careerDNAInsight = "Excellent placement profile. You match all core competencies for recruitment.";
    } else if (probability > 65) {
      careerDNAInsight = "Strong academic backing, but upgrading targeted skills is advised.";
    }

    return {
      'probability': double.parse(probability.toStringAsFixed(1)),
      'skillsMatchPercent': double.parse((skillMatchRatio * 100).toStringAsFixed(1)),
      'missingSkills': missingSkills,
      'insight': careerDNAInsight,
    };
  }

  // 5. Recommendation Engine
  // Analyzes multiple metrics and provides smart actions
  static List<String> generateSmartRecommendations({
    required double cognitiveScore,
    required double burnoutProbability,
    required double memoryDecayLevel,
  }) {
    List<String> recommendations = [];

    if (burnoutProbability > 65) {
      recommendations.add("Proactive wellness block triggered: take a 20 minute meditation session immediately.");
    }
    if (cognitiveScore < 70) {
      recommendations.add("Attention optimization: Disable social feeds and lock your mobile using the Neural Focus Bubble.");
    }
    if (memoryDecayLevel > 40) {
      recommendations.add("Revision due: Advanced structures and core conceptual definitions decay detected. Revise now.");
    }
    if (recommendations.isEmpty) {
      recommendations.add("Ecosystem status healthy. Enhance your competitive edge by starting a Mock Aptitude challenge.");
    }

    return recommendations;
  }

  // 6. Prediction Engine
  // Extrapolates current trends into term projections
  static Map<String, dynamic> predictAcademicTrend({
    required List<double> cgpaHistory,
    required List<double> attendanceHistory,
  }) {
    double predictedCGPA = 9.0;
    double predictedAttendance = 90.0;

    if (cgpaHistory.isNotEmpty) {
      // Linear regression / extrapolation approximation
      double sumX = 0;
      double sumY = 0;
      double sumXY = 0;
      double sumX2 = 0;
      int n = cgpaHistory.length;

      for (int i = 0; i < n; i++) {
        sumX += i;
        sumY += cgpaHistory[i];
        sumXY += i * cgpaHistory[i];
        sumX2 += i * i;
      }

      double denominator = (n * sumX2) - (sumX * sumX);
      if (denominator != 0) {
        double m = ((n * sumXY) - (sumX * sumY)) / denominator;
        predictedCGPA = cgpaHistory.last + m;
      } else {
        predictedCGPA = cgpaHistory.last;
      }
    }

    if (attendanceHistory.isNotEmpty) {
      predictedAttendance = attendanceHistory.reduce((a, b) => a + b) / attendanceHistory.length;
    }

    return {
      'projectedCGPA': double.parse(predictedCGPA.clamp(0.0, 10.0).toStringAsFixed(2)),
      'projectedAttendance': double.parse(predictedAttendance.clamp(0.0, 100.0).toStringAsFixed(1)),
      'trajectory': predictedCGPA > 8.5 ? "Top Tier Growth" : (predictedCGPA > 7.0 ? "Stable Growth" : "Recovery Required"),
    };
  }
}
