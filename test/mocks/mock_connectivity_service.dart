import 'dart:async';
import 'package:applicazione_mental_coach/core/services/connectivity_service.dart';

/// Mock connectivity service for testing
/// Implements the same interface as ConnectivityService without platform dependencies
class MockConnectivityService {
  late final StreamController<ConnectivityStatus> _statusController;
  ConnectivityStatus _currentStatus = ConnectivityStatus.connected;
  bool _isInitialized = false;

  MockConnectivityService({ConnectivityStatus initialStatus = ConnectivityStatus.connected}) {
    _currentStatus = initialStatus;
    _statusController = StreamController<ConnectivityStatus>.broadcast();
  }

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if currently connected to internet
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  /// Check if currently disconnected
  bool get isDisconnected => _currentStatus == ConnectivityStatus.disconnected;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    _isInitialized = true;
  }

  /// Manually check connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    return _currentStatus;
  }

  /// Test actual internet connectivity (not just network interface)
  Future<bool> hasInternetConnection() async {
    return _currentStatus == ConnectivityStatus.connected;
  }

  /// Get detailed connection information
  Future<Map<String, dynamic>> getConnectionDetails() async {
    return {
      'status': _currentStatus.name,
      'timestamp': DateTime.now().toIso8601String(),
      'type': _currentStatus == ConnectivityStatus.connected ? 'wifi' : 'none',
      'is_metered': false,
      'available_types': _currentStatus == ConnectivityStatus.connected ? ['wifi'] : <String>[],
    };
  }

  /// Force connectivity status update
  Future<void> forceConnectivityUpdate() async {
    _statusController.add(_currentStatus);
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _statusController.close();
    }
  }

  // Test helper methods
  void setConnected(bool connected) {
    final newStatus = connected ? ConnectivityStatus.connected : ConnectivityStatus.disconnected;
    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      if (_isInitialized) {
        _statusController.add(_currentStatus);
      }
    }
  }

  void simulateConnectionLoss() {
    setConnected(false);
  }

  void simulateConnectionRestore() {
    setConnected(true);
  }
}