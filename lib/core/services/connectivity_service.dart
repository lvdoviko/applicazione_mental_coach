import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity status
/// Used by OfflineFallbackEngine and ChatWebSocketService
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late final StreamController<ConnectivityStatus> _statusController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if currently connected to internet
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  /// Check if currently disconnected
  bool get isDisconnected => _currentStatus == ConnectivityStatus.disconnected;

  bool _isInitialized = false;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _statusController = StreamController<ConnectivityStatus>.broadcast();
    
    // Get initial connectivity status
    await _updateConnectivityStatus();
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: _onConnectivityError,
    );
    
    _isInitialized = true;
  }

  /// Manually check connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    await _updateConnectivityStatus();
    return _currentStatus;
  }

  /// Test actual internet connectivity (not just network interface)
  Future<bool> hasInternetConnection() async {
    try {
      // Simple connectivity test - ping a reliable server
      // In production, you might want to ping your own API endpoint
      final result = await _connectivity.checkConnectivity();
      
      if (result.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // Additional check could be added here to verify actual internet access
      // For now, we assume that having a network connection means internet access
      return true;
      
    } catch (e) {
      debugPrint('Internet connectivity check failed: $e');
      return false;
    }
  }

  Future<void> _updateConnectivityStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final newStatus = _parseConnectivityResult(result);
      
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _statusController.add(_currentStatus);
        debugPrint('Connectivity status changed to: $_currentStatus');
      }
    } catch (e) {
      debugPrint('Failed to update connectivity status: $e');
      _currentStatus = ConnectivityStatus.unknown;
      _statusController.add(_currentStatus);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final newStatus = _parseConnectivityResult(results);
    
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
      debugPrint('Connectivity changed to: $_currentStatus');
      
      // If we think we're connected, verify actual internet access
      if (_currentStatus == ConnectivityStatus.connected) {
        final hasInternet = await hasInternetConnection();
        if (!hasInternet) {
          _currentStatus = ConnectivityStatus.disconnected;
          _statusController.add(_currentStatus);
          debugPrint('Network available but no internet access');
        }
      }
    }
  }

  void _onConnectivityError(dynamic error) {
    debugPrint('Connectivity monitoring error: $error');
    _currentStatus = ConnectivityStatus.unknown;
    _statusController.add(_currentStatus);
  }

  ConnectivityStatus _parseConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.disconnected;
    }
    
    // If we have any connection type (mobile, wifi, ethernet), consider connected
    if (results.any((result) => 
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn)) {
      return ConnectivityStatus.connected;
    }
    
    return ConnectivityStatus.unknown;
  }

  /// Get human-readable connection type
  String getConnectionType() {
    switch (_currentStatus) {
      case ConnectivityStatus.connected:
        return 'Connected';
      case ConnectivityStatus.disconnected:
        return 'Disconnected';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }

  /// Get detailed connection info for debugging
  Future<Map<String, dynamic>> getConnectionDetails() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInternet = await hasInternetConnection();
      
      return {
        'status': _currentStatus.name,
        'connection_types': results.map((r) => r.name).toList(),
        'has_internet': hasInternet,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Dispose the service and clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}

/// Connectivity status enum
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Extension for easy string conversion
extension ConnectivityStatusExtension on ConnectivityStatus {
  String get displayName {
    switch (this) {
      case ConnectivityStatus.connected:
        return 'Connected';
      case ConnectivityStatus.disconnected:
        return 'Offline';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isOnline => this == ConnectivityStatus.connected;
  bool get isOffline => this == ConnectivityStatus.disconnected;
}