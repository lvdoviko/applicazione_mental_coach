import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'health_data_service.dart';
import 'health_aggregator_service.dart';
import '../providers/health_data_providers.dart';
import '../models/wearable_snapshot.dart';
import '../models/vendor_data_models.dart';

/// Service for managing background synchronization of health data
/// Handles iOS/Android specific background constraints and optimization
class HealthSyncService {
  final HealthDataService _healthDataService;
  final HealthAggregatorService _aggregatorService;
  final SharedPreferences _prefsService;

  static const String _backgroundTaskName = 'health_data_sync';
  static const String _isolatePortName = 'health_sync_isolate';

  HealthSyncService({
    required HealthDataService healthDataService,
    required HealthAggregatorService aggregatorService,
    required SharedPreferences prefsService,
  }) : _healthDataService = healthDataService,
       _aggregatorService = aggregatorService,
       _prefsService = prefsService;

  /// Enable background health data synchronization
  Future<void> enableBackgroundSync() async {
    try {
      await _prefsService.setBool('background_sync_enabled', true);
      await _prefsService.setString('background_sync_enabled_date', 
          DateTime.now().toIso8601String());
      
      if (Platform.isIOS) {
        await _setupiOSBackgroundSync();
      } else if (Platform.isAndroid) {
        await _setupAndroidBackgroundSync();
      }
    } catch (e) {
      throw Exception('Failed to enable background sync: $e');
    }
  }

  /// Disable background synchronization
  Future<void> disableBackgroundSync() async {
    try {
      await _prefsService.setBool('background_sync_enabled', false);
      
      if (Platform.isIOS) {
        await _healthDataService.disableBackgroundDelivery();
      } else if (Platform.isAndroid) {
        await _disableAndroidBackgroundSync();
      }
    } catch (e) {
      throw Exception('Failed to disable background sync: $e');
    }
  }

  /// Check if background sync is enabled
  bool get isBackgroundSyncEnabled {
    return _prefsService.getBool('background_sync_enabled') ?? false;
  }

  /// Set sync interval (in minutes)
  Future<void> setSyncInterval(int minutes) async {
    if (minutes < 15) {
      throw ArgumentError('Minimum sync interval is 15 minutes');
    }
    
    await _prefsService.setInt('sync_interval_minutes', minutes);
    
    // Restart background sync with new interval
    if (isBackgroundSyncEnabled) {
      await disableBackgroundSync();
      await enableBackgroundSync();
    }
  }

  /// Get current sync interval
  int get syncIntervalMinutes {
    return _prefsService.getInt('sync_interval_minutes') ?? 15;
  }

  /// Perform immediate sync (foreground)
  Future<void> syncNow() async {
    final startTime = DateTime.now();
    
    try {
      await _prefsService.setString('last_sync_start', startTime.toIso8601String());
      await _prefsService.setBool('sync_in_progress', true);
      
      // Check permissions first
      final hasPermissions = await _healthDataService.hasPermissions();
      if (!hasPermissions) {
        throw Exception('Health permissions not granted');
      }
      
      // Get new health data
      final newHealthData = await _healthDataService.getNewHealthData();
      
      if (newHealthData.isNotEmpty) {
        // Process vendor data (simplified for now)
        final vendorData = <String, VendorHealthData>{};
        
        // Get Apple Health data if available
        final appleData = await _healthDataService.getAppleHealthData();
        if (appleData != null) {
          vendorData['apple'] = appleData;
        }
        
        // Get Samsung Health data if available
        final samsungData = await _healthDataService.getSamsungHealthData();
        if (samsungData != null) {
          vendorData['samsung'] = samsungData;
        }
        
        // Generate snapshot if we have data
        if (vendorData.isNotEmpty) {
          final snapshot = await _aggregatorService.generateSnapshot(
            vendorData,
            userId: 'current_user', // Would get from auth service
          );
          
          // Save snapshot locally
          await _saveSnapshotLocally(snapshot);
          
          // Update sync stats
          await _updateSyncStats(true, startTime);
        }
      }
      
      await _prefsService.setString('last_successful_sync', 
          DateTime.now().toIso8601String());
    } catch (e) {
      await _updateSyncStats(false, startTime);
      rethrow;
    } finally {
      await _prefsService.setBool('sync_in_progress', false);
    }
  }

