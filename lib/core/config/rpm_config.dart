/// Configuration constants for Ready Player Me integration
class RpmConfig {
  RpmConfig._();

  /// Ready Player Me subdomain
  /// 
  /// Use custom subdomain for enterprise branding:
  /// - Custom: 'yourapp.readyplayer.me'
  /// - Demo: 'demo.readyplayer.me'
  static const String subdomain = 'demo.readyplayer.me';

  /// Body type for avatars
  /// 
  /// Options:
  /// - 'halfbody': Upper body only (RECOMMENDED for Mental Coach)
  ///   - Smaller file size (~2-3MB)
  ///   - Better facial detail on small screens
  ///   - Faster loading
  /// - 'fullbody': Full body avatar (~5-8MB)
  static const String bodyType = 'fullbody';

  /// Allow users to edit existing avatars
  /// 
  /// If true, users can modify their current avatar
  /// If false, users start fresh each time
  static const bool clearCache = false;

  /// Enable quick start mode
  /// 
  /// Skips intro screens in RPM editor
  static const bool quickStart = true;

  /// JavaScript channel name for communication
  /// 
  /// Used to receive avatar export events from WebView
  static const String jsChannelName = 'readyplayerme';

  /// Timeout for WebView loading
  static const Duration webViewTimeout = Duration(seconds: 30);

  /// Build complete RPM editor URL
  static String get editorUrl {
    final params = <String, String>{
      'frameApi': '',
      'bodyType': bodyType,
      if (clearCache) 'clearCache': '',
      if (quickStart) 'quickStart': '',
    };

    final queryString = params.entries
        .map((e) => e.value.isEmpty ? e.key : '${e.key}=${e.value}')
        .join('&');

    return 'https://$subdomain/avatar?$queryString';
  }

  /// Validate if URL is from Ready Player Me
  static bool isValidRpmUrl(String url) {
    return url.startsWith('https://models.readyplayer.me/') &&
           url.endsWith('.glb');
  }

  /// Extract avatar ID from RPM URL
  static String? extractAvatarId(String url) {
    final regex = RegExp(r'https://models\.readyplayer\.me/([^/]+)\.glb');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }
}
