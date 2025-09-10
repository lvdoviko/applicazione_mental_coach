import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'vendor_data_models.g.dart';

/// Base class for vendor-specific health data
abstract class VendorHealthData extends Equatable {
  /// Vendor identifier
  String get vendor;
  
  /// Available data types from this vendor
  Set<String> get availableDataTypes;
  
  /// Data collection timestamp
  DateTime get timestamp;
  
  /// Convert to standardized health metrics
  Map<String, dynamic> toStandardizedMetrics();
  
  /// Check if vendor data is valid and complete
  bool isValid();
}

/// Apple HealthKit data model
@JsonSerializable(explicitToJson: true)
class AppleHealthData extends VendorHealthData {
  @override
  String get vendor => 'apple_healthkit';
  
  @override
  final DateTime timestamp;
  
  /// Heart rate samples (BPM)
  @JsonKey(name: 'heart_rate_samples')
  final List<HealthSample> heartRateSamples;
  
  /// Heart rate variability SDNN (ms)
  @JsonKey(name: 'hrv_samples')
  final List<HealthSample> hrvSamples;
  
  /// Sleep analysis data
  @JsonKey(name: 'sleep_samples')
  final List<SleepSample> sleepSamples;
  
  /// Step count data
  @JsonKey(name: 'step_samples')
  final List<HealthSample> stepSamples;
  
  /// Active energy burned (calories)
  @JsonKey(name: 'active_energy_samples')
  final List<HealthSample> activeEnergySamples;
  
  /// Workout sessions
  @JsonKey(name: 'workout_samples')
  final List<WorkoutSample> workoutSamples;
  
  /// Blood oxygen levels (if available)
  @JsonKey(name: 'blood_oxygen_samples', includeIfNull: false)
  final List<HealthSample>? bloodOxygenSamples;
  
  /// Resting heart rate (if calculated by HealthKit)
  @JsonKey(name: 'resting_hr_samples', includeIfNull: false)
  final List<HealthSample>? restingHrSamples;

  AppleHealthData({
    required this.timestamp,
    required this.heartRateSamples,
    required this.hrvSamples,
    required this.sleepSamples,
    required this.stepSamples,
    required this.activeEnergySamples,
    required this.workoutSamples,
    this.bloodOxygenSamples,
    this.restingHrSamples,
  });

  factory AppleHealthData.fromJson(Map<String, dynamic> json) =>
      _$AppleHealthDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppleHealthDataToJson(this);

  @override
  Set<String> get availableDataTypes => {
    'heart_rate',
    'hrv',
    'sleep',
    'steps',
    'active_energy',
    'workouts',
    if (bloodOxygenSamples != null) 'blood_oxygen',
    if (restingHrSamples != null) 'resting_hr',
  };

  @override
  bool isValid() {
    return heartRateSamples.isNotEmpty &&
           sleepSamples.isNotEmpty &&
           stepSamples.isNotEmpty;
  }

  @override
  Map<String, dynamic> toStandardizedMetrics() {
    return {
      'vendor': vendor,
      'timestamp': timestamp.toIso8601String(),
      'heart_rate': {
        'samples': heartRateSamples.length,
        'avg': _calculateAverage(heartRateSamples),
        'resting': restingHrSamples?.isNotEmpty == true 
            ? restingHrSamples!.last.value 
            : null,
      },
      'hrv': {
        'samples': hrvSamples.length,
        'avg_rmssd': _calculateAverage(hrvSamples),
      },
      'sleep': {
        'total_hours': _calculateTotalSleepHours(),
        'efficiency': _calculateSleepEfficiency(),
        'deep_sleep_pct': _calculateDeepSleepPercentage(),
      },
      'activity': {
        'daily_steps': _calculateDailySteps(),
        'active_calories': _calculateActiveCalories(),
        'workouts': workoutSamples.length,
      },
      'blood_oxygen': bloodOxygenSamples?.isNotEmpty == true 
          ? _calculateAverage(bloodOxygenSamples!) 
          : null,
    };
  }

  double _calculateAverage(List<HealthSample> samples) {
    if (samples.isEmpty) return 0.0;
    return samples.map((s) => s.value).reduce((a, b) => a + b) / samples.length;
  }

  double _calculateTotalSleepHours() {
    double totalMinutes = 0.0;
    for (var sample in sleepSamples) {
      if (sample.sleepType == 'inBed' || sample.sleepType == 'asleep') {
        totalMinutes += sample.endTime.difference(sample.startTime).inMinutes;
      }
    }
    return totalMinutes / 60.0;
  }

