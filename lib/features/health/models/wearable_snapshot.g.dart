// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wearable_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WearableSnapshot _$WearableSnapshotFromJson(Map<String, dynamic> json) =>
    WearableSnapshot(
      userIdHash: json['user_id_hash'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      window: json['window'] as String,
      sleep: SleepMetrics.fromJson(json['sleep'] as Map<String, dynamic>),
      physio:
          PhysiologicalMetrics.fromJson(json['physio'] as Map<String, dynamic>),
      training:
          TrainingMetrics.fromJson(json['training'] as Map<String, dynamic>),
      selfReport: SelfReportMetrics.fromJson(
          json['self_report'] as Map<String, dynamic>),
      context: ContextMetrics.fromJson(json['context'] as Map<String, dynamic>),
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toList(),
      summaryText: json['summary_text'] as String,
      pineconeId: json['pinecone_id'] as String?,
    );

Map<String, dynamic> _$WearableSnapshotToJson(WearableSnapshot instance) {
  final val = <String, dynamic>{
    'user_id_hash': instance.userIdHash,
    'timestamp': instance.timestamp.toIso8601String(),
    'window': instance.window,
    'sleep': instance.sleep.toJson(),
    'physio': instance.physio.toJson(),
    'training': instance.training.toJson(),
    'self_report': instance.selfReport.toJson(),
    'context': instance.context.toJson(),
    'flags': instance.flags,
    'summary_text': instance.summaryText,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pinecone_id', instance.pineconeId);
  return val;
}

SleepMetrics _$SleepMetricsFromJson(Map<String, dynamic> json) => SleepMetrics(
      avgHours: (json['avg_hours'] as num).toDouble(),
      efficiency: (json['efficiency'] as num).toDouble(),
      lastNightsHours: (json['last_nights_hours'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      deepSleepPct: (json['deep_sleep_pct'] as num?)?.toDouble(),
      remSleepPct: (json['rem_sleep_pct'] as num?)?.toDouble(),
      onsetMinutes: (json['onset_minutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SleepMetricsToJson(SleepMetrics instance) {
  final val = <String, dynamic>{
    'avg_hours': instance.avgHours,
    'efficiency': instance.efficiency,
    'last_nights_hours': instance.lastNightsHours,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('deep_sleep_pct', instance.deepSleepPct);
  writeNotNull('rem_sleep_pct', instance.remSleepPct);
  writeNotNull('onset_minutes', instance.onsetMinutes);
  return val;
}

PhysiologicalMetrics _$PhysiologicalMetricsFromJson(
        Map<String, dynamic> json) =>
    PhysiologicalMetrics(
      restingHr: (json['resting_hr'] as num).toDouble(),
      restingHrDeltaVsWeek:
          (json['resting_hr_delta_vs_week'] as num).toDouble(),
      hrvRmssd: (json['hrv_rmssd'] as num).toDouble(),
      hrvDeltaPct: (json['hrv_delta_pct'] as num).toDouble(),
      spo2: (json['spo2'] as num?)?.toDouble(),
      avgHr: (json['avg_hr'] as num?)?.toDouble(),
      workoutAvgHr: (json['workout_avg_hr'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PhysiologicalMetricsToJson(
    PhysiologicalMetrics instance) {
  final val = <String, dynamic>{
    'resting_hr': instance.restingHr,
    'resting_hr_delta_vs_week': instance.restingHrDeltaVsWeek,
    'hrv_rmssd': instance.hrvRmssd,
    'hrv_delta_pct': instance.hrvDeltaPct,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('spo2', instance.spo2);
  writeNotNull('avg_hr', instance.avgHr);
  writeNotNull('workout_avg_hr', instance.workoutAvgHr);
  return val;
}

TrainingMetrics _$TrainingMetricsFromJson(Map<String, dynamic> json) =>
    TrainingMetrics(
      lastSession: json['last_session'] == null
          ? null
          : TrainingSession.fromJson(
              json['last_session'] as Map<String, dynamic>),
      weeklyLoad: (json['weekly_load'] as num).toDouble(),
      dailySteps: (json['daily_steps'] as num?)?.toInt(),
      activeCalories: (json['active_calories'] as num?)?.toDouble(),
      sessionsThisWeek: (json['sessions_this_week'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrainingMetricsToJson(TrainingMetrics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('last_session', instance.lastSession?.toJson());
  val['weekly_load'] = instance.weeklyLoad;
  writeNotNull('daily_steps', instance.dailySteps);
  writeNotNull('active_calories', instance.activeCalories);
  writeNotNull('sessions_this_week', instance.sessionsThisWeek);
  return val;
}

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      type: json['type'] as String,
      durationMin: (json['duration_min'] as num).toInt(),
      intensity: (json['intensity'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'type': instance.type,
      'duration_min': instance.durationMin,
      'intensity': instance.intensity,
      'timestamp': instance.timestamp.toIso8601String(),
      'details': instance.details,
    };

SelfReportMetrics _$SelfReportMetricsFromJson(Map<String, dynamic> json) =>
    SelfReportMetrics(
      mood: (json['mood'] as num).toInt(),
      anxiety: (json['anxiety'] as num).toInt(),
      stressLevel: (json['stress_level'] as num?)?.toInt(),
      energyLevel: (json['energy_level'] as num?)?.toInt(),
      motivation: (json['motivation'] as num?)?.toInt(),
      sleepQualityPerceived: (json['sleep_quality_perceived'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SelfReportMetricsToJson(SelfReportMetrics instance) {
  final val = <String, dynamic>{
    'mood': instance.mood,
    'anxiety': instance.anxiety,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('stress_level', instance.stressLevel);
  writeNotNull('energy_level', instance.energyLevel);
  writeNotNull('motivation', instance.motivation);
  writeNotNull('sleep_quality_perceived', instance.sleepQualityPerceived);
  return val;
}

ContextMetrics _$ContextMetricsFromJson(Map<String, dynamic> json) =>
    ContextMetrics(
      daysToCompetition: (json['days_to_competition'] as num?)?.toInt(),
      travelFlag: json['travel_flag'] as bool,
      timezoneChanges: (json['timezone_changes'] as num?)?.toInt(),
      externalStress: (json['external_stress'] as num?)?.toInt(),
      healthIssues: (json['health_issues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ContextMetricsToJson(ContextMetrics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('days_to_competition', instance.daysToCompetition);
  val['travel_flag'] = instance.travelFlag;
  writeNotNull('timezone_changes', instance.timezoneChanges);
  writeNotNull('external_stress', instance.externalStress);
  writeNotNull('health_issues', instance.healthIssues);
  return val;
}
