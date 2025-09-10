import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/wearable_snapshot.dart';
import '../models/vendor_data_models.dart';

/// Service for aggregating and processing health data from multiple vendors
/// Performs feature engineering and generates standardized snapshots
class HealthAggregatorService {
  
  /// Generate a wearable snapshot from vendor health data
  Future<WearableSnapshot> generateSnapshot(
    Map<String, VendorHealthData> vendorData, {
    String window = '24h',
    String? userId,
  }) async {
    // Generate privacy-preserving user ID hash
    final userIdHash = userId != null 
        ? _generateUserIdHash(userId)
        : 'sha256:anonymous';
    
    // Aggregate data from all vendors
    final aggregatedData = await _aggregateVendorData(vendorData, window);
    
    // Generate summary text for AI context
    final summaryText = _generateSummaryText(aggregatedData, window);
    
    // Generate health flags based on metrics
    final flags = _generateHealthFlags(aggregatedData);
    
    return WearableSnapshot(
      userIdHash: userIdHash,
      timestamp: DateTime.now(),
      window: window,
      sleep: aggregatedData['sleep'] as SleepMetrics,
      physio: aggregatedData['physio'] as PhysiologicalMetrics,
      training: aggregatedData['training'] as TrainingMetrics,
      selfReport: aggregatedData['self_report'] as SelfReportMetrics,
      context: aggregatedData['context'] as ContextMetrics,
      flags: flags,
      summaryText: summaryText,
    );
  }

  /// Calculate health baselines from historical data
  Future<Map<String, double>> calculateBaselines(
    List<WearableSnapshot> historicalSnapshots,
  ) async {
    if (historicalSnapshots.isEmpty) {
      return _getDefaultBaselines();
    }
    
    final baselines = <String, double>{};
    
    // Calculate HRV baseline (7-day rolling average)
    final hrvValues = historicalSnapshots
        .map((s) => s.physio.hrvRmssd)
        .where((v) => v > 0)
        .toList();
    
    if (hrvValues.isNotEmpty) {
      baselines['hrv_rmssd'] = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
    }
    
    // Calculate resting HR baseline
    final rhValues = historicalSnapshots
        .map((s) => s.physio.restingHr)
        .where((v) => v > 0)
        .toList();
    
    if (rhValues.isNotEmpty) {
      baselines['resting_hr'] = rhValues.reduce((a, b) => a + b) / rhValues.length;
    }
    
    // Calculate sleep duration baseline
    final sleepValues = historicalSnapshots
        .map((s) => s.sleep.avgHours)
        .where((v) => v > 0)
        .toList();
    
    if (sleepValues.isNotEmpty) {
      baselines['sleep_hours'] = sleepValues.reduce((a, b) => a + b) / sleepValues.length;
    }
    
    return baselines;
  }

  /// Detect anomalies in health data
  List<String> detectAnomalies(
    WearableSnapshot currentSnapshot,
    List<WearableSnapshot> historicalSnapshots,
  ) {
    final anomalies = <String>[];
    
    if (historicalSnapshots.length < 7) {
      return anomalies; // Need at least a week of data
    }
    
    // HRV anomaly detection
    final hrvValues = historicalSnapshots
        .map((s) => s.physio.hrvRmssd)
        .where((v) => v > 0)
        .toList();
    
    if (hrvValues.isNotEmpty) {
      final mean = hrvValues.reduce((a, b) => a + b) / hrvValues.length;
      final variance = hrvValues
          .map((v) => pow(v - mean, 2))
          .reduce((a, b) => a + b) / hrvValues.length;
      final stdDev = sqrt(variance);
      
      // Flag if current HRV is more than 2 standard deviations below mean
      if (currentSnapshot.physio.hrvRmssd < (mean - 2 * stdDev)) {
        anomalies.add('hrv_significantly_low');
      }
    }
    
    // Resting HR anomaly detection
    final rhValues = historicalSnapshots
        .map((s) => s.physio.restingHr)
        .where((v) => v > 0)
        .toList();
    
    if (rhValues.isNotEmpty) {
      final mean = rhValues.reduce((a, b) => a + b) / rhValues.length;
      final variance = rhValues
          .map((v) => pow(v - mean, 2))
          .reduce((a, b) => a + b) / rhValues.length;
      final stdDev = sqrt(variance);
      
      // Flag if current RHR is more than 2 standard deviations above mean
      if (currentSnapshot.physio.restingHr > (mean + 2 * stdDev)) {
        anomalies.add('resting_hr_significantly_high');
      }
    }
    
    return anomalies;
  }

