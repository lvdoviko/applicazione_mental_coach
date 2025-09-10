// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_data_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleHealthData _$AppleHealthDataFromJson(Map<String, dynamic> json) =>
    AppleHealthData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRateSamples: (json['heart_rate_samples'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      hrvSamples: (json['hrv_samples'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      sleepSamples: (json['sleep_samples'] as List<dynamic>)
          .map((e) => SleepSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      stepSamples: (json['step_samples'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeEnergySamples: (json['active_energy_samples'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      workoutSamples: (json['workout_samples'] as List<dynamic>)
          .map((e) => WorkoutSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      bloodOxygenSamples: (json['blood_oxygen_samples'] as List<dynamic>?)
          ?.map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      restingHrSamples: (json['resting_hr_samples'] as List<dynamic>?)
          ?.map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppleHealthDataToJson(AppleHealthData instance) {
  final val = <String, dynamic>{
    'timestamp': instance.timestamp.toIso8601String(),
    'heart_rate_samples':
        instance.heartRateSamples.map((e) => e.toJson()).toList(),
    'hrv_samples': instance.hrvSamples.map((e) => e.toJson()).toList(),
    'sleep_samples': instance.sleepSamples.map((e) => e.toJson()).toList(),
    'step_samples': instance.stepSamples.map((e) => e.toJson()).toList(),
    'active_energy_samples':
        instance.activeEnergySamples.map((e) => e.toJson()).toList(),
    'workout_samples': instance.workoutSamples.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('blood_oxygen_samples',
      instance.bloodOxygenSamples?.map((e) => e.toJson()).toList());
  writeNotNull('resting_hr_samples',
      instance.restingHrSamples?.map((e) => e.toJson()).toList());
  return val;
}

SamsungHealthData _$SamsungHealthDataFromJson(Map<String, dynamic> json) =>
    SamsungHealthData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: (json['heart_rate'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      stressSamples: (json['stress_samples'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      sleepData: (json['sleep_data'] as List<dynamic>)
          .map((e) => SamsungSleepData.fromJson(e as Map<String, dynamic>))
          .toList(),
      stepCount: (json['step_count'] as List<dynamic>)
          .map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
      exerciseSessions: (json['exercise_sessions'] as List<dynamic>)
          .map(
              (e) => SamsungExerciseSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      spo2Samples: (json['spo2_samples'] as List<dynamic>?)
          ?.map((e) => HealthSample.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SamsungHealthDataToJson(SamsungHealthData instance) {
  final val = <String, dynamic>{
    'timestamp': instance.timestamp.toIso8601String(),
    'heart_rate': instance.heartRate.map((e) => e.toJson()).toList(),
    'stress_samples': instance.stressSamples.map((e) => e.toJson()).toList(),
    'sleep_data': instance.sleepData.map((e) => e.toJson()).toList(),
    'step_count': instance.stepCount.map((e) => e.toJson()).toList(),
    'exercise_sessions':
        instance.exerciseSessions.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'spo2_samples', instance.spo2Samples?.map((e) => e.toJson()).toList());
  return val;
}

GarminHealthData _$GarminHealthDataFromJson(Map<String, dynamic> json) =>
    GarminHealthData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      dailySummary: GarminDailySummary.fromJson(
          json['daily_summary'] as Map<String, dynamic>),
      sleepSummary: json['sleep_summary'] == null
          ? null
          : GarminSleepSummary.fromJson(
              json['sleep_summary'] as Map<String, dynamic>),
      stressData: json['stress_data'] == null
          ? null
          : GarminStressData.fromJson(
              json['stress_data'] as Map<String, dynamic>),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => GarminActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      trainingMetrics: json['training_metrics'] == null
          ? null
          : GarminTrainingMetrics.fromJson(
              json['training_metrics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GarminHealthDataToJson(GarminHealthData instance) {
  final val = <String, dynamic>{
    'timestamp': instance.timestamp.toIso8601String(),
    'daily_summary': instance.dailySummary.toJson(),
    'sleep_summary': instance.sleepSummary?.toJson(),
    'stress_data': instance.stressData?.toJson(),
    'activities': instance.activities.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('training_metrics', instance.trainingMetrics?.toJson());
  return val;
}

WhoopHealthData _$WhoopHealthDataFromJson(Map<String, dynamic> json) =>
    WhoopHealthData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      recovery:
          WhoopRecovery.fromJson(json['recovery'] as Map<String, dynamic>),
      strain: WhoopStrain.fromJson(json['strain'] as Map<String, dynamic>),
      sleep: WhoopSleep.fromJson(json['sleep'] as Map<String, dynamic>),
      physiologicalData: WhoopPhysiologicalData.fromJson(
          json['physiological_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WhoopHealthDataToJson(WhoopHealthData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'recovery': instance.recovery.toJson(),
      'strain': instance.strain.toJson(),
      'sleep': instance.sleep.toJson(),
      'physiological_data': instance.physiologicalData.toJson(),
    };

HealthSample _$HealthSampleFromJson(Map<String, dynamic> json) => HealthSample(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$HealthSampleToJson(HealthSample instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'unit': instance.unit,
    };

SleepSample _$SleepSampleFromJson(Map<String, dynamic> json) => SleepSample(
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      sleepType: json['sleep_type'] as String,
    );

Map<String, dynamic> _$SleepSampleToJson(SleepSample instance) =>
    <String, dynamic>{
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'sleep_type': instance.sleepType,
    };

WorkoutSample _$WorkoutSampleFromJson(Map<String, dynamic> json) =>
    WorkoutSample(
      workoutType: json['workout_type'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalEnergy: (json['total_energy'] as num?)?.toDouble(),
      totalDistance: (json['total_distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WorkoutSampleToJson(WorkoutSample instance) =>
    <String, dynamic>{
      'workout_type': instance.workoutType,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'total_energy': instance.totalEnergy,
      'total_distance': instance.totalDistance,
    };

SamsungSleepData _$SamsungSleepDataFromJson(Map<String, dynamic> json) =>
    SamsungSleepData(
      startTime: DateTime.parse(json['start_time'] as String),
      sleepDuration: (json['sleep_duration'] as num).toInt(),
      bedTime: (json['bed_time'] as num?)?.toInt(),
      efficiency: (json['efficiency'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SamsungSleepDataToJson(SamsungSleepData instance) {
  final val = <String, dynamic>{
    'start_time': instance.startTime.toIso8601String(),
    'sleep_duration': instance.sleepDuration,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bed_time', instance.bedTime);
  val['efficiency'] = instance.efficiency;
  return val;
}

SamsungExerciseSession _$SamsungExerciseSessionFromJson(
        Map<String, dynamic> json) =>
    SamsungExerciseSession(
      exerciseType: json['exercise_type'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      duration: (json['duration'] as num).toInt(),
      calorie: (json['calorie'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SamsungExerciseSessionToJson(
        SamsungExerciseSession instance) =>
    <String, dynamic>{
      'exercise_type': instance.exerciseType,
      'start_time': instance.startTime.toIso8601String(),
      'duration': instance.duration,
      'calorie': instance.calorie,
    };

GarminDailySummary _$GarminDailySummaryFromJson(Map<String, dynamic> json) =>
    GarminDailySummary(
      totalSteps: (json['total_steps'] as num).toInt(),
      activeCalories: (json['active_calories'] as num).toDouble(),
      totalDistance: (json['total_distance'] as num).toDouble(),
    );

Map<String, dynamic> _$GarminDailySummaryToJson(GarminDailySummary instance) =>
    <String, dynamic>{
      'total_steps': instance.totalSteps,
      'active_calories': instance.activeCalories,
      'total_distance': instance.totalDistance,
    };

GarminSleepSummary _$GarminSleepSummaryFromJson(Map<String, dynamic> json) =>
    GarminSleepSummary(
      totalSleepTime: (json['total_sleep_time'] as num).toInt(),
      deepSleepSeconds: (json['deep_sleep_seconds'] as num).toInt(),
      sleepScore: (json['sleep_score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GarminSleepSummaryToJson(GarminSleepSummary instance) =>
    <String, dynamic>{
      'total_sleep_time': instance.totalSleepTime,
      'deep_sleep_seconds': instance.deepSleepSeconds,
      'sleep_score': instance.sleepScore,
    };

GarminStressData _$GarminStressDataFromJson(Map<String, dynamic> json) =>
    GarminStressData(
      averageStressLevel: (json['average_stress_level'] as num?)?.toInt(),
      maxStressLevel: (json['max_stress_level'] as num?)?.toInt(),
      restStressLevel: (json['rest_stress_level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GarminStressDataToJson(GarminStressData instance) =>
    <String, dynamic>{
      'average_stress_level': instance.averageStressLevel,
      'max_stress_level': instance.maxStressLevel,
      'rest_stress_level': instance.restStressLevel,
    };

GarminActivity _$GarminActivityFromJson(Map<String, dynamic> json) =>
    GarminActivity(
      activityType: json['activity_type'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$GarminActivityToJson(GarminActivity instance) =>
    <String, dynamic>{
      'activity_type': instance.activityType,
      'start_time': instance.startTime.toIso8601String(),
      'duration': instance.duration,
    };

GarminTrainingMetrics _$GarminTrainingMetricsFromJson(
        Map<String, dynamic> json) =>
    GarminTrainingMetrics(
      trainingLoad: (json['training_load'] as num?)?.toInt(),
      recoveryTime: (json['recovery_time'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GarminTrainingMetricsToJson(
        GarminTrainingMetrics instance) =>
    <String, dynamic>{
      'training_load': instance.trainingLoad,
      'recovery_time': instance.recoveryTime,
    };

WhoopRecovery _$WhoopRecoveryFromJson(Map<String, dynamic> json) =>
    WhoopRecovery(
      recoveryScore: (json['recovery_score'] as num?)?.toDouble(),
      hrvRmssd: (json['hrv_rmssd'] as num?)?.toDouble(),
      restingHeartRate: (json['resting_heart_rate'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WhoopRecoveryToJson(WhoopRecovery instance) =>
    <String, dynamic>{
      'recovery_score': instance.recoveryScore,
      'hrv_rmssd': instance.hrvRmssd,
      'resting_heart_rate': instance.restingHeartRate,
    };

WhoopStrain _$WhoopStrainFromJson(Map<String, dynamic> json) => WhoopStrain(
      strainScore: (json['strain_score'] as num?)?.toDouble(),
      maxHeartRate: (json['max_heart_rate'] as num?)?.toInt(),
      averageHeartRate: (json['average_heart_rate'] as num?)?.toInt(),
      kilojoules: (json['kilojoules'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WhoopStrainToJson(WhoopStrain instance) =>
    <String, dynamic>{
      'strain_score': instance.strainScore,
      'max_heart_rate': instance.maxHeartRate,
      'average_heart_rate': instance.averageHeartRate,
      'kilojoules': instance.kilojoules,
    };

WhoopSleep _$WhoopSleepFromJson(Map<String, dynamic> json) => WhoopSleep(
      totalSleepTime: (json['total_sleep_time'] as num).toInt(),
      sleepEfficiency: (json['sleep_efficiency'] as num?)?.toDouble(),
      slowWaveSleep: (json['slow_wave_sleep'] as num).toInt(),
      remSleep: (json['rem_sleep'] as num).toInt(),
      sleepPerformancePercentage:
          (json['sleep_performance_percentage'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WhoopSleepToJson(WhoopSleep instance) =>
    <String, dynamic>{
      'total_sleep_time': instance.totalSleepTime,
      'sleep_efficiency': instance.sleepEfficiency,
      'slow_wave_sleep': instance.slowWaveSleep,
      'rem_sleep': instance.remSleep,
      'sleep_performance_percentage': instance.sleepPerformancePercentage,
    };

WhoopPhysiologicalData _$WhoopPhysiologicalDataFromJson(
        Map<String, dynamic> json) =>
    WhoopPhysiologicalData(
      heartRateVariabilityRmssd:
          (json['heart_rate_variability_rmssd'] as num?)?.toDouble(),
      restingHeartRate: (json['resting_heart_rate'] as num?)?.toInt(),
      respiratoryRate: (json['respiratory_rate'] as num?)?.toDouble(),
      skinTempCelsius: (json['skin_temp_celsius'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WhoopPhysiologicalDataToJson(
        WhoopPhysiologicalData instance) =>
    <String, dynamic>{
      'heart_rate_variability_rmssd': instance.heartRateVariabilityRmssd,
      'resting_heart_rate': instance.restingHeartRate,
      'respiratory_rate': instance.respiratoryRate,
      'skin_temp_celsius': instance.skinTempCelsius,
    };