  double _calculateSleepEfficiency() {
    double inBedTime = 0.0;
    double asleepTime = 0.0;
    
    for (var sample in sleepSamples) {
      final duration = sample.endTime.difference(sample.startTime).inMinutes.toDouble();
      
      if (sample.sleepType == 'inBed') {
        inBedTime += duration;
      } else if (sample.sleepType == 'asleep') {
        asleepTime += duration;
      }
    }
    
    if (inBedTime == 0) return 0.0;
    return (asleepTime / inBedTime) * 100;
  }

  double _calculateDeepSleepPercentage() {
    double totalSleepTime = 0.0;
    double deepSleepTime = 0.0;
    
    for (var sample in sleepSamples) {
      final duration = sample.endTime.difference(sample.startTime).inMinutes.toDouble();
      
      if (sample.sleepType == 'asleep') {
        totalSleepTime += duration;
      } else if (sample.sleepType == 'deepSleep') {
        deepSleepTime += duration;
      }
    }
    
    if (totalSleepTime == 0) return 0.0;
    return (deepSleepTime / totalSleepTime) * 100;
  }

  int _calculateDailySteps() {
    return stepSamples
        .where((s) => _isFromToday(s.timestamp))
        .fold<int>(0, (sum, sample) => sum + sample.value.round());
  }

  double _calculateActiveCalories() {
    return activeEnergySamples
        .where((s) => _isFromToday(s.timestamp))
        .fold<double>(0.0, (sum, sample) => sum + sample.value);
  }

  bool _isFromToday(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sampleDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    return sampleDay.isAtSameMomentAs(today);
  }

  @override
  List<Object?> get props => [
    timestamp,
    heartRateSamples,
    hrvSamples,
    sleepSamples,
    stepSamples,
    activeEnergySamples,
    workoutSamples,
    bloodOxygenSamples,
    restingHrSamples,
  ];
}

/// Samsung Health data model
@JsonSerializable(explicitToJson: true)
class SamsungHealthData extends VendorHealthData {
  @override
  String get vendor => 'samsung_health';
  
  @override
  final DateTime timestamp;
  
  /// Heart rate data
  @JsonKey(name: 'heart_rate')
  final List<HealthSample> heartRate;
  
  /// Stress level measurements (Samsung specific)
  @JsonKey(name: 'stress_samples')
  final List<HealthSample> stressSamples;
  
  /// Sleep data from Samsung Health
  @JsonKey(name: 'sleep_data')
  final List<SamsungSleepData> sleepData;
  
  /// Step count
  @JsonKey(name: 'step_count')
  final List<HealthSample> stepCount;
  
  /// Exercise sessions
  @JsonKey(name: 'exercise_sessions')
  final List<SamsungExerciseSession> exerciseSessions;
  
  /// SpO2 measurements (Galaxy Watch)
  @JsonKey(name: 'spo2_samples', includeIfNull: false)
  final List<HealthSample>? spo2Samples;

  SamsungHealthData({
    required this.timestamp,
    required this.heartRate,
    required this.stressSamples,
    required this.sleepData,
    required this.stepCount,
    required this.exerciseSessions,
    this.spo2Samples,
  });

  factory SamsungHealthData.fromJson(Map<String, dynamic> json) =>
      _$SamsungHealthDataFromJson(json);

  Map<String, dynamic> toJson() => _$SamsungHealthDataToJson(this);

  @override
  Set<String> get availableDataTypes => {
    'heart_rate',
    'stress',
    'sleep',
    'steps',
    'exercise',
    if (spo2Samples != null) 'spo2',
  };

  @override
  bool isValid() {
    return heartRate.isNotEmpty &&
           sleepData.isNotEmpty &&
           stepCount.isNotEmpty;
  }

  @override
  Map<String, dynamic> toStandardizedMetrics() {
    return {
      'vendor': vendor,
      'timestamp': timestamp.toIso8601String(),
      'heart_rate': {
        'avg': _calculateAverage(heartRate),
        'samples': heartRate.length,
      },
      'stress': {
        'avg_level': _calculateAverage(stressSamples),
        'samples': stressSamples.length,
      },
      'sleep': {
        'total_hours': _calculateSleepHours(),
        'efficiency': _calculateSleepEfficiency(),
      },
      'activity': {
        'daily_steps': _calculateDailySteps(),
        'exercise_sessions': exerciseSessions.length,
      },
      'spo2': spo2Samples?.isNotEmpty == true 
          ? _calculateAverage(spo2Samples!) 
          : null,
    };
  }

