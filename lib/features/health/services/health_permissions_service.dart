import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:health/health.dart';

/// Service for managing health data permissions and consent
/// Handles granular consent management for GDPR compliance
class HealthPermissionsService {
  final SharedPreferences _prefs;
  
  /// Health data types with their user-friendly names
  static const Map<String, String> _permissionNames = {
    'heart_rate': 'Heart Rate',
    'hrv': 'Heart Rate Variability',
    'sleep': 'Sleep Data',
    'steps': 'Steps & Activity',
    'workouts': 'Workouts',
    'blood_oxygen': 'Blood Oxygen',
    'respiratory_rate': 'Respiratory Rate',
  };

  /*
  /// Health data types mapped to HealthKit/Health Connect types
  static const Map<String, List<HealthDataType>> _healthDataTypeMap = {
    'heart_rate': [
      HealthDataType.HEART_RATE,
      HealthDataType.RESTING_HEART_RATE,
    ],
    'hrv': [
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ],
    'sleep': [
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_AWAKE,
    ],
    'steps': [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.DISTANCE_WALKING_RUNNING,
    ],
    'workouts': [
      HealthDataType.WORKOUT,
    ],
    'blood_oxygen': [
      HealthDataType.BLOOD_OXYGEN,
    ],
    'respiratory_rate': [
      HealthDataType.RESPIRATORY_RATE,
    ],
  };
  */

  HealthPermissionsService(this._prefs);

  /// Check all permissions status
  Future<Map<String, bool>> checkAllPermissions() async {
    final permissions = <String, bool>{};
    
    for (final permissionKey in _permissionNames.keys) {
      permissions[permissionKey] = await checkSpecificPermission(permissionKey);
    }
    
    return permissions;
  }

