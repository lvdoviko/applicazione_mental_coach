import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'wearable_snapshot.g.dart';

/// Complete health snapshot aggregated from wearable devices
/// Follows the JSON schema defined for backend integration
@JsonSerializable(explicitToJson: true)
class WearableSnapshot extends Equatable {
  /// SHA256 hash of user ID for privacy
  @JsonKey(name: 'user_id_hash')
  final String userIdHash;
  
  /// ISO 8601 timestamp of snapshot generation
  final DateTime timestamp;
  
  /// Time window for aggregation (24h, 72h, 7d, custom)
  final String window;
  
  /// Sleep-related metrics
  final SleepMetrics sleep;
  
  /// Physiological metrics (HR, HRV, etc.)
  final PhysiologicalMetrics physio;
  
  /// Training and activity metrics
  final TrainingMetrics training;
  
  /// Self-reported metrics from user
  @JsonKey(name: 'self_report')
  final SelfReportMetrics selfReport;
  
  /// Contextual information
  final ContextMetrics context;
  
  /// Health flags and alerts
  final List<String> flags;
  
  /// Natural language summary for AI context
  @JsonKey(name: 'summary_text')
  final String summaryText;
  
  /// Pinecone vector database ID
  @JsonKey(name: 'pinecone_id', includeIfNull: false)
  final String? pineconeId;

  const WearableSnapshot({
    required this.userIdHash,
    required this.timestamp,
    required this.window,
    required this.sleep,
    required this.physio,
    required this.training,
    required this.selfReport,
    required this.context,
    required this.flags,
    required this.summaryText,
    this.pineconeId,
  });

  /// Factory constructor from JSON
  factory WearableSnapshot.fromJson(Map<String, dynamic> json) =>
      _$WearableSnapshotFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$WearableSnapshotToJson(this);

  /// Validate snapshot data integrity
  bool isValid() {
    try {
      // Validate user ID hash format (SHA256)
      if (!RegExp(r'^sha256:[a-f0-9]{64}$').hasMatch(userIdHash)) {
        return false;
      }

      // Validate window enum
      const validWindows = ['24h', '72h', '7d', 'custom'];
      if (!validWindows.contains(window)) {
        return false;
      }

      // Validate timestamp is not in future
      if (timestamp.isAfter(DateTime.now())) {
        return false;
      }

      // Validate summary text is not empty
      if (summaryText.trim().isEmpty) {
        return false;
      }

      // Validate sub-models
      return sleep.isValid() && 
             physio.isValid() && 
             training.isValid() && 
             selfReport.isValid() && 
             context.isValid();
    } catch (e) {
      return false;
    }
  }

  /// Generate AI context map for RAG integration
  Map<String, dynamic> toAIContext() {
    return {
      'vital_signs': {
        'resting_heart_rate': physio.restingHr,
        'heart_rate_variability': physio.hrvRmssd,
        'hrv_baseline_percentage': physio.hrvDeltaPct,
        'stress_indicators': physio.getStressScore(),
      },
      'sleep_quality': {
        'average_hours': sleep.avgHours,
        'efficiency': sleep.efficiency,
        'quality_trend': sleep.getQualityTrend(),
        'consecutive_poor_nights': sleep.getPoorSleepStreak(),
      },
      'training_load': {
        'weekly_load': training.weeklyLoad,
        'last_session_intensity': training.lastSession?.intensity ?? 0,
        'recovery_needed': training.isRecoveryNeeded(),
      },
      'mental_state': {
        'mood_score': selfReport.mood,
        'anxiety_level': selfReport.anxiety,
        'stress_perception': selfReport.stressLevel ?? 0,
      },
      'context_factors': {
        'days_to_competition': context.daysToCompetition,
        'travel_fatigue': context.travelFlag,
        'sleep_debt': sleep.getSleepDebt(),
      },
      'health_alerts': flags,
      'summary': summaryText,
      'risk_assessment': _calculateRiskLevel(),
      'recommendations': _generateRecommendations(),
    };
  }

