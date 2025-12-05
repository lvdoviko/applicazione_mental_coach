import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:applicazione_mental_coach/core/config/rpm_config.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';

/// WebView-based Ready Player Me avatar creator
/// 
/// Features:
/// - Full-screen RPM editor
/// - JavaScript channel to capture avatar export
/// - Pre-loader with progress during download
/// - Dark mode styling
class RpmAvatarCreator extends ConsumerStatefulWidget {
  final VoidCallback? onAvatarCreated;
  final VoidCallback? onCancel;

  const RpmAvatarCreator({
    super.key,
    this.onAvatarCreated,
    this.onCancel,
  });

  @override
  ConsumerState<RpmAvatarCreator> createState() => _RpmAvatarCreatorState();
}

class _RpmAvatarCreatorState extends ConsumerState<RpmAvatarCreator> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nukeAndLoad();
  }

  Future<void> _nukeAndLoad() async {
    await _nukeAvatarCache();
    await _nukeAvatarCache();
    _initializeWebView();
  }

  Future<void> _nukeAvatarCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // Assuming the file is saved as 'avatar.glb' or similar based on previous context
      // But wait, the config has the path. We don't have the config here easily unless we pass it.
      // The user said: "File('${docsDir.path}/avatars/my_coach.glb')"
      // I'll try to delete the standard path if I can guess it, or just rely on the editor clearing cache.
      // Actually, the user provided code uses `getApplicationDocumentsDirectory`.
      // Let's look at where the file is SAVED. It's in `_handleAvatarExport`.
      // It uses `path_provider` and saves to `appDir.path/avatar.glb`.
      
      final appDir = await getApplicationDocumentsDirectory();
      final avatarFile = File('${appDir.path}/avatar.glb');
      
      if (await avatarFile.exists()) {
        debugPrint("💣 NUKE: Cancellazione avatar vecchio in corso...");
        await avatarFile.delete();
        debugPrint("✅ NUKE: Avatar cancellato.");
      } else {
        debugPrint("⚠️ NUKE: Nessun avatar trovato da cancellare.");
      }
    } catch (e) {
      debugPrint("❌ NUKE ERROR: $e");
    }
  }

  Future<void> _initializeWebView() async {
    // FORZA BRUTA: Scrivilo direttamente nella stringa, non fidarti delle variabili
    // Force fullbody, clear cache, and use HIGH quality to match repository
    final String rpmUrl = "https://demo.readyplayer.me/avatar?frameApi&bodyType=fullbody&quality=high&clearCache=true";
    
    debugPrint('Loading RPM Editor: $rpmUrl');

    // Initialize controller first
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (url) async {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            
            // Inject JavaScript to monitor for avatar URL
            await _controller?.runJavaScript('''
              (function() {
                // 1. Listen for standard RPM postMessage events
                window.addEventListener('message', function(event) {
                  var data = event.data;
                  
                  // Case A: Data is just the URL string (common in frameApi)
                  if (typeof data === 'string' && data.startsWith('https://models.readyplayer.me/')) {
                    window.${RpmConfig.jsChannelName}.postMessage(JSON.stringify({
                      eventName: 'v1.avatar.exported',
                      url: data
                    }));
                  }
                  
                  // Case B: Data is a JSON string
                  if (typeof data === 'string') {
                    try {
                      var json = JSON.parse(data);
                      if (json.eventName === 'v1.avatar.exported') {
                        window.${RpmConfig.jsChannelName}.postMessage(data);
                      }
                    } catch(e) {}
                  }
                  
                  // Case C: Data is an object
                  if (typeof data === 'object' && data.eventName === 'v1.avatar.exported') {
                    window.${RpmConfig.jsChannelName}.postMessage(JSON.stringify(data));
                  }
                });

                // 2. Fallback: DOM Scraping (Keep existing logic)
                var foundUrl = false;
                
                // Function to check for avatar URL
                function checkForAvatarUrl() {
                  if (foundUrl) return true;
                  
                  // Check all input fields
                  var inputs = document.querySelectorAll('input');
                  for (var i = 0; i < inputs.length; i++) {
                    var val = inputs[i].value || '';
                    if (val.includes('models.readyplayer.me') && val.includes('.glb')) {
                      foundUrl = true;
                      window.${RpmConfig.jsChannelName}.postMessage(JSON.stringify({
                        eventName: 'avatar.found',
                        url: val.trim()
                      }));
                      return true;
                    }
                  }
                  
                  // Check page text
                  var bodyText = document.body.innerText || '';
                  var match = bodyText.match(/https:\\/\\/models\\.readyplayer\\.me\\/[a-zA-Z0-9-]+\\.glb/);
                  if (match) {
                    foundUrl = true;
                    window.${RpmConfig.jsChannelName}.postMessage(JSON.stringify({
                      eventName: 'avatar.found',
                      url: match[0]
                    }));
                    return true;
                  }
                  
                  return false;
                }
                
                // Check immediately
                checkForAvatarUrl();
                
                // Set up observer for DOM changes (stops after finding URL)
                var observer = new MutationObserver(function() {
                  if (checkForAvatarUrl()) {
                    observer.disconnect();
                  }
                });
                
                observer.observe(document.body, {
                  childList: true,
                  subtree: true
                });
              })();
            ''');
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _errorMessage = 'Failed to load editor: ${error.description}';
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        RpmConfig.jsChannelName,
        onMessageReceived: _handleJavaScriptMessage,
      );

    // Clear cookies
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();

    // Clear LocalStorage (native method clears for all domains)
    await _controller?.clearLocalStorage();

    // Load actual editor
    if (mounted) {
      _controller?.loadRequest(Uri.parse(rpmUrl));
    }
  }

  /// Handle messages from Ready Player Me JavaScript
  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final eventName = data['eventName'] as String?;

      if (eventName == 'v1.avatar.exported' || eventName == 'avatar.found') {
        final avatarUrl = data['data']?['url'] as String? ?? data['url'] as String?;
        
        if (avatarUrl != null && RpmConfig.isValidRpmUrl(avatarUrl)) {
          _downloadAvatar(avatarUrl);
        } else {
          _showError('Invalid avatar URL received');
        }
      }
    } catch (e) {
      _showError('Failed to process avatar: $e');
    }
  }



  /// Download avatar with progress tracking
  Future<void> _downloadAvatar(String url) async {
    if (!mounted) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Use avatar provider to download
      await ref.read(avatarProvider.notifier).saveAvatar(url);

      // Check if download succeeded
      final state = ref.read(avatarProvider);
      
      if (state is AvatarStateLoaded) {
        // Success - close and notify
        if (mounted) {
          widget.onAvatarCreated?.call();
          Navigator.of(context).pop();
        }
      } else if (state is AvatarStateError) {
        _showError(state.failure.message);
      }
    } catch (e) {
      _showError('Download failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    setState(() {
      _errorMessage = message;
      _isDownloading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: AppColors.white,
            onPressed: () {
              setState(() => _errorMessage = null);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to avatar state for download progress
    ref.listen<AvatarState>(avatarProvider, (previous, next) {
      if (next is AvatarStateDownloading) {
        setState(() => _downloadProgress = next.progress);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Create Your Coach',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
      ),

      body: Stack(
        children: [
          // WebView
          if (_errorMessage == null && _controller != null)
            WebViewWidget(controller: _controller!),

          // Error state
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Oops!',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _initializeWebView();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator (WebView initialization)
          if (_isLoading && _errorMessage == null)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Loading avatar editor...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Download overlay (Pre-loader)
          if (_isDownloading)
            Container(
              color: AppColors.background.withOpacity(0.95),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large Logo
                      SizedBox(
                        height: 160, // Occupy less layout space
                        child: OverflowBox(
                          minHeight: 240,
                          maxHeight: 240,
                          child: Image.asset(
                            'assets/icons/app_logo.png',
                            width: 240,
                            height: 240,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md), // Reduced from xl
                      Text(
                        'Preparing your coach...',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'This will only take a moment',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Progress bar
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _downloadProgress,
                              backgroundColor: AppColors.grey700,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${(_downloadProgress * 100).toInt()}%',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 180), // Push content up visually (increased)
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
