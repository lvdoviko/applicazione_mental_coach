import 'dart:io';
// import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vendor_data_models.dart';

/// Core service for health data collection from various vendors
/// Handles Apple HealthKit, Samsung Health, and other wearable integrations
class HealthDataService {
  /*
  static const List<HealthDataType> _healthTypes = [
    // Core metrics
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    
    // Sleep data
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    
    // Activity data
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    
    // Additional metrics
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
  ];

  final Health _health = Health();
  */
  late final SharedPreferences _prefs;

  /// Initialize service with shared preferences
  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  /// Check if device supports health data collection
  bool get isHealthSupported {
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Check if we have necessary permissions
  Future<bool> hasPermissions() async {
    try {
      if (!isHealthSupported) return false;
      
      /*
      final permissions = await _health.hasPermissions(_healthTypes);
      return permissions ?? false;
      */
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Request health data permissions
  Future<bool> requestPermissions() async {
    try {
      if (!isHealthSupported) return false;
      
      /*
      final granted = await _health.requestAuthorization(_healthTypes);
      
      if (granted) {
        // Store permission grant timestamp
        await _prefs.setString('health_permissions_granted', 
            DateTime.now().toIso8601String());
      }
      
      return granted;
      */
      return false;
    } catch (e) {
      throw Exception('Failed to request health permissions: $e');
    }
  }

  /// Get Apple HealthKit data (iOS only)
  Future<AppleHealthData?> getAppleHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!Platform.isIOS) return null;
    
    /*
    final start = startTime ?? DateTime.now().subtract(const Duration(days: 1));
    final end = endTime ?? DateTime.now();
    
    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _healthTypes,
      );
      
      if (healthData.isEmpty) return null;
      
      return _convertToAppleHealthData(healthData, end);
    } catch (e) {
      throw Exception('Failed to get Apple Health data: $e');
    }
    */
    return null;
  }

  /// Get Samsung Health data (Android Samsung devices only)
  Future<SamsungHealthData?> getSamsungHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (!Platform.isAndroid) return null;
    
    // For Samsung Health, we'd integrate with Samsung Health SDK
    // For now, we'll try to get data through Health Connect if available
    return await _getSamsungThroughHealthConnect(startTime, endTime);
  }

  /// Get raw health data points for specific time range
  /*
  Future<List<HealthDataPoint>> getHealthDataPoints({
    required DateTime startTime,
    required DateTime endTime,
    List<HealthDataType>? types,
  }) async {
    try {
      final dataTypes = types ?? _healthTypes;
      final data = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: dataTypes,
      );
      return data;
    } catch (e) {
      throw Exception('Failed to get health data points: $e');
    }
  }
  */

  /// Get today's health data
  /*
  Future<List<HealthDataPoint>> getTodayHealthData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return await getHealthDataPoints(startTime: startOfDay, endTime: now);
  }
  */

  /// Get last N hours of health data
  /*
  Future<List<HealthDataPoint>> getLastHoursData(int hours) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(hours: hours));
    return await getHealthDataPoints(startTime: start, endTime: now);
  }
  */

  /// Set up background delivery for health data (iOS)
  Future<bool> enableBackgroundDelivery() async {
    if (!Platform.isIOS) return false;
    
    try {
      // TODO: Update for new health package API
      // Background delivery API has changed or is removed in this version
      return false;
    } catch (e) {
      throw Exception('Failed to enable background delivery: $e');
    }
  }

  /// Disable background delivery (iOS)
  Future<void> disableBackgroundDelivery() async {
    if (!Platform.isIOS) return;
    
    try {
      // TODO: Update for new health package API
    } catch (e) {
      throw Exception('Failed to disable background delivery: $e');
    }
  }

  /// Check for new health data since last sync
  /*
  Future<List<HealthDataPoint>> getNewHealthData() async {
    final lastSyncString = _prefs.getString('last_health_sync');
    final lastSync = lastSyncString != null 
        ? DateTime.parse(lastSyncString)
        : DateTime.now().subtract(const Duration(days: 1));
    
    final newData = await getHealthDataPoints(
      startTime: lastSync,
      endTime: DateTime.now(),
    );
    
    // Update last sync timestamp
    await _prefs.setString('last_health_sync', DateTime.now().toIso8601String());
    
    return newData;
  }
  */