  /// Check specific permission status
  Future<bool> checkSpecificPermission(String permission) async {
    if (!_permissionNames.containsKey(permission)) {
      return false;
    }

    try {
      /*
      final healthTypes = _healthDataTypeMap[permission] ?? [];
      if (healthTypes.isEmpty) return false;

      if (Platform.isIOS) {
        // iOS HealthKit permissions
        final health = Health();
        final hasPermission = await health.hasPermissions(healthTypes);
        return hasPermission ?? false;
      } else if (Platform.isAndroid) {
        // Android permissions
        return await _checkAndroidPermissions(permission);
      }
      */
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Request all health data permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        return await _requestiOSPermissions();
      } else if (Platform.isAndroid) {
        return await _requestAndroidPermissions();
      }
      return false;
    } catch (e) {
      throw Exception('Failed to request permissions: $e');
    }
  }

  /// Request specific permission
  Future<bool> requestSpecificPermission(String permission) async {
    if (!_permissionNames.containsKey(permission)) {
      return false;
    }

    try {
      /*
      final healthTypes = _healthDataTypeMap[permission] ?? [];
      if (healthTypes.isEmpty) return false;

      if (Platform.isIOS) {
        final health = Health();
        final granted = await health.requestAuthorization(healthTypes);
        
        if (granted) {
          await _savePermissionConsent(permission, granted: true);
        }
        
        return granted;
      } else if (Platform.isAndroid) {
        return await _requestSpecificAndroidPermission(permission);
      }
      */
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get user-friendly permission names
  Map<String, String> getPermissionNames() {
    return Map.from(_permissionNames);
  }

  /// Check if user has consented to data processing (GDPR)
  bool hasDataProcessingConsent() {
    return _prefs.getBool('data_processing_consent') ?? false;
  }

  /// Record data processing consent
  Future<void> setDataProcessingConsent(bool granted) async {
    await _prefs.setBool('data_processing_consent', granted);
    await _prefs.setString('data_processing_consent_date', 
        DateTime.now().toIso8601String());
  }

  /// Check if user has consented to health data collection
  bool hasHealthDataConsent() {
    return _prefs.getBool('health_data_consent') ?? false;
  }

  /// Record health data consent
  Future<void> setHealthDataConsent(bool granted) async {
    await _prefs.setBool('health_data_consent', granted);
    await _prefs.setString('health_data_consent_date', 
        DateTime.now().toIso8601String());
    
    // If consent is revoked, clear all health permissions
    if (!granted) {
      await _clearAllPermissionConsents();
    }
  }

  /// Get consent audit trail
  Map<String, dynamic> getConsentAuditTrail() {
    final trail = <String, dynamic>{};
    
    // Data processing consent
    trail['data_processing_consent'] = {
      'granted': hasDataProcessingConsent(),
      'date': _prefs.getString('data_processing_consent_date'),
    };
    
    // Health data consent
    trail['health_data_consent'] = {
      'granted': hasHealthDataConsent(),
      'date': _prefs.getString('health_data_consent_date'),
    };
    
    // Individual permission consents
    for (final permission in _permissionNames.keys) {
      trail['permission_$permission'] = {
        'granted': _prefs.getBool('permission_consent_$permission') ?? false,
        'date': _prefs.getString('permission_consent_date_$permission'),
      };
    }
    
    return trail;
  }

  /// Check if user needs to reconsent (e.g., after app update)
  bool needsReconsent() {
    final lastConsentVersion = _prefs.getString('consent_version');
    const currentVersion = '1.0'; // Update when privacy policy changes
    
    return lastConsentVersion != currentVersion || 
           !hasDataProcessingConsent() ||
           !hasHealthDataConsent();
  }

  /// Update consent version after successful consent flow
  Future<void> updateConsentVersion() async {
    await _prefs.setString('consent_version', '1.0');
    await _prefs.setString('consent_updated_date', 
        DateTime.now().toIso8601String());
  }

  /// Revoke all consents and permissions
  Future<void> revokeAllConsents() async {
    await setDataProcessingConsent(false);
    await setHealthDataConsent(false);
    await _clearAllPermissionConsents();
    
    // Disable background sync
    await _prefs.setBool('background_sync_enabled', false);
  }

  /// Check if we have minimum required permissions for the app to function
  Future<bool> hasMinimumPermissions() async {
    final permissions = await checkAllPermissions();
    
    // Minimum required: heart rate and sleep data
    return (permissions['heart_rate'] ?? false) && 
           (permissions['sleep'] ?? false);
  }

  /// Get list of missing critical permissions
  Future<List<String>> getMissingCriticalPermissions() async {
    final permissions = await checkAllPermissions();
    final missing = <String>[];
    
    // Critical permissions for core functionality
    const criticalPermissions = ['heart_rate', 'sleep', 'steps'];
    
    for (final permission in criticalPermissions) {
      if (!(permissions[permission] ?? false)) {
        missing.add(permission);
      }
    }
    
    return missing;
  }

  // Private methods

  /// Request iOS HealthKit permissions
  Future<bool> _requestiOSPermissions() async {
    /*
    final health = Health();
    
    // Get all health types
    final allHealthTypes = <HealthDataType>[];
    for (final types in _healthDataTypeMap.values) {
      allHealthTypes.addAll(types);
    }
    
    final granted = await health.requestAuthorization(allHealthTypes);
    
    if (granted) {
      // Save individual permission consents
      for (final permission in _permissionNames.keys) {
        await _savePermissionConsent(permission, granted: true);
      }
    }
    
    return granted;
    */
    return false;
  }

  /// Request Android permissions
  Future<bool> _requestAndroidPermissions() async {
    // Request basic permissions first
    final basicPermissions = [
      Permission.activityRecognition,
      Permission.sensors,
    ];
    
    for (final permission in basicPermissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        return false;
      }
    }
    
    // Request Health Connect permissions if available
    try {
      /*
      final health = Health();
      final allHealthTypes = <HealthDataType>[];
      for (final types in _healthDataTypeMap.values) {
        allHealthTypes.addAll(types);
      }
      
      final granted = await health.requestAuthorization(allHealthTypes);
      
      if (granted) {
        for (final permission in _permissionNames.keys) {
          await _savePermissionConsent(permission, granted: true);
        }
      }
      
      return granted;
      */
      return false;
    } catch (e) {
      // Health Connect not available, use basic permissions
      return true;
    }
  }

  /// Check Android permissions
  Future<bool> _checkAndroidPermissions(String permission) async {
    try {
      /*
      final healthTypes = _healthDataTypeMap[permission] ?? [];
      
      if (healthTypes.isEmpty) {
        // Fallback to system permissions
        switch (permission) {
          case 'steps':
            return await Permission.activityRecognition.isGranted;
          case 'heart_rate':
            return await Permission.sensors.isGranted;
          default:
            return false;
        }
      }
      
      // Try Health Connect
      final health = Health();
      final hasPermission = await health.hasPermissions(healthTypes);
      return hasPermission ?? false;
      */
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Request specific Android permission
  Future<bool> _requestSpecificAndroidPermission(String permission) async {
    try {
      /*
      final healthTypes = _healthDataTypeMap[permission] ?? [];
      
      if (healthTypes.isEmpty) {
        return false;
      }
      
      final health = Health();
      final granted = await health.requestAuthorization(healthTypes);
      
      if (granted) {
        await _savePermissionConsent(permission, granted: true);
      }
      
      return granted;
      */
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save permission consent with timestamp
  Future<void> _savePermissionConsent(String permission, {required bool granted}) async {
    await _prefs.setBool('permission_consent_$permission', granted);
    await _prefs.setString('permission_consent_date_$permission', 
        DateTime.now().toIso8601String());
    
    // Also save the platform-specific consent
    final platform = Platform.isIOS ? 'ios' : 'android';
    await _prefs.setBool('permission_${permission}_$platform', granted);
  }

  /// Clear all permission consents
  Future<void> _clearAllPermissionConsents() async {
    for (final permission in _permissionNames.keys) {
      await _prefs.remove('permission_consent_$permission');
      await _prefs.remove('permission_consent_date_$permission');
    }
  }
}