  /// Get sync statistics
  Future<SyncStats> getSyncStats() async {
    final successfulSyncs = _prefsService.getInt('successful_syncs') ?? 0;
    final failedSyncs = _prefsService.getInt('failed_syncs') ?? 0;
    final totalSyncTime = _prefsService.getDouble('total_sync_time') ?? 0.0;
    final batteryImpact = _prefsService.getDouble('battery_impact_percent') ?? 0.0;
    
    final avgSyncDuration = successfulSyncs > 0 
        ? totalSyncTime / successfulSyncs 
        : 0.0;
    
    return SyncStats(
      successfulSyncs: successfulSyncs,
      failedSyncs: failedSyncs,
      avgSyncDuration: avgSyncDuration,
      batteryImpactPercent: batteryImpact,
      lastCalculated: DateTime.now(),
    );
  }

  /// Get last sync information
  Map<String, dynamic> getLastSyncInfo() {
    return {
      'last_successful_sync': _prefsService.getString('last_successful_sync'),
      'last_sync_start': _prefsService.getString('last_sync_start'),
      'sync_in_progress': _prefsService.getBool('sync_in_progress') ?? false,
      'successful_syncs': _prefsService.getInt('successful_syncs') ?? 0,
      'failed_syncs': _prefsService.getInt('failed_syncs') ?? 0,
    };
  }

  /// Schedule next background sync
  Future<void> scheduleNextSync() async {
    if (!isBackgroundSyncEnabled) return;
    
    final nextSync = DateTime.now().add(Duration(minutes: syncIntervalMinutes));
    await _prefsService.setString('next_scheduled_sync', nextSync.toIso8601String());
    
    if (Platform.isIOS) {
      await _scheduleiOSBackgroundTask();
    } else if (Platform.isAndroid) {
      await _scheduleAndroidWorkManager();
    }
  }

  /// Check if device is in optimal conditions for sync
  bool _isOptimalSyncCondition() {
    // Check battery level (would need battery_plus plugin)
    // Check network connectivity (would need connectivity_plus plugin)
    // Check if device is charging
    
    // For now, return true
    return true;
  }

  // iOS-specific methods

  /// Set up iOS background sync using HealthKit background delivery
  Future<void> _setupiOSBackgroundSync() async {
    if (!Platform.isIOS) return;
    
    try {
      // Enable HealthKit background delivery
      await _healthDataService.enableBackgroundDelivery();
      
      // Register background task
      await _registeriOSBackgroundTask();
    } catch (e) {
      throw Exception('Failed to setup iOS background sync: $e');
    }
  }

  /// Register iOS background task
  Future<void> _registeriOSBackgroundTask() async {
    // In a real implementation, this would use iOS background task registration
    // For now, we'll use a simplified approach
    
    // Register callback port for isolate communication
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      receivePort.sendPort, 
      _isolatePortName,
    );
    