  double _calculateAverage(List<HealthSample> samples) {
    if (samples.isEmpty) return 0.0;
    return samples.map((s) => s.value).reduce((a, b) => a + b) / samples.length;
  }

  double _calculateSleepHours() {
    return sleepData.fold<double>(
      0.0, 
      (sum, sleep) => sum + (sleep.sleepDuration / 3600000), // ms to hours
    );
  }

  double _calculateSleepEfficiency() {
    if (sleepData.isEmpty) return 0.0;
    
    final totalSleep = sleepData.fold<int>(0, (sum, s) => sum + s.sleepDuration);
    final totalInBed = sleepData.fold<int>(0, (sum, s) => sum + (s.bedTime ?? s.sleepDuration));
    
    if (totalInBed == 0) return 0.0;
    return (totalSleep / totalInBed) * 100;
  }

  int _calculateDailySteps() {
    final today = DateTime.now();
    return stepCount
        .where((s) => _isSameDay(s.timestamp, today))
        .fold<int>(0, (sum, sample) => sum + sample.value.round());
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  List<Object?> get props => [
    timestamp,
    heartRate,
    stressSamples,
    sleepData,
    stepCount,
    exerciseSessions,
    spo2Samples,
  ];
}

/// Garmin Connect data model
@JsonSerializable(explicitToJson: true)
class GarminHealthData extends VendorHealthData {
  @override
  String get vendor => 'garmin_connect';
  
  @override
  final DateTime timestamp;
  
  /// Daily summaries from Garmin Connect
  @JsonKey(name: 'daily_summary')
  final GarminDailySummary dailySummary;
  
  /// Sleep summary data
  @JsonKey(name: 'sleep_summary')
  final GarminSleepSummary? sleepSummary;
  
  /// Stress and body battery data
  @JsonKey(name: 'stress_data')
  final GarminStressData? stressData;
  
  /// Training activities
  @JsonKey(name: 'activities')
  final List<GarminActivity> activities;
  
  /// Advanced training metrics (if available)
  @JsonKey(name: 'training_metrics', includeIfNull: false)
  final GarminTrainingMetrics? trainingMetrics;

  GarminHealthData({
    required this.timestamp,
    required this.dailySummary,
    this.sleepSummary,
    this.stressData,
    required this.activities,
    this.trainingMetrics,
  });

  factory GarminHealthData.fromJson(Map<String, dynamic> json) =>
      _$GarminHealthDataFromJson(json);

  Map<String, dynamic> toJson() => _$GarminHealthDataToJson(this);

  @override
  Set<String> get availableDataTypes => {
    'daily_summary',
    'activities',
    if (sleepSummary != null) 'sleep',
    if (stressData != null) 'stress',
    if (trainingMetrics != null) 'training_metrics',
  };

  @override
  bool isValid() {
    return activities.isNotEmpty;
  }

  @override
  Map<String, dynamic> toStandardizedMetrics() {
    return {
      'vendor': vendor,
      'timestamp': timestamp.toIso8601String(),
      'daily_activity': {
        'steps': dailySummary.totalSteps,
        'calories': dailySummary.activeCalories,
        'distance': dailySummary.totalDistance,
      },
      'sleep': sleepSummary != null ? {
        'total_hours': sleepSummary!.totalSleepTime / 3600, // seconds to hours
        'deep_sleep_pct': sleepSummary!.deepSleepSeconds / sleepSummary!.totalSleepTime * 100,
        'sleep_score': sleepSummary!.sleepScore,
      } : null,
      'stress': stressData != null ? {
        'avg_stress': stressData!.averageStressLevel,
        'max_stress': stressData!.maxStressLevel,
        'rest_stress': stressData!.restStressLevel,
      } : null,
      'training': {
        'activities_count': activities.length,
        'total_training_time': _calculateTotalTrainingTime(),
        'training_load': trainingMetrics?.trainingLoad,
        'recovery_time': trainingMetrics?.recoveryTime,
      },
    };
  }

  double _calculateTotalTrainingTime() {
    return activities.fold<double>(
      0.0, 
      (sum, activity) => sum + (activity.duration / 3600), // seconds to hours
    );
  }

  @override
  List<Object?> get props => [
    timestamp,
    dailySummary,
    sleepSummary,
    stressData,
    activities,
    trainingMetrics,
  ];
}

/// Whoop data model
@JsonSerializable(explicitToJson: true)
class WhoopHealthData extends VendorHealthData {
  @override
  String get vendor => 'whoop';
  