  /// Convert Health plugin data to AppleHealthData model
  /*
  AppleHealthData _convertToAppleHealthData(List<HealthDataPoint> data, DateTime timestamp) {
    final heartRateSamples = <HealthSample>[];
    final hrvSamples = <HealthSample>[];
    final sleepSamples = <SleepSample>[];
    final stepSamples = <HealthSample>[];
    final activeEnergySamples = <HealthSample>[];
    final workoutSamples = <WorkoutSample>[];
    final bloodOxygenSamples = <HealthSample>[];
    final restingHrSamples = <HealthSample>[];

    for (final point in data) {
      switch (point.type) {
        case HealthDataType.HEART_RATE:
          if (point.value is NumericHealthValue) {
            heartRateSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'bpm',
            ));
          }
          break;
          
        case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
          if (point.value is NumericHealthValue) {
            hrvSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'ms',
            ));
          }
          break;
          
        case HealthDataType.RESTING_HEART_RATE:
          if (point.value is NumericHealthValue) {
            restingHrSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'bpm',
            ));
          }
          break;
          
        case HealthDataType.SLEEP_IN_BED:
        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_DEEP:
        case HealthDataType.SLEEP_REM:
          sleepSamples.add(SleepSample(
            startTime: point.dateFrom,
            endTime: point.dateTo,
            sleepType: _mapSleepType(point.type),
          ));
          break;
          
        case HealthDataType.STEPS:
          if (point.value is NumericHealthValue) {
            stepSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'count',
            ));
          }
          break;
          
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          if (point.value is NumericHealthValue) {
            activeEnergySamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'kcal',
            ));
          }
          break;
          
        case HealthDataType.WORKOUT:
          if (point.value is WorkoutHealthValue) {
            final workout = point.value as WorkoutHealthValue;
            workoutSamples.add(WorkoutSample(
              workoutType: workout.workoutActivityType.name,
              startTime: point.dateFrom,
              endTime: point.dateTo,
              totalEnergy: workout.totalEnergyBurned?.toDouble(),
              totalDistance: workout.totalDistance?.toDouble(),
            ));
          }
          break;
          
        case HealthDataType.BLOOD_OXYGEN:
          if (point.value is NumericHealthValue) {
            bloodOxygenSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: '%',
            ));
          }
          break;
          
        default:
          break;
      }
    }

    return AppleHealthData(
      timestamp: timestamp,
      heartRateSamples: heartRateSamples,
      hrvSamples: hrvSamples,
      sleepSamples: sleepSamples,
      stepSamples: stepSamples,
      activeEnergySamples: activeEnergySamples,
      workoutSamples: workoutSamples,
      bloodOxygenSamples: bloodOxygenSamples.isNotEmpty ? bloodOxygenSamples : null,
      restingHrSamples: restingHrSamples.isNotEmpty ? restingHrSamples : null,
    );
  }
  */

  /// Map HealthKit sleep types to our model
  /*
  String _mapSleepType(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_IN_BED:
        return 'inBed';
      case HealthDataType.SLEEP_ASLEEP:
        return 'asleep';
      case HealthDataType.SLEEP_DEEP:
        return 'deepSleep';
      case HealthDataType.SLEEP_REM:
        return 'remSleep';
      case HealthDataType.SLEEP_AWAKE:
        return 'awake';
      default:
        return 'unknown';
    }
  }
  */

  /// Get Samsung Health data through Health Connect (Android)
  Future<SamsungHealthData?> _getSamsungThroughHealthConnect(DateTime? startTime, DateTime? endTime) async {
    try {
      /*
      final start = startTime ?? DateTime.now().subtract(const Duration(days: 1));
      final end = endTime ?? DateTime.now();
      
      final healthData = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _healthTypes,
      );
      
      if (healthData.isEmpty) return null;
      
      return _convertToSamsungHealthData(healthData, end);
      */
      return null;
    } catch (e) {
      return null; // Samsung Health not available
    }
  }

  /// Convert generic health data to Samsung Health format
  /*
  SamsungHealthData _convertToSamsungHealthData(List<HealthDataPoint> data, DateTime timestamp) {
    final heartRateSamples = <HealthSample>[];
    final stressSamples = <HealthSample>[];
    final sleepData = <SamsungSleepData>[];
    final stepSamples = <HealthSample>[];
    final exerciseSessions = <SamsungExerciseSession>[];
    final spo2Samples = <HealthSample>[];

    for (final point in data) {
      switch (point.type) {
        case HealthDataType.HEART_RATE:
          if (point.value is NumericHealthValue) {
            heartRateSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'bpm',
            ));
          }
          break;
          
        case HealthDataType.STEPS:
          if (point.value is NumericHealthValue) {
            stepSamples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: 'count',
            ));
          }
          break;
          
        case HealthDataType.SLEEP_IN_BED:
          sleepData.add(SamsungSleepData(
            startTime: point.dateFrom,
            sleepDuration: point.dateTo.difference(point.dateFrom).inMilliseconds,
            efficiency: 85.0, // Would need actual efficiency data
          ));
          break;
          
        case HealthDataType.WORKOUT:
          if (point.value is WorkoutHealthValue) {
            final workout = point.value as WorkoutHealthValue;
            exerciseSessions.add(SamsungExerciseSession(
              exerciseType: workout.workoutActivityType.name,
              startTime: point.dateFrom,
              duration: point.dateTo.difference(point.dateFrom).inSeconds,
              calorie: workout.totalEnergyBurned?.toDouble(),
            ));
          }
          break;
          
        case HealthDataType.BLOOD_OXYGEN:
          if (point.value is NumericHealthValue) {
            spo2Samples.add(HealthSample(
              timestamp: point.dateFrom,
              value: (point.value as NumericHealthValue).numericValue.toDouble(),
              unit: '%',
            ));
          }
          break;
          
        default:
          break;
      }
    }

    return SamsungHealthData(
      timestamp: timestamp,
      heartRate: heartRateSamples,
      stressSamples: stressSamples, // Would need actual stress data from Samsung
      sleepData: sleepData,
      stepCount: stepSamples,
      exerciseSessions: exerciseSessions,
      spo2Samples: spo2Samples.isNotEmpty ? spo2Samples : null,
    );
  }
  */
}