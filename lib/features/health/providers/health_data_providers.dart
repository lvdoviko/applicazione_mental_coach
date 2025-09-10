import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wearable_snapshot.dart';
import '../models/vendor_data_models.dart';
import '../services/health_data_service.dart';
import '../services/health_permissions_service.dart';
import '../services/health_aggregator_service.dart';
import '../services/health_sync_service.dart';

/// Health data state management with Riverpod
/// Follows the existing app architecture using Riverpod instead of BLoC

// Core Services Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final healthDataServiceProvider = Provider<HealthDataService>((ref) {
  return HealthDataService();
});

final healthPermissionsServiceProvider = Provider<HealthPermissionsService>((ref) {
  return HealthPermissionsService(ref.watch(sharedPreferencesProvider));
});

final healthAggregatorServiceProvider = Provider<HealthAggregatorService>((ref) {
  return HealthAggregatorService();
});

final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService(
    healthDataService: ref.watch(healthDataServiceProvider),
    aggregatorService: ref.watch(healthAggregatorServiceProvider),
    prefsService: ref.watch(sharedPreferencesProvider),
  );
});

// Health Data State Models

/// State for health permissions management
class HealthPermissionsState {
  final bool isLoading;
  final Map<String, bool> permissions;
  final String? error;
  final DateTime? lastChecked;

  const HealthPermissionsState({
    this.isLoading = false,
    this.permissions = const {},
    this.error,
    this.lastChecked,
  });