  @override
  final DateTime timestamp;
  
  /// Recovery data (Whoop's primary metric)
  @JsonKey(name: 'recovery')
  final WhoopRecovery recovery;
  
  /// Strain data for the day
  @JsonKey(name: 'strain')
  final WhoopStrain strain;
  
  /// Sleep performance data
  @JsonKey(name: 'sleep')
  final WhoopSleep sleep;
  
  /// Physiological data
  @JsonKey(name: 'physiological_data')
  final WhoopPhysiologicalData physiologicalData;

  WhoopHealthData({
    required this.timestamp,
    required this.recovery,
    required this.strain,
    required this.sleep,
    required this.physiologicalData,
  });

  factory WhoopHealthData.fromJson(Map<String, dynamic> json) =>
      _$WhoopHealthDataFromJson(json);

  Map<String, dynamic> toJson() => _$WhoopHealthDataToJson(this);

  @override
  Set<String> get availableDataTypes => {
    'recovery',
    'strain',
    'sleep',
    'hrv',
    'heart_rate',
  };

  @override
  bool isValid() {
    return recovery.recoveryScore != null;
  }

  @override
  Map<String, dynamic> toStandardizedMetrics() {
    return {
      'vendor': vendor,
      'timestamp': timestamp.toIso8601String(),
      'recovery': {
        'score': recovery.recoveryScore,
        'hrv_rmssd': recovery.hrvRmssd,
        'resting_hr': recovery.restingHeartRate,
      },
      'strain': {
        'score': strain.strainScore,
        'max_hr': strain.maxHeartRate,
        'avg_hr': strain.averageHeartRate,
        'kilojoules': strain.kilojoules,
      },
      'sleep': {
        'total_hours': sleep.totalSleepTime / 3600000, // ms to hours
        'sleep_efficiency': sleep.sleepEfficiency,
        'deep_sleep_pct': sleep.slowWaveSleep / sleep.totalSleepTime * 100,
        'rem_sleep_pct': sleep.remSleep / sleep.totalSleepTime * 100,
        'sleep_score': sleep.sleepPerformancePercentage,
      },
      'physiological': {
        'hrv_rmssd': physiologicalData.heartRateVariabilityRmssd,
        'resting_hr': physiologicalData.restingHeartRate,
        'respiratory_rate': physiologicalData.respiratoryRate,
        'skin_temp': physiologicalData.skinTempCelsius,
      },
    };
  }

  @override
  List<Object?> get props => [
    timestamp,
    recovery,
    strain,
    sleep,
    physiologicalData,
  ];
}

// Supporting data structures

/// Generic health sample with timestamp and value
@JsonSerializable()
class HealthSample extends Equatable {
  final DateTime timestamp;
  final double value;
  final String? unit;

  const HealthSample({
    required this.timestamp,
    required this.value,
    this.unit,
  });

  factory HealthSample.fromJson(Map<String, dynamic> json) =>
      _$HealthSampleFromJson(json);

  Map<String, dynamic> toJson() => _$HealthSampleToJson(this);

  @override
  List<Object?> get props => [timestamp, value, unit];
}

/// Sleep sample with start/end times and sleep type
@JsonSerializable()
class SleepSample extends Equatable {
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  
  @JsonKey(name: 'sleep_type')
  final String sleepType; // 'inBed', 'asleep', 'deepSleep', 'remSleep', 'awake'

  const SleepSample({
    required this.startTime,
    required this.endTime,
    required this.sleepType,
  });

  factory SleepSample.fromJson(Map<String, dynamic> json) =>
      _$SleepSampleFromJson(json);

  Map<String, dynamic> toJson() => _$SleepSampleToJson(this);

  @override
  List<Object?> get props => [startTime, endTime, sleepType];
}

/// Workout/Exercise sample with metadata
@JsonSerializable()
class WorkoutSample extends Equatable {
  @JsonKey(name: 'workout_type')
  final String workoutType;
  
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  
  @JsonKey(name: 'total_energy')
  final double? totalEnergy;
  
  @JsonKey(name: 'total_distance')
  final double? totalDistance;

  const WorkoutSample({
    required this.workoutType,
    required this.startTime,
    required this.endTime,
    this.totalEnergy,
    this.totalDistance,
  });

  factory WorkoutSample.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSampleFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSampleToJson(this);