  /// Calculate numerical risk score
  int _calculateRiskScore() {
    int riskScore = 0;
    
    // Sleep risk factors
    if (sleep.avgHours < 6.0) {
      riskScore += 3;
    } else if (sleep.avgHours < 7.0) riskScore += 1;
    
    if (sleep.efficiency < 80) riskScore += 2;
    
    // HRV risk factors
    if (physio.hrvDeltaPct < -20) {
      riskScore += 3;
    } else if (physio.hrvDeltaPct < -10) riskScore += 1;
    
    // Mental state risk factors
    if (selfReport.anxiety >= 8) {
      riskScore += 3;
    } else if (selfReport.anxiety >= 6) riskScore += 1;
    
    if (selfReport.mood <= 2) riskScore += 2;
    
    // Competition pressure
    if (context.daysToCompetition != null && context.daysToCompetition! <= 1 && riskScore > 2) riskScore += 1;
    
    return riskScore;
  }

  /// Calculate overall risk level based on metrics
  String _calculateRiskLevel() {
    final riskScore = _calculateRiskScore();
    
    if (riskScore >= 6) return 'high';
    if (riskScore >= 3) return 'moderate';
    return 'low';
  }

  /// Generate contextual recommendations
  List<String> _generateRecommendations() {
    List<String> recommendations = [];
    
    // Sleep recommendations
    if (sleep.avgHours < 7.0) {
      recommendations.add('Consider improving sleep duration - aim for 7-9 hours nightly');
    }
    
    if (sleep.efficiency < 85) {
      recommendations.add('Focus on sleep quality - consider sleep hygiene techniques');
    }
    
    // HRV recommendations
    if (physio.hrvDeltaPct < -15) {
      recommendations.add('HRV indicates elevated stress - consider active recovery');
    }
    
    // Mental state recommendations
    if (selfReport.anxiety >= 7) {
      recommendations.add('High anxiety detected - breathing exercises or mindfulness may help');
    }
    
    // Competition-specific
    if (context.daysToCompetition != null && context.daysToCompetition! <= 2 && _calculateRiskScore() >= 3) {
      recommendations.add('Pre-competition stress management recommended');
    }
    
    return recommendations;
  }

  @override
  List<Object?> get props => [
        userIdHash,
        timestamp,
        window,
        sleep,
        physio,
        training,
        selfReport,
        context,
        flags,
        summaryText,
        pineconeId,
      ];

  /// Generate privacy-preserving AI summary for backend processing
  String generateAISummary() {
    final buffer = StringBuffer();
    
    // Time context
    buffer.writeln('Health Summary ($window):');
    
    // Sleep metrics
    buffer.writeln('Sleep: ${sleep.avgHours.toStringAsFixed(1)}h avg, ${sleep.efficiency}% efficiency');
    if (sleep.deepSleepPct != null) {
      buffer.writeln('Deep sleep: ${sleep.deepSleepPct!.toStringAsFixed(1)}%');
    }
    
    // HRV and physiological state
    buffer.writeln('HRV: ${physio.hrvDeltaPct.toStringAsFixed(1)}% vs baseline');
    buffer.writeln('Resting HR: ${physio.restingHr}bpm (${physio.restingHrDeltaVsWeek.toStringAsFixed(1)} vs week)');
    
    // Training load
    buffer.writeln('Training load: ${training.weeklyLoad.toStringAsFixed(1)}');
    if (training.dailySteps != null) {
      buffer.writeln('Daily steps: ${training.dailySteps}');
    }
    
    // Self-reported state
    buffer.writeln('Energy: ${selfReport.energyLevel ?? 0}/5, Stress: ${selfReport.stressLevel ?? 0}/10');
    buffer.writeln('Mood: ${selfReport.mood}/10, Motivation: ${selfReport.motivation}/10');
    
    // Context
    if (context.daysToCompetition != null) {
      buffer.writeln('Days to competition: ${context.daysToCompetition}');
    }
    
    // Risk indicators
    if (flags.isNotEmpty) {
      buffer.writeln('Alerts: ${flags.join(", ")}');
    }
    
    return buffer.toString();
  }

