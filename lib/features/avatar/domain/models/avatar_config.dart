/// Domain model for avatar configuration
/// 
/// Uses sealed classes (Dart 3) for type-safe state representation
sealed class AvatarConfig {
  const AvatarConfig();
}

/// Avatar is loaded and available
class AvatarConfigLoaded extends AvatarConfig {
  /// Original Ready Player Me URL
  final String remoteUrl;
  
  /// Local file path to the downloaded .glb file
  final String localPath;
  
  /// When the avatar was last updated
  final DateTime lastUpdated;
  
  /// Optional gender for personalized messages
  final String? gender;

  const AvatarConfigLoaded({
    required this.remoteUrl,
    required this.localPath,
    required this.lastUpdated,
    this.gender,
  });

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
        'remoteUrl': remoteUrl,
        'localPath': localPath,
        'lastUpdated': lastUpdated.toIso8601String(),
        'gender': gender,
      };

  /// Create from JSON
  factory AvatarConfigLoaded.fromJson(Map<String, dynamic> json) {
    return AvatarConfigLoaded(
      remoteUrl: json['remoteUrl'] as String,
      localPath: json['localPath'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      gender: json['gender'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarConfigLoaded &&
          runtimeType == other.runtimeType &&
          remoteUrl == other.remoteUrl &&
          localPath == other.localPath;

  @override
  int get hashCode => remoteUrl.hashCode ^ localPath.hashCode;
}

/// No avatar configured yet
class AvatarConfigEmpty extends AvatarConfig {
  const AvatarConfigEmpty();
}