  @override
  List<Object?> get props => [workoutType, startTime, endTime, totalEnergy, totalDistance];
}

// Samsung Health specific models
@JsonSerializable()
class SamsungSleepData extends Equatable {
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'sleep_duration')
  final int sleepDuration; // milliseconds
  
  @JsonKey(name: 'bed_time', includeIfNull: false)
  final int? bedTime; // milliseconds
  
  @JsonKey(name: 'efficiency')
  final double? efficiency;

  const SamsungSleepData({
    required this.startTime,
    required this.sleepDuration,
    this.bedTime,
    this.efficiency,
  });

  factory SamsungSleepData.fromJson(Map<String, dynamic> json) =>
      _$SamsungSleepDataFromJson(json);

  Map<String, dynamic> toJson() => _$SamsungSleepDataToJson(this);

  @override
  List<Object?> get props => [startTime, sleepDuration, bedTime, efficiency];
}

@JsonSerializable()
class SamsungExerciseSession extends Equatable {
  @JsonKey(name: 'exercise_type')
  final String exerciseType;
  
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'duration')
  final int duration; // seconds
  
  @JsonKey(name: 'calorie')
  final double? calorie;

  const SamsungExerciseSession({
    required this.exerciseType,
    required this.startTime,
    required this.duration,
    this.calorie,
  });

  factory SamsungExerciseSession.fromJson(Map<String, dynamic> json) =>
      _$SamsungExerciseSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SamsungExerciseSessionToJson(this);

  @override
  List<Object?> get props => [exerciseType, startTime, duration, calorie];
}

// Garmin specific models
@JsonSerializable()
class GarminDailySummary extends Equatable {
  @JsonKey(name: 'total_steps')
  final int totalSteps;
  
  @JsonKey(name: 'active_calories')
  final double activeCalories;
  
  @JsonKey(name: 'total_distance')
  final double totalDistance; // meters

  const GarminDailySummary({
    required this.totalSteps,
    required this.activeCalories,
    required this.totalDistance,
  });

  factory GarminDailySummary.fromJson(Map<String, dynamic> json) =>
      _$GarminDailySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$GarminDailySummaryToJson(this);

  @override
  List<Object?> get props => [totalSteps, activeCalories, totalDistance];
}

@JsonSerializable()
class GarminSleepSummary extends Equatable {
  @JsonKey(name: 'total_sleep_time')
  final int totalSleepTime; // seconds
  
  @JsonKey(name: 'deep_sleep_seconds')
  final int deepSleepSeconds;
  
  @JsonKey(name: 'sleep_score')
  final int? sleepScore;

  const GarminSleepSummary({
    required this.totalSleepTime,
    required this.deepSleepSeconds,
    this.sleepScore,
  });

  factory GarminSleepSummary.fromJson(Map<String, dynamic> json) =>
      _$GarminSleepSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$GarminSleepSummaryToJson(this);

  @override
  List<Object?> get props => [totalSleepTime, deepSleepSeconds, sleepScore];
}

@JsonSerializable()
class GarminStressData extends Equatable {
  @JsonKey(name: 'average_stress_level')
  final int? averageStressLevel;
  
  @JsonKey(name: 'max_stress_level')
  final int? maxStressLevel;
  
  @JsonKey(name: 'rest_stress_level')
  final int? restStressLevel;

  const GarminStressData({
    this.averageStressLevel,
    this.maxStressLevel,
    this.restStressLevel,
  });

  factory GarminStressData.fromJson(Map<String, dynamic> json) =>
      _$GarminStressDataFromJson(json);

  Map<String, dynamic> toJson() => _$GarminStressDataToJson(this);

  @override
  List<Object?> get props => [averageStressLevel, maxStressLevel, restStressLevel];
}

@JsonSerializable()
class GarminActivity extends Equatable {
  @JsonKey(name: 'activity_type')
  final String activityType;
  
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  
  @JsonKey(name: 'duration')
  final int duration; // seconds

  const GarminActivity({
    required this.activityType,
    required this.startTime,
    required this.duration,
  });

  factory GarminActivity.fromJson(Map<String, dynamic> json) =>
      _$GarminActivityFromJson(json);

  Map<String, dynamic> toJson() => _$GarminActivityToJson(this);

  @override
  List<Object?> get props => [activityType, startTime, duration];
}

@JsonSerializable()
class GarminTrainingMetrics extends Equatable {
  @JsonKey(name: 'training_load')
  final int? trainingLoad;
  
