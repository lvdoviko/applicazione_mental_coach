import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
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
      )
      ..loadRequest(Uri.parse(RpmConfig.editorUrl));
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

  /// Extract avatar URL from current page (fallback method)
  Future<void> _extractAvatarUrlFromPage() async {
    if (_controller == null) {
      _showError('WebView not initialized');
      return;
    }

    try {
      // First, try to get the current URL
      final currentUrl = await _controller!.currentUrl();
      if (currentUrl != null) {
        // Check if current URL contains avatar URL as parameter
        final uri = Uri.parse(currentUrl);
        final avatarUrl = uri.queryParameters['url'] ?? 
                         uri.queryParameters['avatarUrl'] ??
                         uri.queryParameters['model'];
        
        if (avatarUrl != null && RpmConfig.isValidRpmUrl(avatarUrl)) {
          _downloadAvatar(avatarUrl);
          return;
        }
      }

      // Execute JavaScript to find the avatar URL in the page
      final result = await _controller!.runJavaScriptReturningResult(
        '''
        (function() {
          // Method 1: Try to find the URL in an input field
          var inputs = document.querySelectorAll('input');
          for (var i = 0; i < inputs.length; i++) {
            var val = inputs[i].value || '';
            if (val.includes('models.readyplayer.me') && val.includes('.glb')) {
              return val.trim();
            }
          }
          
          // Method 2: Search in all text content
          var bodyText = document.body.innerText || document.body.textContent || '';
          var urlPattern = /https:\\/\\/models\\.readyplayer\\.me\\/[a-zA-Z0-9-]+\\.glb/;
          var match = bodyText.match(urlPattern);
          if (match) {
            return match[0];
          }
          
          // Method 3: Search in all links
          var links = document.querySelectorAll('a');
          for (var i = 0; i < links.length; i++) {
            var href = links[i].href || '';
            if (href.includes('models.readyplayer.me') && href.includes('.glb')) {
              return href;
            }
          }
          
          return '';
        })();
        '''
      );

      final urlString = result?.toString() ?? '';
      
      if (urlString.isNotEmpty && 
          urlString != 'null' && 
          urlString != '<null>' &&
          RpmConfig.isValidRpmUrl(urlString)) {
        _downloadAvatar(urlString);
      } else {
        _showError('Could not find avatar URL. Please wait for the avatar to finish generating.');
      }
    } catch (e) {
      _showError('Failed to extract URL: $e');
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
      floatingActionButton: !_isDownloading && !_isLoading && _errorMessage == null
          ? FloatingActionButton.extended(
              onPressed: _extractAvatarUrlFromPage,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.download),
              label: const Text('Use This Avatar'),
            )
          : null,
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
                      // Animated coach icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                size: 40,
                                color: AppColors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