  /// Generate features for machine learning models
  Map<String, double> extractFeatures(WearableSnapshot snapshot) {
    return {
      // Sleep features
      'sleep_hours': snapshot.sleep.avgHours,
      'sleep_efficiency': snapshot.sleep.efficiency,
      'sleep_debt': snapshot.sleep.getSleepDebt(),
      'poor_sleep_streak': snapshot.sleep.getPoorSleepStreak().toDouble(),
      
      // Physiological features
      'resting_hr': snapshot.physio.restingHr,
      'hrv_rmssd': snapshot.physio.hrvRmssd,
      'hrv_delta_pct': snapshot.physio.hrvDeltaPct,
      'stress_score': snapshot.physio.getStressScore().toDouble(),
      
      // Training features
      'weekly_load': snapshot.training.weeklyLoad,
      'recovery_needed': snapshot.training.isRecoveryNeeded() ? 1.0 : 0.0,
      
      // Self-report features
      'mood_score': snapshot.selfReport.mood.toDouble(),
      'anxiety_level': snapshot.selfReport.anxiety.toDouble(),
      'stress_level': (snapshot.selfReport.stressLevel ?? 0).toDouble(),
      
      // Context features
      'days_to_competition': (snapshot.context.daysToCompetition ?? 30).toDouble(),
      'travel_flag': snapshot.context.travelFlag ? 1.0 : 0.0,
      
      // Derived features
      'health_flag_count': snapshot.flags.length.toDouble(),
      'overall_wellness': _calculateWellnessScore(snapshot),
    };
  }

  // Private methods

  /// Aggregate data from multiple vendors into standardized metrics
  Future<Map<String, dynamic>> _aggregateVendorData(
    Map<String, VendorHealthData> vendorData,
    String window,
  ) async {
    // Initialize aggregation containers
    final heartRateValues = <double>[];
    final hrvValues = <double>[];
    final sleepHours = <double>[];
    final stepCounts = <int>[];
    final workoutSessions = <Map<String, dynamic>>[];
    
    // Process each vendor's data
    for (final vendor in vendorData.entries) {
      final data = vendor.value;
      final standardized = data.toStandardizedMetrics();
      
      // Extract heart rate data
      final hrData = standardized['heart_rate'] as Map<String, dynamic>?;
      if (hrData != null) {
        final avgHr = hrData['avg'] as double?;
        if (avgHr != null && avgHr > 0) {
          heartRateValues.add(avgHr);
        }
      }
      
      // Extract HRV data
      final hrvData = standardized['hrv'] as Map<String, dynamic>?;
      if (hrvData != null) {
        final avgHrv = hrvData['avg_rmssd'] as double?;
        if (avgHrv != null && avgHrv > 0) {
          hrvValues.add(avgHrv);
        }
      }
      
      // Extract sleep data
      final sleepData = standardized['sleep'] as Map<String, dynamic>?;
      if (sleepData != null) {
        final totalHours = sleepData['total_hours'] as double?;
        if (totalHours != null && totalHours > 0) {
          sleepHours.add(totalHours);
        }
      }
      
      // Extract activity data
      final activityData = standardized['activity'] as Map<String, dynamic>?;
      if (activityData != null) {
        final dailySteps = activityData['daily_steps'] as int?;
        if (dailySteps != null && dailySteps > 0) {
          stepCounts.add(dailySteps);
        }
        
        final workouts = activityData['workouts'] as int?;
        if (workouts != null && workouts > 0) {
          workoutSessions.add({'count': workouts, 'vendor': vendor.key});
        }
      }
    }
    
    // Calculate aggregated metrics
    final sleep = _calculateSleepMetrics(sleepHours, window);
    final physio = _calculatePhysiologicalMetrics(heartRateValues, hrvValues);
    final training = _calculateTrainingMetrics(stepCounts, workoutSessions);
    final selfReport = _createDefaultSelfReport(); // Would be populated from user input
    final context = _createDefaultContext(); // Would be populated from app context
    
    return {
      'sleep': sleep,
      'physio': physio,
      'training': training,
      'self_report': selfReport,
      'context': context,
    };
  }

  /// Calculate sleep metrics from aggregated data
  SleepMetrics _calculateSleepMetrics(List<double> sleepHours, String window) {
    if (sleepHours.isEmpty) {
      return SleepMetrics(
        avgHours: 0.0,
        efficiency: 0.0,
        lastNightsHours: [],
      );
    }
    
    final avgHours = sleepHours.reduce((a, b) => a + b) / sleepHours.length;
    final efficiency = _estimateSleepEfficiency(avgHours);
    
    return SleepMetrics(
      avgHours: avgHours,
      efficiency: efficiency,
      lastNightsHours: sleepHours,
      deepSleepPct: _estimateDeepSleepPercentage(avgHours),
      remSleepPct: _estimateRemSleepPercentage(avgHours),
    );
  }