  @JsonKey(name: 'recovery_time')
  final int? recoveryTime; // hours

  const GarminTrainingMetrics({
    this.trainingLoad,
    this.recoveryTime,
  });

  factory GarminTrainingMetrics.fromJson(Map<String, dynamic> json) =>
      _$GarminTrainingMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$GarminTrainingMetricsToJson(this);

  @override
  List<Object?> get props => [trainingLoad, recoveryTime];
}

// Whoop specific models
@JsonSerializable()
class WhoopRecovery extends Equatable {
  @JsonKey(name: 'recovery_score')
  final double? recoveryScore; // 0-100 percentage
  
  @JsonKey(name: 'hrv_rmssd')
  final double? hrvRmssd; // milliseconds
  
  @JsonKey(name: 'resting_heart_rate')
  final int? restingHeartRate; // BPM

  const WhoopRecovery({
    this.recoveryScore,
    this.hrvRmssd,
    this.restingHeartRate,
  });

  factory WhoopRecovery.fromJson(Map<String, dynamic> json) =>
      _$WhoopRecoveryFromJson(json);

  Map<String, dynamic> toJson() => _$WhoopRecoveryToJson(this);

  @override
  List<Object?> get props => [recoveryScore, hrvRmssd, restingHeartRate];
}

@JsonSerializable()
class WhoopStrain extends Equatable {
  @JsonKey(name: 'strain_score')
  final double? strainScore; // 0-21 scale
  
  @JsonKey(name: 'max_heart_rate')
  final int? maxHeartRate; // BPM
  
  @JsonKey(name: 'average_heart_rate')
  final int? averageHeartRate; // BPM
  
  @JsonKey(name: 'kilojoules')
  final double? kilojoules;

  const WhoopStrain({
    this.strainScore,
    this.maxHeartRate,
    this.averageHeartRate,
    this.kilojoules,
  });

  factory WhoopStrain.fromJson(Map<String, dynamic> json) =>
      _$WhoopStrainFromJson(json);

  Map<String, dynamic> toJson() => _$WhoopStrainToJson(this);

  @override
  List<Object?> get props => [strainScore, maxHeartRate, averageHeartRate, kilojoules];
}

@JsonSerializable()
class WhoopSleep extends Equatable {
  @JsonKey(name: 'total_sleep_time')
  final int totalSleepTime; // milliseconds
  
  @JsonKey(name: 'sleep_efficiency')
  final double? sleepEfficiency; // percentage
  
  @JsonKey(name: 'slow_wave_sleep')
  final int slowWaveSleep; // milliseconds (deep sleep)
  
  @JsonKey(name: 'rem_sleep')
  final int remSleep; // milliseconds
  
  @JsonKey(name: 'sleep_performance_percentage')
  final int? sleepPerformancePercentage;

  const WhoopSleep({
    required this.totalSleepTime,
    this.sleepEfficiency,
    required this.slowWaveSleep,
    required this.remSleep,
    this.sleepPerformancePercentage,
  });

  factory WhoopSleep.fromJson(Map<String, dynamic> json) =>
      _$WhoopSleepFromJson(json);

  Map<String, dynamic> toJson() => _$WhoopSleepToJson(this);

  @override
  List<Object?> get props => [
    totalSleepTime,
    sleepEfficiency,
    slowWaveSleep,
    remSleep,
    sleepPerformancePercentage,
  ];
}

@JsonSerializable()
class WhoopPhysiologicalData extends Equatable {
  @JsonKey(name: 'heart_rate_variability_rmssd')
  final double? heartRateVariabilityRmssd; // milliseconds
  
  @JsonKey(name: 'resting_heart_rate')
  final int? restingHeartRate; // BPM
  
  @JsonKey(name: 'respiratory_rate')
  final double? respiratoryRate; // breaths per minute
  
  @JsonKey(name: 'skin_temp_celsius')
  final double? skinTempCelsius;

  const WhoopPhysiologicalData({
    this.heartRateVariabilityRmssd,
    this.restingHeartRate,
    this.respiratoryRate,
    this.skinTempCelsius,
  });

  factory WhoopPhysiologicalData.fromJson(Map<String, dynamic> json) =>
      _$WhoopPhysiologicalDataFromJson(json);

  Map<String, dynamic> toJson() => _$WhoopPhysiologicalDataToJson(this);

  @override
  List<Object?> get props => [
    heartRateVariabilityRmssd,
    restingHeartRate,
    respiratoryRate,
    skinTempCelsius,
  ];
}