  /// Convert to structured features for backend ML processing
  Map<String, dynamic> toStructuredFeatures() {
    return {
      // Sleep features
      'sleep_hours': sleep.avgHours,
      'sleep_efficiency': sleep.efficiency,
      'deep_sleep_minutes': sleep.deepSleepPct != null ? (sleep.deepSleepPct! * sleep.avgHours * 60 / 100).round() : null,
      'sleep_onset_minutes': sleep.onsetMinutes,
      
      // Physiological features
      'resting_hr': physio.restingHr,
      'resting_hr_delta_week': physio.restingHrDeltaVsWeek,
      'hrv_rmssd': physio.hrvRmssd,
      'hrv_delta_pct': physio.hrvDeltaPct,
      'avg_hr': physio.avgHr,
      'spo2': physio.spo2,
      
      // Training features
      'weekly_load': training.weeklyLoad,
      'daily_steps': training.dailySteps,
      'active_calories': training.activeCalories,
      'sessions_this_week': training.sessionsThisWeek,
      
      // Self-report features
      'energy_level': selfReport.energyLevel,
      'stress_level': selfReport.stressLevel,
      'mood_score': selfReport.mood,
      'motivation_level': selfReport.motivation,
      'anxiety_level': selfReport.anxiety,
      'sleep_quality_perceived': selfReport.sleepQualityPerceived,
      
      // Context features
      'days_to_competition': context.daysToCompetition,
      'travel_flag': context.travelFlag,
      'timezone_changes': context.timezoneChanges,
      'external_stress': context.externalStress,
      'health_issues_count': context.healthIssues?.length ?? 0,
      
      // Risk indicators
      'risk_score': _calculateRiskScore(),
      'alert_flags': flags,
      'risk_level': _calculateRiskLevel(),
    };
  }

  /// Copy with method for updates
  WearableSnapshot copyWith({
    String? userIdHash,
    DateTime? timestamp,
    String? window,
    SleepMetrics? sleep,
    PhysiologicalMetrics? physio,
    TrainingMetrics? training,
    SelfReportMetrics? selfReport,
    ContextMetrics? context,
    List<String>? flags,
    String? summaryText,
    String? pineconeId,
  }) {
    return WearableSnapshot(
      userIdHash: userIdHash ?? this.userIdHash,
      timestamp: timestamp ?? this.timestamp,
      window: window ?? this.window,
      sleep: sleep ?? this.sleep,
      physio: physio ?? this.physio,
      training: training ?? this.training,
      selfReport: selfReport ?? this.selfReport,
      context: context ?? this.context,
      flags: flags ?? this.flags,
      summaryText: summaryText ?? this.summaryText,
      pineconeId: pineconeId ?? this.pineconeId,
    );
  }
}

/// Sleep-related health metrics
@JsonSerializable(explicitToJson: true)
class SleepMetrics extends Equatable {
  /// Average sleep hours in the time window
  @JsonKey(name: 'avg_hours')
  final double avgHours;
  
  /// Sleep efficiency percentage (0-100)
  final double efficiency;
  
  /// Individual night sleep hours
  @JsonKey(name: 'last_nights_hours')
  final List<double> lastNightsHours;
  
  /// Deep sleep percentage
  @JsonKey(name: 'deep_sleep_pct', includeIfNull: false)
  final double? deepSleepPct;
  
  /// REM sleep percentage
  @JsonKey(name: 'rem_sleep_pct', includeIfNull: false)
  final double? remSleepPct;
  
  /// Sleep onset time (minutes to fall asleep)
  @JsonKey(name: 'onset_minutes', includeIfNull: false)
  final int? onsetMinutes;

  const SleepMetrics({
    required this.avgHours,
    required this.efficiency,
    required this.lastNightsHours,
    this.deepSleepPct,
    this.remSleepPct,
    this.onsetMinutes,
  });

  factory SleepMetrics.fromJson(Map<String, dynamic> json) =>
      _$SleepMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SleepMetricsToJson(this);

  bool isValid() {
    return avgHours >= 0 && 
           avgHours <= 24 && 
           efficiency >= 0 && 
           efficiency <= 100 &&
           lastNightsHours.isNotEmpty &&
           lastNightsHours.every((hours) => hours >= 0 && hours <= 24);
  }

  /// Get sleep quality trend over recent nights
  String getQualityTrend() {
    if (lastNightsHours.length < 3) return 'insufficient_data';
    
    final recent = lastNightsHours.take(3).toList();
    final older = lastNightsHours.skip(3).take(3).toList();
    
    if (older.isEmpty) return 'stable';
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    final diff = recentAvg - olderAvg;
    
    if (diff > 0.5) return 'improving';
    if (diff < -0.5) return 'declining';
    return 'stable';
  }

