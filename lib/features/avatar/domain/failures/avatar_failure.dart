/// Custom failure types for avatar operations
/// 
/// Uses sealed classes for exhaustive pattern matching
sealed class AvatarFailure {
  final String message;
  const AvatarFailure(this.message);
}

/// Failed to download avatar file
class DownloadFailure extends AvatarFailure {
  final int? statusCode;
  const DownloadFailure(super.message, {this.statusCode});
}

/// Failed to save/read from local storage
class StorageFailure extends AvatarFailure {
  const StorageFailure(super.message);
}

/// Network connectivity issue
class NetworkFailure extends AvatarFailure {
  const NetworkFailure(super.message);
}

/// Invalid avatar URL or file
class ValidationFailure extends AvatarFailure {
  const ValidationFailure(super.message);
}

/// File system error (permissions, disk full, etc.)
class FileSystemFailure extends AvatarFailure {
  const FileSystemFailure(super.message);
}
