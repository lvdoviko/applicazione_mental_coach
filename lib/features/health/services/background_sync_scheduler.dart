import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/api/secure_api_client.dart';
import '../../../core/services/connectivity_service.dart';
import 'health_aggregator_service.dart';
import 'health_data_service.dart';

/// Background service for scheduling and executing health data synchronization
/// Follows the KAIX Backend Platform integration pattern
class BackgroundSyncScheduler {
  static const Duration _syncInterval = Duration(hours: 6); // Sync every 6 hours
  static const Duration _retryInterval = Duration(minutes: 15);
  static const int _maxRetryAttempts = 3;

  final SecureApiClient _apiClient;
  final HealthAggregatorService _aggregatorService;
  final HealthDataService _healthDataService;
  final ConnectivityService _connectivityService;

  Timer? _syncTimer;
  Timer? _retryTimer;
  bool _isRunning = false;
  int _retryAttempts = 0;
  DateTime? _lastSuccessfulSync;
  
  // Stream controllers for sync status
  late final StreamController<SyncStatus> _statusController;
  late final StreamController<SyncProgress> _progressController;
  late final StreamController<SyncError> _errorController;

  BackgroundSyncScheduler({
    required SecureApiClient apiClient,
    required HealthAggregatorService aggregatorService,
    required HealthDataService healthDataService,
    required ConnectivityService connectivityService,
  })  : _apiClient = apiClient,
        _aggregatorService = aggregatorService,
        _healthDataService = healthDataService,
        _connectivityService = connectivityService {
    _statusController = StreamController<SyncStatus>.broadcast();
    _progressController = StreamController<SyncProgress>.broadcast();
    _errorController = StreamController<SyncError>.broadcast();
  }

  // Public streams
  Stream<SyncStatus> get statusStream => _statusController.stream;
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<SyncError> get errorStream => _errorController.stream;

  // Getters
  bool get isRunning => _isRunning;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  bool get canSync => _connectivityService.isConnected;

  /// Start the background sync scheduler
  Future<void> start() async {
    if (_isRunning) return;

    _isRunning = true;
    _statusController.add(SyncStatus.started);
    
    // Perform initial sync if connected
    if (canSync) {
      await _performSync();
    } else {
      _statusController.add(SyncStatus.waitingForConnection);
    }

    // Schedule regular syncs
    _schedulePeriodSync();

    // Listen to connectivity changes
    _connectivityService.statusStream.listen(_onConnectivityChanged);
    
    debugPrint('BackgroundSyncScheduler started');
  }

  /// Stop the background sync scheduler
  void stop() {
    _isRunning = false;
    _syncTimer?.cancel();
    _retryTimer?.cancel();
    _statusController.add(SyncStatus.stopped);
    debugPrint('BackgroundSyncScheduler stopped');
  }