  HealthPermissionsState copyWith({
    bool? isLoading,
    Map<String, bool>? permissions,
    String? error,
    DateTime? lastChecked,
  }) {
    return HealthPermissionsState(
      isLoading: isLoading ?? this.isLoading,
      permissions: permissions ?? this.permissions,
      error: error,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  bool get hasAllPermissions {
    return permissions.values.every((granted) => granted);
  }

  List<String> get missingPermissions {
    return permissions.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}

/// State for health data collection and processing
class HealthDataState {
  final bool isLoading;
  final bool isSyncing;
  final WearableSnapshot? latestSnapshot;
  final List<WearableSnapshot> recentSnapshots;
  final Map<String, VendorHealthData> vendorData;
  final String? error;
  final DateTime? lastSync;
  final HealthDataStats? stats;

  const HealthDataState({
    this.isLoading = false,
    this.isSyncing = false,
    this.latestSnapshot,
    this.recentSnapshots = const [],
    this.vendorData = const {},
    this.error,
    this.lastSync,
    this.stats,
  });

  HealthDataState copyWith({
    bool? isLoading,
    bool? isSyncing,
    WearableSnapshot? latestSnapshot,
    List<WearableSnapshot>? recentSnapshots,
    Map<String, VendorHealthData>? vendorData,
    String? error,
    DateTime? lastSync,
    HealthDataStats? stats,
  }) {
    return HealthDataState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      latestSnapshot: latestSnapshot ?? this.latestSnapshot,
      recentSnapshots: recentSnapshots ?? this.recentSnapshots,
      vendorData: vendorData ?? this.vendorData,
      error: error,
      lastSync: lastSync ?? this.lastSync,
      stats: stats ?? this.stats,
    );
  }

  bool get hasData => latestSnapshot != null;
  bool get isHealthy => latestSnapshot?.flags.length ?? 0 < 3;
  String get riskLevel => latestSnapshot?.toAIContext()['risk_assessment'] ?? 'unknown';
}

/// State for background sync operations
class SyncState {
  final bool isEnabled;
  final bool isRunning;
  final DateTime? lastBackgroundSync;
  final int syncInterval; // minutes
  final SyncStats? stats;
  final String? error;

  const SyncState({
    this.isEnabled = false,
    this.isRunning = false,
    this.lastBackgroundSync,
    this.syncInterval = 15, // default 15 minutes
    this.stats,
    this.error,
  });

  SyncState copyWith({
    bool? isEnabled,
    bool? isRunning,
    DateTime? lastBackgroundSync,
    int? syncInterval,
    SyncStats? stats,
    String? error,
  }) {
    return SyncState(
      isEnabled: isEnabled ?? this.isEnabled,
      isRunning: isRunning ?? this.isRunning,
      lastBackgroundSync: lastBackgroundSync ?? this.lastBackgroundSync,
      syncInterval: syncInterval ?? this.syncInterval,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}

/// State for calibration mode and self-reports
class CalibrationState {
  final bool isEnabled;
  final List<SelfReportEntry> selfReports;
  final int targetReportsPerDay;
  final DateTime? calibrationStarted;
  final String? error;

  const CalibrationState({
    this.isEnabled = false,
    this.selfReports = const [],
    this.targetReportsPerDay = 2,
    this.calibrationStarted,
    this.error,
  });

  CalibrationState copyWith({
    bool? isEnabled,
    List<SelfReportEntry>? selfReports,
    int? targetReportsPerDay,
    DateTime? calibrationStarted,
    String? error,
  }) {
    return CalibrationState(
      isEnabled: isEnabled ?? this.isEnabled,
      selfReports: selfReports ?? this.selfReports,
      targetReportsPerDay: targetReportsPerDay ?? this.targetReportsPerDay,
      calibrationStarted: calibrationStarted ?? this.calibrationStarted,
      error: error,
    );
  }

  int get todaysReports {
    final today = DateTime.now();
    return selfReports.where((report) => 
      report.timestamp.year == today.year &&
      report.timestamp.month == today.month &&
      report.timestamp.day == today.day
    ).length;
  }

  bool get needsMoreReports => todaysReports < targetReportsPerDay;
}

// Supporting Data Models

class HealthDataStats {
  final int totalDataPoints;
  final double avgSyncTime;
  final Map<String, int> vendorDataCounts;
  final DateTime generatedAt;

  const HealthDataStats({
    required this.totalDataPoints,
    required this.avgSyncTime,
    required this.vendorDataCounts,
    required this.generatedAt,
  });
}

class SyncStats {
  final int successfulSyncs;
  final int failedSyncs;
  final double avgSyncDuration;
  final double batteryImpactPercent;
  final DateTime lastCalculated;

  const SyncStats({
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.avgSyncDuration,
    required this.batteryImpactPercent,
    required this.lastCalculated,
  });

  double get successRate => 
    successfulSyncs + failedSyncs > 0 
      ? (successfulSyncs / (successfulSyncs + failedSyncs)) * 100 
      : 0.0;
}

class SelfReportEntry {
  final String id;
  final DateTime timestamp;
  final int mood; // 1-5 scale
  final int anxiety; // 0-10 scale
  final int? stressLevel; // 0-10 scale
  final int? energyLevel; // 1-5 scale
  final int? sleepQuality; // 1-5 scale
  final Map<String, dynamic>? additionalData;

  const SelfReportEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.anxiety,
    this.stressLevel,
    this.energyLevel,
    this.sleepQuality,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
      'anxiety': anxiety,
      'stressLevel': stressLevel,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'additionalData': additionalData,
    };
  }

  factory SelfReportEntry.fromJson(Map<String, dynamic> json) {
    return SelfReportEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mood: json['mood'] as int,
      anxiety: json['anxiety'] as int,
      stressLevel: json['stressLevel'] as int?,
      energyLevel: json['energyLevel'] as int?,
      sleepQuality: json['sleepQuality'] as int?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
}

// State Notifiers (Riverpod Controllers)

/// Health permissions management controller
class HealthPermissionsNotifier extends StateNotifier<HealthPermissionsState> {
  final HealthPermissionsService _permissionsService;

  HealthPermissionsNotifier(this._permissionsService) 
    : super(const HealthPermissionsState());

  /// Check current permission status
  Future<void> checkPermissions() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final permissions = await _permissionsService.checkAllPermissions();
      state = state.copyWith(
        isLoading: false,
        permissions: permissions,
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Request permissions for health data access
  Future<bool> requestPermissions() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final granted = await _permissionsService.requestPermissions();
      if (granted) {
        await checkPermissions();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Some permissions were denied',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Request specific permission
  Future<bool> requestSpecificPermission(String permission) async {
    try {
      final granted = await _permissionsService.requestSpecificPermission(permission);
      await checkPermissions(); // Refresh all permissions
      return granted;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Health data management controller
class HealthDataNotifier extends StateNotifier<HealthDataState> {
  final HealthDataService _healthService;
  final HealthAggregatorService _aggregatorService;

  HealthDataNotifier(this._healthService, this._aggregatorService) 
    : super(const HealthDataState());

  /// Sync health data from all available sources
  Future<void> syncHealthData({bool forceRefresh = false}) async {
    if (state.isSyncing) return;
    
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      // Collect data from all vendors
      final vendorData = <String, VendorHealthData>{};
      
      // Apple HealthKit (iOS)
      try {
        final appleData = await _healthService.getAppleHealthData();
        if (appleData != null) {
          vendorData['apple'] = appleData;
        }
      } catch (e) {
        // Continue with other vendors if Apple fails
      }
      
      // Samsung Health (Android Samsung devices)
      try {
        final samsungData = await _healthService.getSamsungHealthData();
        if (samsungData != null) {
          vendorData['samsung'] = samsungData;
        }
      } catch (e) {
        // Continue with other vendors
      }
      
      // Generate aggregated snapshot
      if (vendorData.isNotEmpty) {
        final snapshot = await _aggregatorService.generateSnapshot(vendorData);
        final updatedSnapshots = [snapshot, ...state.recentSnapshots].take(7).toList();
        
        final stats = HealthDataStats(
          totalDataPoints: vendorData.values.fold(0, (sum, data) => sum + data.availableDataTypes.length),
          avgSyncTime: 0.0, // Calculate based on timing
          vendorDataCounts: vendorData.map((key, value) => MapEntry(key, value.availableDataTypes.length)),
          generatedAt: DateTime.now(),
        );
        
        state = state.copyWith(
          isSyncing: false,
          latestSnapshot: snapshot,
          recentSnapshots: updatedSnapshots,
          vendorData: vendorData,
          lastSync: DateTime.now(),
          stats: stats,
        );
      } else {
        state = state.copyWith(
          isSyncing: false,
          error: 'No health data available from any vendor',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  /// Get health data for specific time window
  Future<WearableSnapshot?> getSnapshotForWindow(String window) async {
    try {
      final vendorData = await _getAllVendorData();
      if (vendorData.isNotEmpty) {
        return await _aggregatorService.generateSnapshot(vendorData, window: window);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    return null;
  }

  /// Clear all health data (for privacy/testing)
  void clearHealthData() {
    state = const HealthDataState();
  }

  Future<Map<String, VendorHealthData>> _getAllVendorData() async {
    final vendorData = <String, VendorHealthData>{};
    
    // Collect from all available vendors
    final appleData = await _healthService.getAppleHealthData();
    if (appleData != null) vendorData['apple'] = appleData;
    
    final samsungData = await _healthService.getSamsungHealthData();
    if (samsungData != null) vendorData['samsung'] = samsungData;
    
    return vendorData;
  }
}

/// Background sync management controller
class SyncNotifier extends StateNotifier<SyncState> {
  final HealthSyncService _syncService;

  SyncNotifier(this._syncService) : super(const SyncState());

  /// Enable background sync
  Future<void> enableBackgroundSync() async {
    try {
      await _syncService.enableBackgroundSync();
      state = state.copyWith(isEnabled: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Disable background sync
  Future<void> disableBackgroundSync() async {
    try {
      await _syncService.disableBackgroundSync();
      state = state.copyWith(isEnabled: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Update sync interval
  Future<void> setSyncInterval(int minutes) async {
    try {
      await _syncService.setSyncInterval(minutes);
      state = state.copyWith(syncInterval: minutes);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get sync statistics
  Future<void> loadSyncStats() async {
    try {
      final stats = await _syncService.getSyncStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Calibration mode controller for self-reports
class CalibrationNotifier extends StateNotifier<CalibrationState> {
  final SharedPreferences _prefs;

  CalibrationNotifier(this._prefs) : super(const CalibrationState()) {
    _loadSelfReports();
  }

  /// Enable calibration mode
  void enableCalibration() {
    state = state.copyWith(
      isEnabled: true,
      calibrationStarted: DateTime.now(),
    );
    _saveTotPrefs();
  }

  /// Disable calibration mode
  void disableCalibration() {
    state = state.copyWith(
      isEnabled: false,
      calibrationStarted: null,
    );
    _saveTotPrefs();
  }

  /// Add self-report entry
  Future<void> addSelfReport(SelfReportEntry report) async {
    final updatedReports = [...state.selfReports, report];
    state = state.copyWith(selfReports: updatedReports);
    await _saveSelfReports();
  }

  /// Remove self-report entry
  Future<void> removeSelfReport(String reportId) async {
    final updatedReports = state.selfReports
        .where((report) => report.id != reportId)
        .toList();
    state = state.copyWith(selfReports: updatedReports);
    await _saveSelfReports();
  }

  /// Get self-reports for specific date range
  List<SelfReportEntry> getSelfReportsInRange(DateTime start, DateTime end) {
    return state.selfReports
        .where((report) => 
          report.timestamp.isAfter(start) && 
          report.timestamp.isBefore(end))
        .toList();
  }

  void _loadSelfReports() {
    final reportsJson = _prefs.getStringList('self_reports') ?? [];
    final reports = reportsJson
        .map((json) => SelfReportEntry.fromJson(
            Map<String, dynamic>.from(
                json as Map)))
        .toList();
    
    final isEnabled = _prefs.getBool('calibration_enabled') ?? false;
    final calibrationStarted = _prefs.getString('calibration_started');
    
    state = state.copyWith(
      selfReports: reports,
      isEnabled: isEnabled,
      calibrationStarted: calibrationStarted != null 
          ? DateTime.parse(calibrationStarted)
          : null,
    );
  }

  Future<void> _saveSelfReports() async {
    final reportsJson = state.selfReports
        .map((report) => report.toJson())
        .toList();
    await _prefs.setStringList('self_reports', 
        reportsJson.map((json) => json.toString()).toList());
  }

  Future<void> _saveTotPrefs() async {
    await _prefs.setBool('calibration_enabled', state.isEnabled);
    if (state.calibrationStarted != null) {
      await _prefs.setString('calibration_started', 
          state.calibrationStarted!.toIso8601String());
    } else {
      await _prefs.remove('calibration_started');
    }
  }
}

// Provider Instances

/// Health permissions state and controller
final healthPermissionsProvider = 
    StateNotifierProvider<HealthPermissionsNotifier, HealthPermissionsState>((ref) {
  return HealthPermissionsNotifier(ref.watch(healthPermissionsServiceProvider));
});

/// Health data state and controller
final healthDataProvider = 
    StateNotifierProvider<HealthDataNotifier, HealthDataState>((ref) {
  return HealthDataNotifier(
    ref.watch(healthDataServiceProvider),
    ref.watch(healthAggregatorServiceProvider),
  );
});

/// Background sync state and controller
final syncProvider = 
    StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.watch(healthSyncServiceProvider));
});

/// Calibration mode state and controller
final calibrationProvider = 
    StateNotifierProvider<CalibrationNotifier, CalibrationState>((ref) {
  return CalibrationNotifier(ref.watch(sharedPreferencesProvider));
});

// Computed Providers

/// Check if we have all required permissions
final hasHealthPermissionsProvider = Provider<bool>((ref) {
  return ref.watch(healthPermissionsProvider).hasAllPermissions;
});

/// Get current health risk level
final healthRiskLevelProvider = Provider<String>((ref) {
  return ref.watch(healthDataProvider).riskLevel;
});

/// Check if health data is available
final hasHealthDataProvider = Provider<bool>((ref) {
  return ref.watch(healthDataProvider).hasData;
});

/// Get latest health snapshot for AI context
final aiHealthContextProvider = Provider<Map<String, dynamic>?>((ref) {
  final snapshot = ref.watch(healthDataProvider).latestSnapshot;
  return snapshot?.toAIContext();
});

/// Check if calibration is needed
final needsCalibrationProvider = Provider<bool>((ref) {
  final calibrationState = ref.watch(calibrationProvider);
  return calibrationState.isEnabled && calibrationState.needsMoreReports;
});

/// Get sync status information
final syncStatusProvider = Provider<String>((ref) {
  final syncState = ref.watch(syncProvider);
  final healthState = ref.watch(healthDataProvider);
  
  if (syncState.isRunning || healthState.isSyncing) {
    return 'Syncing...';
  } else if (healthState.lastSync != null) {
    final timeSinceSync = DateTime.now().difference(healthState.lastSync!);
    if (timeSinceSync.inMinutes < 60) {
      return 'Synced ${timeSinceSync.inMinutes}m ago';
    } else if (timeSinceSync.inHours < 24) {
      return 'Synced ${timeSinceSync.inHours}h ago';
    } else {
      return 'Synced ${timeSinceSync.inDays}d ago';
    }
  } else {
    return 'Never synced';
  }
});