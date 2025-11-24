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
  late final WebViewController _controller;
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
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() {
              _errorMessage = 'Failed to load editor: ${error.description}';
              _isLoading = false;
            });
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

      if (eventName == 'v1.avatar.exported') {
        final avatarUrl = data['data']?['url'] as String?;
        
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
          if (_errorMessage == null)
            WebViewWidget(controller: _controller),

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