  /// Calculate physiological metrics
  PhysiologicalMetrics _calculatePhysiologicalMetrics(
    List<double> heartRateValues,
    List<double> hrvValues,
  ) {
    final restingHr = heartRateValues.isNotEmpty 
        ? heartRateValues.reduce(min)
        : 60.0;
    
    final avgHrv = hrvValues.isNotEmpty 
        ? hrvValues.reduce((a, b) => a + b) / hrvValues.length
        : 45.0;
    
    // Calculate delta vs baseline (would use historical data)
    const baselineHrv = 45.0; // Default baseline
    final hrvDeltaPct = ((avgHrv - baselineHrv) / baselineHrv) * 100;
    
    const baselineRhr = 60.0; // Default baseline
    final rhrDelta = restingHr - baselineRhr;
    
    return PhysiologicalMetrics(
      restingHr: restingHr,
      restingHrDeltaVsWeek: rhrDelta,
      hrvRmssd: avgHrv,
      hrvDeltaPct: hrvDeltaPct,
      avgHr: heartRateValues.isNotEmpty 
          ? heartRateValues.reduce((a, b) => a + b) / heartRateValues.length
          : null,
    );
  }

  /// Calculate training metrics
  TrainingMetrics _calculateTrainingMetrics(
    List<int> stepCounts,
    List<Map<String, dynamic>> workoutSessions,
  ) {
    final dailySteps = stepCounts.isNotEmpty 
        ? stepCounts.reduce((a, b) => a + b) ~/ stepCounts.length
        : null;
    
    final weeklyLoad = _calculateWeeklyLoad(stepCounts, workoutSessions);
    
    TrainingSession? lastSession;
    if (workoutSessions.isNotEmpty) {
      lastSession = TrainingSession(
        type: 'general',
        durationMin: 45, // Estimated
        intensity: 6, // Estimated
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
      );
    }
    
    return TrainingMetrics(
      lastSession: lastSession,
      weeklyLoad: weeklyLoad,
      dailySteps: dailySteps,
      sessionsThisWeek: workoutSessions.length,
    );
  }

  /// Create default self-report metrics (would be populated from UI)
  SelfReportMetrics _createDefaultSelfReport() {
    return SelfReportMetrics(
      mood: 3, // Neutral
      anxiety: 3, // Low-moderate
      stressLevel: 3,
      energyLevel: 3,
    );
  }

  /// Create default context metrics
  ContextMetrics _createDefaultContext() {
    return ContextMetrics(
      travelFlag: false,
      // daysToCompetition would be set from user's calendar/goals
    );
  }

  /// Generate natural language summary for AI context
  String _generateSummaryText(Map<String, dynamic> aggregatedData, String window) {
    final sleep = aggregatedData['sleep'] as SleepMetrics;
    final physio = aggregatedData['physio'] as PhysiologicalMetrics;
    final training = aggregatedData['training'] as TrainingMetrics;
    
    final summary = StringBuffer();
    
    // Time window context
    summary.write('$window: ');
    
    // Sleep summary
    if (sleep.avgHours > 0) {
      summary.write('sonno medio ${sleep.avgHours.toStringAsFixed(1)}h, ');
      if (sleep.efficiency > 0) {
        summary.write('efficienza ${sleep.efficiency.toStringAsFixed(0)}%, ');
      }
    }
    
    // HRV summary
    if (physio.hrvRmssd > 0) {
      final trend = physio.hrvDeltaPct >= 0 ? '+' : '';
      summary.write('HRV $trend${physio.hrvDeltaPct.toStringAsFixed(0)}% vs baseline, ');
    }
    
    // Heart rate summary
    if (physio.restingHr > 0) {
      final trend = physio.restingHrDeltaVsWeek >= 0 ? '+' : '';
      summary.write('RHR $trend${physio.restingHrDeltaVsWeek.toStringAsFixed(0)} bpm, ');
    }
    
    // Training load
    if (training.weeklyLoad > 0) {
      summary.write('carico allenamento ${training.weeklyLoad.toStringAsFixed(0)}');
    }
    
    // Context
    final context = aggregatedData['context'] as ContextMetrics;
    if (context.daysToCompetition != null && context.daysToCompetition! <= 7) {
      summary.write(', gara in ${context.daysToCompetition} giorni');
    }
    
    return summary.toString();
  }

