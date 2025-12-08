class AppConfig {
  AppConfig._();

  // App Metadata
  static const String appName = 'KAIX';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Personal AI Mental Wellness Coach';
  
  // Environment
  static const bool isDevelopment = true;
  static const bool enableAnalytics = false; // Privacy-first default
  static const bool enableCrashReporting = false; // Privacy-first default
  
  // API Configuration - MIP Technologies Backend
  static const String baseUrl = 'https://api.miptechnologies.tech';
  static const String wsUrl = 'wss://api.miptechnologies.tech/api/v1/ws/chat?tenant_id=kaix';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration chatTimeout = Duration(minutes: 5);

  // Multi-tenant Configuration
  static const String tenantId = 'kaix';
  static const String apiKey = 'kaix_0o37k_mVbEkJ9c3mT_FIxn1_KZYOuvNfwlM4vYi3XuM=';

  // WebSocket Configuration
  static const Duration wsConnectionTimeout = Duration(seconds: 10);
  static const Duration wsHeartbeatInterval = Duration(seconds: 30);
  static const Duration wsHeartbeatTimeout = Duration(seconds: 10);
  static const int wsMaxReconnectAttempts = 5;
  static const Duration wsReconnectInitialDelay = Duration(seconds: 1);
  static const Duration wsReconnectMaxDelay = Duration(seconds: 30);

  // Auth Configuration
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
  static const Duration guestTokenExpiry = Duration(hours: 24);
  
  // Rate Limiting (Cost optimization)
  static const int maxMessagesPerDay = 100;
  static const int maxMessagesPerHour = 20;
  static const Duration rateLimitWindow = Duration(hours: 1);
  
  // Health Data
  static const List<String> healthDataTypes = [
    'steps',
    'heart_rate',
    'sleep_analysis',
    'active_energy_burned',
    'workout',
    'mindfulness',
  ];
  
  // Avatar Customization
  static const int maxAvatarConfigs = 5;
  static const int avatarCacheHours = 24;
  
  // Privacy & GDPR
  static const Duration dataRetentionPeriod = Duration(days: 365);
  static const Duration exportRequestTimeout = Duration(days: 30);
  static const bool requireExplicitConsent = true;
  static const bool obfuscateNotificationsByDefault = true;
  
  // Chat Features
  static const int maxMessageLength = 2000;
  static const int maxQuickReplies = 3;
  static const Duration typingIndicatorDelay = Duration(milliseconds: 500);
  static const Duration messageBubbleAnimationDuration = Duration(milliseconds: 300);
  
  // A/B Testing Hooks
  static const String defaultMicrocopyVariant = 'empathetic_A';
  static const bool enableVoiceToText = true;
  static const bool enablePushNotifications = true;
  
  // Performance
  static const int maxCachedMessages = 1000;
  static const Duration cacheCleanupInterval = Duration(hours: 6);
  static const int maxImageCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Emergency Support
  static const List<String> emergencyHotlines = [
    '+1-988-662-4357', // US
    '+39-02-2327-2327', // IT
  ];
  
  // Features Flags
  static const bool enableOfflineMode = false;
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = true;
  static const bool enableAnimations = true;
  
  // Debug
  static const bool showDebugInfo = isDevelopment;
  static const bool enableNetworkLogs = isDevelopment;
  static const bool skipOnboarding = false; // For development
  static const bool debugSimulateTokenExpiry = false; // For testing token expiry logic
}