  /// Get consecutive poor sleep nights count
  int getPoorSleepStreak() {
    int streak = 0;
    for (double hours in lastNightsHours) {
      if (hours < 6.0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculate sleep debt in hours
  double getSleepDebt() {
    const optimalSleep = 8.0;
    double debt = 0.0;
    
    for (double hours in lastNightsHours) {
      if (hours < optimalSleep) {
        debt += optimalSleep - hours;
      }
    }
    
    return debt;
  }

  @override
  List<Object?> get props => [
        avgHours,
        efficiency,
        lastNightsHours,
        deepSleepPct,
        remSleepPct,
        onsetMinutes,
      ];
}

/// Physiological health metrics
@JsonSerializable(explicitToJson: true)
class PhysiologicalMetrics extends Equatable {
  /// Resting heart rate (BPM)
  @JsonKey(name: 'resting_hr')
  final double restingHr;
  
  /// Change in resting HR vs weekly baseline
  @JsonKey(name: 'resting_hr_delta_vs_week')
  final double restingHrDeltaVsWeek;
  
  /// Heart rate variability RMSSD (ms)
  @JsonKey(name: 'hrv_rmssd')
  final double hrvRmssd;
  
  /// HRV change as percentage of baseline
  @JsonKey(name: 'hrv_delta_pct')
  final double hrvDeltaPct;
  
  /// Blood oxygen saturation percentage
  @JsonKey(name: 'spo2', includeIfNull: false)
  final double? spo2;
  
  /// Average daily heart rate
  @JsonKey(name: 'avg_hr', includeIfNull: false)
  final double? avgHr;
  
  /// Heart rate during last workout
  @JsonKey(name: 'workout_avg_hr', includeIfNull: false)
  final double? workoutAvgHr;

  const PhysiologicalMetrics({
    required this.restingHr,
    required this.restingHrDeltaVsWeek,
    required this.hrvRmssd,
    required this.hrvDeltaPct,
    this.spo2,
    this.avgHr,
    this.workoutAvgHr,
  });

  factory PhysiologicalMetrics.fromJson(Map<String, dynamic> json) =>
      _$PhysiologicalMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$PhysiologicalMetricsToJson(this);

  bool isValid() {
    return restingHr > 30 && 
           restingHr < 200 && 
           hrvRmssd > 0 &&
           (spo2 == null || (spo2! >= 70 && spo2! <= 100));
  }

  /// Calculate overall stress score based on physio metrics
  int getStressScore() {
    int score = 0;
    
    // Elevated resting HR indicates stress
    if (restingHrDeltaVsWeek > 10) {
      score += 3;
    } else if (restingHrDeltaVsWeek > 5) {
      score += 1;
    }
    
    // Low HRV indicates stress
    if (hrvDeltaPct < -20) {
      score += 3;
    } else if (hrvDeltaPct < -10) {
      score += 1;
    }
    
    // Low SpO2 can indicate stress/fatigue
    if (spo2 != null && spo2! < 95) {
      score += 2;
    }
    
    return score.clamp(0, 10);
  }

  @override
  List<Object?> get props => [
        restingHr,
        restingHrDeltaVsWeek,
        hrvRmssd,
        hrvDeltaPct,
        spo2,
        avgHr,
        workoutAvgHr,
      ];
}

/// Training and activity metrics
@JsonSerializable(explicitToJson: true)
class TrainingMetrics extends Equatable {
  /// Last training session details
  @JsonKey(name: 'last_session', includeIfNull: false)
  final TrainingSession? lastSession;
  
  /// Weekly training load
  @JsonKey(name: 'weekly_load')
  final double weeklyLoad;
  
  /// Daily step count average
  @JsonKey(name: 'daily_steps', includeIfNull: false)
  final int? dailySteps;
  
  /// Active energy burned (calories)
  @JsonKey(name: 'active_calories', includeIfNull: false)
  final double? activeCalories;
  
  /// Training sessions count this week
  @JsonKey(name: 'sessions_this_week', includeIfNull: false)
  final int? sessionsThisWeek;

  const TrainingMetrics({
    this.lastSession,
    required this.weeklyLoad,
    this.dailySteps,
    this.activeCalories,
    this.sessionsThisWeek,
  });

  factory TrainingMetrics.fromJson(Map<String, dynamic> json) =>
      _$TrainingMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingMetricsToJson(this);

  bool isValid() {
    return weeklyLoad >= 0 && 
           (dailySteps == null || dailySteps! >= 0) &&
           (activeCalories == null || activeCalories! >= 0);
  }

  /// Determine if recovery is needed based on training load
  bool isRecoveryNeeded() {
    // High weekly load threshold
    if (weeklyLoad > 800) return true;
    
    // Recent high-intensity session
    if (lastSession?.intensity != null && lastSession!.intensity > 8) {
      return true;
    }
    
    return false;
  }

  @override
  List<Object?> get props => [
        lastSession,
        weeklyLoad,
        dailySteps,
        activeCalories,
        sessionsThisWeek,
      ];
}

/// Individual training session data
@JsonSerializable(explicitToJson: true)
class TrainingSession extends Equatable {
  /// Session type (strength, cardio, sport-specific, etc.)
  final String type;
  
  /// Duration in minutes
  @JsonKey(name: 'duration_min')
  final int durationMin;
  
  /// Perceived exertion (1-10 scale)
  final int intensity;
  
  /// When the session occurred
  final DateTime timestamp;
  
  /// Sport-specific details
  final Map<String, dynamic>? details;

  const TrainingSession({
    required this.type,
    required this.durationMin,
    required this.intensity,
    required this.timestamp,
    this.details,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);

  @override
  List<Object?> get props => [type, durationMin, intensity, timestamp, details];
}

/// Self-reported metrics from the athlete
@JsonSerializable(explicitToJson: true)
class SelfReportMetrics extends Equatable {
  /// Mood score (1-5 scale, 5 being best)
  final int mood;
  
  /// Anxiety level (0-10 scale, 10 being highest)
  final int anxiety;
  
  /// Perceived stress level (0-10 scale)
  @JsonKey(name: 'stress_level', includeIfNull: false)
  final int? stressLevel;
  
  /// Energy level (1-5 scale)
  @JsonKey(name: 'energy_level', includeIfNull: false)
  final int? energyLevel;
  
  /// Motivation level (1-5 scale)
  @JsonKey(name: 'motivation', includeIfNull: false)
  final int? motivation;
  
  /// Sleep quality perception (1-5 scale)
  @JsonKey(name: 'sleep_quality_perceived', includeIfNull: false)
  final int? sleepQualityPerceived;

  const SelfReportMetrics({
    required this.mood,
    required this.anxiety,
    this.stressLevel,
    this.energyLevel,
    this.motivation,
    this.sleepQualityPerceived,
  });

  factory SelfReportMetrics.fromJson(Map<String, dynamic> json) =>
      _$SelfReportMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SelfReportMetricsToJson(this);

  bool isValid() {
    return mood >= 1 && 
           mood <= 5 && 
           anxiety >= 0 && 
           anxiety <= 10 &&
           (stressLevel == null || (stressLevel! >= 0 && stressLevel! <= 10)) &&
           (energyLevel == null || (energyLevel! >= 1 && energyLevel! <= 5));
  }

  @override
  List<Object?> get props => [
        mood,
        anxiety,
        stressLevel,
        energyLevel,
        motivation,
        sleepQualityPerceived,
      ];
}

/// Contextual metrics that affect performance
@JsonSerializable(explicitToJson: true)
class ContextMetrics extends Equatable {
  /// Days until next competition
  @JsonKey(name: 'days_to_competition', includeIfNull: false)
  final int? daysToCompetition;
  
  /// Whether user has traveled recently
  @JsonKey(name: 'travel_flag')
  final bool travelFlag;
  
  /// Time zone changes in last week
  @JsonKey(name: 'timezone_changes', includeIfNull: false)
  final int? timezoneChanges;
  
  /// Academic/work stress level
  @JsonKey(name: 'external_stress', includeIfNull: false)
  final int? externalStress;
  
  /// Injury or illness status
  @JsonKey(name: 'health_issues', includeIfNull: false)
  final List<String>? healthIssues;

  const ContextMetrics({
    this.daysToCompetition,
    required this.travelFlag,
    this.timezoneChanges,
    this.externalStress,
    this.healthIssues,
  });

  factory ContextMetrics.fromJson(Map<String, dynamic> json) =>
      _$ContextMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ContextMetricsToJson(this);

  bool isValid() {
    return (daysToCompetition == null || daysToCompetition! >= 0) &&
           (timezoneChanges == null || timezoneChanges! >= 0) &&
           (externalStress == null || (externalStress! >= 0 && externalStress! <= 10));
  }

  @override
  List<Object?> get props => [
        daysToCompetition,
        travelFlag,
        timezoneChanges,
        externalStress,
        healthIssues,
      ];
}