    // Listen for background sync triggers
    receivePort.listen((data) async {
      if (data == 'sync_health_data') {
        await _performBackgroundSync();
      }
    });
  }

  /// Schedule iOS background task
  Future<void> _scheduleiOSBackgroundTask() async {
    // In a real app, this would use BackgroundTasks framework
    // For now, simulate with timer
  }

  // Android-specific methods

  /// Set up Android background sync using WorkManager
  Future<void> _setupAndroidBackgroundSync() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _scheduleAndroidWorkManager();
    } catch (e) {
      throw Exception('Failed to setup Android background sync: $e');
    }
  }

  /// Schedule Android WorkManager task
  Future<void> _scheduleAndroidWorkManager() async {
    // In a real implementation, this would use android_alarm_manager_plus
    // or work_manager plugin to schedule background work
  }

  /// Disable Android background sync
  Future<void> _disableAndroidBackgroundSync() async {
    // Cancel WorkManager tasks
  }

  // Common background sync methods

  /// Perform background sync (called from background context)
  Future<void> _performBackgroundSync() async {
    if (!_isOptimalSyncCondition()) {
      // Skip sync if conditions aren't optimal
      return;
    }
    
    try {
      // Perform lightweight sync
      await syncNow();
    } catch (e) {
      // Log error but don't crash in background
      print('Background sync failed: $e');
    }
  }

  /// Save health snapshot locally
  Future<void> _saveSnapshotLocally(WearableSnapshot snapshot) async {
    final key = 'health_snapshot_${snapshot.timestamp.millisecondsSinceEpoch}';
    final json = snapshot.toJson();
    
    // Store as JSON string (in a real app, might use a local database)
    await _prefsService.setString(key, json.toString());
    
    // Maintain list of recent snapshots
    final recentSnapshots = _prefsService.getStringList('recent_snapshots') ?? [];
    recentSnapshots.add(key);
    
    // Keep only last 10 snapshots
    if (recentSnapshots.length > 10) {
      final oldKey = recentSnapshots.removeAt(0);
      await _prefsService.remove(oldKey);
    }
    
    await _prefsService.setStringList('recent_snapshots', recentSnapshots);
  }

  /// Update sync statistics
  Future<void> _updateSyncStats(bool success, DateTime startTime) async {
    final duration = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
    
    if (success) {
      final current = _prefsService.getInt('successful_syncs') ?? 0;
      await _prefsService.setInt('successful_syncs', current + 1);
      
      final totalTime = _prefsService.getDouble('total_sync_time') ?? 0.0;
      await _prefsService.setDouble('total_sync_time', totalTime + duration);
    } else {
      final current = _prefsService.getInt('failed_syncs') ?? 0;
      await _prefsService.setInt('failed_syncs', current + 1);
    }
    
    // Update battery impact estimation (simplified)
    final currentImpact = _prefsService.getDouble('battery_impact_percent') ?? 0.0;
    const syncImpact = 0.1; // Estimate 0.1% battery per sync
    await _prefsService.setDouble('battery_impact_percent', currentImpact + syncImpact);
  }

  /// Get recent health snapshots from local storage
  Future<List<WearableSnapshot>> getRecentSnapshots() async {
    final recentKeys = _prefsService.getStringList('recent_snapshots') ?? [];
    final snapshots = <WearableSnapshot>[];
    
    for (final key in recentKeys.reversed) {
      final jsonString = _prefsService.getString(key);
      if (jsonString != null) {
        try {
          final json = Map<String, dynamic>.from(
              jsonString as Map); // Simplified parsing
          final snapshot = WearableSnapshot.fromJson(json);
          snapshots.add(snapshot);
        } catch (e) {
          // Skip corrupted snapshot
          continue;
        }
      }
    }
    
    return snapshots;
  }

  /// Clear all sync data and statistics
  Future<void> clearSyncData() async {
    final keysToRemove = [
      'successful_syncs',
      'failed_syncs',
      'total_sync_time',
      'battery_impact_percent',
      'last_successful_sync',
      'last_sync_start',
      'sync_in_progress',
      'next_scheduled_sync',
    ];
    
    for (final key in keysToRemove) {
      await _prefsService.remove(key);
    }
    
    // Clear recent snapshots
    final recentKeys = _prefsService.getStringList('recent_snapshots') ?? [];
    for (final key in recentKeys) {
      await _prefsService.remove(key);
    }
    await _prefsService.remove('recent_snapshots');
  }
}