  /// Generate health flags based on metrics
  List<String> _generateHealthFlags(Map<String, dynamic> aggregatedData) {
    final flags = <String>[];
    
    final sleep = aggregatedData['sleep'] as SleepMetrics;
    final physio = aggregatedData['physio'] as PhysiologicalMetrics;
    final training = aggregatedData['training'] as TrainingMetrics;
    
    // Sleep flags
    if (sleep.avgHours < 6.0) {
      flags.add('insufficient_sleep');
    }
    if (sleep.getPoorSleepStreak() >= 3) {
      flags.add('poor_sleep_3days');
    }
    if (sleep.efficiency < 80) {
      flags.add('low_sleep_efficiency');
    }
    
    // HRV flags
    if (physio.hrvDeltaPct < -20) {
      flags.add('hrv_significantly_low');
    }
    if (physio.hrvDeltaPct < -10) {
      flags.add('hrv_below_baseline');
    }
    
    // Heart rate flags
    if (physio.restingHrDeltaVsWeek > 10) {
      flags.add('elevated_resting_hr');
    }
    
    // Training flags
    if (training.isRecoveryNeeded()) {
      flags.add('recovery_recommended');
    }
    if (training.weeklyLoad > 800) {
      flags.add('high_training_load');
    }
    
    // Stress flags
    if (physio.getStressScore() >= 7) {
      flags.add('elevated_stress');
    }
    
    return flags;
  }

  /// Generate privacy-preserving user ID hash
  String _generateUserIdHash(String userId) {
    final bytes = utf8.encode(userId);
    final digest = sha256.convert(bytes);
    return 'sha256:$digest';
  }

  /// Estimate sleep efficiency from average hours
  double _estimateSleepEfficiency(double avgHours) {
    // Rough estimation based on typical sleep patterns
    if (avgHours >= 8.0) return 90.0;
    if (avgHours >= 7.0) return 85.0;
    if (avgHours >= 6.0) return 80.0;
    if (avgHours >= 5.0) return 75.0;
    return 70.0;
  }

  /// Estimate deep sleep percentage
  double _estimateDeepSleepPercentage(double totalHours) {
    // Deep sleep typically 15-20% of total sleep
    if (totalHours >= 7.0) return 18.0;
    if (totalHours >= 6.0) return 16.0;
    if (totalHours >= 5.0) return 14.0;
    return 12.0;
  }

  /// Estimate REM sleep percentage
  double _estimateRemSleepPercentage(double totalHours) {
    // REM sleep typically 20-25% of total sleep
    if (totalHours >= 7.0) return 22.0;
    if (totalHours >= 6.0) return 20.0;
    if (totalHours >= 5.0) return 18.0;
    return 16.0;
  }

  /// Calculate weekly training load from activities
  double _calculateWeeklyLoad(
    List<int> stepCounts, 
    List<Map<String, dynamic>> workoutSessions,
  ) {
    double load = 0.0;
    
    // Base load from daily steps
    final avgSteps = stepCounts.isNotEmpty 
        ? stepCounts.reduce((a, b) => a + b) / stepCounts.length
        : 0.0;
    
    // Rough conversion: 1000 steps ≈ 10 load units
    load += (avgSteps / 1000) * 10 * 7; // Weekly extrapolation
    
    // Additional load from workouts
    load += workoutSessions.length * 50; // 50 units per workout session
    
    return load;
  }

  /// Calculate overall wellness score
  double _calculateWellnessScore(WearableSnapshot snapshot) {
    double score = 0.0;
    
    // Sleep contribution (40%)
    score += (snapshot.sleep.avgHours >= 7.0 ? 40.0 : snapshot.sleep.avgHours / 7.0 * 40.0);
    
    // HRV contribution (25%)
    score += (snapshot.physio.hrvDeltaPct >= 0 ? 25.0 : 
              max(0, 25.0 + (snapshot.physio.hrvDeltaPct / 20.0 * 25.0)));
    
    // Mood contribution (20%)
    score += (snapshot.selfReport.mood / 5.0 * 20.0);
    
    // Activity contribution (15%)
    final hasGoodActivity = (snapshot.training.dailySteps ?? 0) >= 8000;
    score += (hasGoodActivity ? 15.0 : (snapshot.training.dailySteps ?? 0) / 8000.0 * 15.0);
    
    return score.clamp(0.0, 100.0);
  }

  /// Get default baselines when no historical data is available
  Map<String, double> _getDefaultBaselines() {
    return {
      'hrv_rmssd': 45.0,
      'resting_hr': 60.0,
      'sleep_hours': 8.0,
    };
  }
}