  /// Manually trigger a sync
  Future<void> syncNow() async {
    if (!canSync) {
      _errorController.add(SyncError.noConnection());
      return;
    }

    await _performSync();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'is_running': _isRunning,
      'last_successful_sync': _lastSuccessfulSync?.toIso8601String(),
      'retry_attempts': _retryAttempts,
      'can_sync': canSync,
      'connection_status': _connectivityService.currentStatus.name,
    };
  }

  // === Private Methods ===

  void _schedulePeriodSync() {
    _syncTimer?.cancel();
    
    if (!_isRunning) return;
    
    _syncTimer = Timer.periodic(_syncInterval, (timer) async {
      if (_isRunning && canSync) {
        await _performSync();
      }
    });
  }

  void _onConnectivityChanged(ConnectivityStatus status) {
    if (status == ConnectivityStatus.connected && _isRunning) {
      // Connection restored, attempt sync
      _performSync();
    } else if (status == ConnectivityStatus.disconnected) {
      _statusController.add(SyncStatus.waitingForConnection);
    }
  }

  Future<void> _performSync() async {
    if (!canSync) {
      _statusController.add(SyncStatus.waitingForConnection);
      return;
    }

    try {
      _statusController.add(SyncStatus.syncing);
      _progressController.add(SyncProgress(0.0, 'Checking permissions...'));

      // Step 1: Check if health sync is enabled and permissions granted
      final hasPermissions = await _healthDataService.hasPermissions();
      if (!hasPermissions) {
        _errorController.add(SyncError.noPermissions());
        _statusController.add(SyncStatus.failed);
        return;
      }

      _progressController.add(SyncProgress(0.2, 'Aggregating health data...'));

      // Step 2: Generate current health snapshot
      final vendorData = await _healthDataService.getVendorHealthData();
      if (vendorData.isEmpty) {
        _errorController.add(SyncError.noHealthData());
        _statusController.add(SyncStatus.failed);
        return;
      }
      
      final snapshot = await _aggregatorService.generateSnapshot(vendorData);

      _progressController.add(SyncProgress(0.6, 'Uploading to backend...'));

      // Step 3: Upload snapshot to KAIX Backend Platform
      final response = await _apiClient.uploadHealthSnapshot(snapshot);
      
      _progressController.add(SyncProgress(0.9, 'Finalizing sync...'));

      // Step 4: Update local tracking
      _lastSuccessfulSync = DateTime.now();
      _retryAttempts = 0;
      
      _progressController.add(SyncProgress(1.0, 'Sync completed successfully'));
      _statusController.add(SyncStatus.completed);

      debugPrint('Health data sync completed successfully. Pinecone ID: ${response.pineconeId}');

    } catch (e) {
      await _handleSyncError(e);
    }
  }

  Future<void> _handleSyncError(dynamic error) async {
    _retryAttempts++;
    
    debugPrint('Health sync failed (attempt $_retryAttempts): $error');
    
    final syncError = SyncError.syncFailed(error.toString(), _retryAttempts);
    _errorController.add(syncError);

    if (_retryAttempts < _maxRetryAttempts) {
      _statusController.add(SyncStatus.retrying);
      _scheduleRetry();
    } else {
      _statusController.add(SyncStatus.failed);
      _retryAttempts = 0; // Reset for next cycle
      debugPrint('Max retry attempts reached. Will retry on next scheduled sync.');
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    
    final retryDelay = Duration(
      minutes: (_retryInterval.inMinutes * _retryAttempts).clamp(15, 60),
    );
    
    debugPrint('Scheduling sync retry in ${retryDelay.inMinutes} minutes');
    
    _retryTimer = Timer(retryDelay, () async {
      if (_isRunning && canSync) {
        await _performSync();
      }
    });
  }

  /// Get health data freshness
  Duration? getDataFreshness() {
    if (_lastSuccessfulSync == null) return null;
    return DateTime.now().difference(_lastSuccessfulSync!);
  }

  /// Check if sync is overdue
  bool isSyncOverdue() {
    if (_lastSuccessfulSync == null) return true;
    final timeSinceSync = getDataFreshness()!;
    return timeSinceSync > _syncInterval * 2; // Consider overdue after 2x normal interval
  }

  /// Force sync with specific window
  Future<void> syncWithWindow(String window) async {
    if (!canSync) {
      _errorController.add(SyncError.noConnection());
      return;
    }

    try {
      _statusController.add(SyncStatus.syncing);
      
      final vendorData = await _healthDataService.getVendorHealthData();
      if (vendorData.isEmpty) {
        _errorController.add(SyncError.noHealthData());
        _statusController.add(SyncStatus.failed);
        return;
      }
      
      final snapshot = await _aggregatorService.generateSnapshot(vendorData, window: window);

      await _apiClient.uploadHealthSnapshot(snapshot);
      
      _lastSuccessfulSync = DateTime.now();
      _retryAttempts = 0;
      _statusController.add(SyncStatus.completed);
      
    } catch (e) {
      await _handleSyncError(e);
    }
  }

  /// Clean up resources
  void dispose() {
    stop();
    _statusController.close();
    _progressController.close();
    _errorController.close();
  }
}

// === Supporting Classes ===

enum SyncStatus {
  started,
  syncing,
  completed,
  failed,
  retrying,
  waitingForConnection,
  stopped,
}

class SyncProgress {
  final double progress; // 0.0 to 1.0
  final String message;
  final DateTime timestamp;

  SyncProgress(this.progress, this.message) : timestamp = DateTime.now();

  @override
  String toString() => 'SyncProgress($progress): $message';
}

class SyncError {
  final String message;
  final SyncErrorType type;
  final int? retryAttempt;
  final DateTime timestamp;

  SyncError._(this.message, this.type, [this.retryAttempt]) 
      : timestamp = DateTime.now();

  factory SyncError.noConnection() =>
      SyncError._('No internet connection available', SyncErrorType.noConnection);

  factory SyncError.noPermissions() =>
      SyncError._('Health data permissions not granted', SyncErrorType.noPermissions);

  factory SyncError.noHealthData() =>
      SyncError._('No health data available for sync', SyncErrorType.noHealthData);

  factory SyncError.syncFailed(String details, int attempt) =>
      SyncError._('Sync failed: $details', SyncErrorType.syncFailed, attempt);

  factory SyncError.authFailed() =>
      SyncError._('Authentication failed during sync', SyncErrorType.authFailed);

  @override
  String toString() => 'SyncError($type): $message${retryAttempt != null ? ' (attempt $retryAttempt)' : ''}';
}

enum SyncErrorType {
  noConnection,
  noPermissions,
  noHealthData,
  syncFailed,
  authFailed,
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.started:
        return 'Started';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.completed:
        return 'Up to date';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.retrying:
        return 'Retrying...';
      case SyncStatus.waitingForConnection:
        return 'Waiting for connection';
      case SyncStatus.stopped:
        return 'Stopped';
    }
  }

  bool get isActive => this == SyncStatus.syncing || this == SyncStatus.retrying;
  bool get isError => this == SyncStatus.failed;
  bool get isSuccess => this == SyncStatus.completed;
}