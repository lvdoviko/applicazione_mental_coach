import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/features/avatar/services/avatar_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 3D Avatar Viewer with Local-First loading
/// 
/// Features:
/// - Loads .glb from local file system (offline support)
/// - Applies external animations via animation-src
/// - Configurable camera controls
/// - Error fallback to placeholder
class AvatarViewer3D extends ConsumerStatefulWidget {
  final AvatarConfig config;
  final double? width;
  final double? height;
  final bool enableCameraControls;
  final bool autoRotate;
  final String? animationName; // 'idle' or 'talking'

  const AvatarViewer3D({
    super.key,
    required this.config,
    this.width,
    this.height,
    this.enableCameraControls = false,
    this.autoRotate = false,
    this.animationName,
  });

  @override
  ConsumerState<AvatarViewer3D> createState() => _AvatarViewer3DState();
}

class _AvatarViewer3DState extends ConsumerState<AvatarViewer3D> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late Key _webViewKey; // Stable key for this session

  @override
  void initState() {
    super.initState();
    // Generate key ONCE when screen opens
    _webViewKey = UniqueKey(); 
    
    // ONE-TIME REFRESH (Android Only): 
    // Wait for screen to stabilize, then force ONE recreation to fix black screen.
    if (Platform.isAndroid) {
      _scheduleAndroidRefresh();
    }
    
    // Initialize engine immediately (Standard behavior)
    _checkEngineStatus();
  }

  void _scheduleAndroidRefresh() async {
    // Wait for transition to complete + buffer
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // FORCE RECREATION: This fixes the black screen/glitch
    setState(() {
      _webViewKey = UniqueKey(); 
    });
    
    // Reload content into the new view
    _updateContent();
  }

  void _checkEngineStatus() {
    final engine = ref.read(avatarEngineProvider);
    if (engine.isInitialized && engine.controller != null) {
      setState(() {
        _isLoading = false;
      });
    } else {
      // If not initialized (e.g. direct navigation), initialize it
      _initEngine();
    }
  }

  Future<void> _initEngine() async {
    try {
      final engine = ref.read(avatarEngineProvider);
      await engine.initialize();
      
      // Load content if config is ready
      if (widget.config is AvatarConfigLoaded) {
        final url = (widget.config as AvatarConfigLoaded).remoteUrl;
        await engine.loadContent(
          avatarUrl: url, 
          animationAsset: 'assets/animations/idle.glb'
        );
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(AvatarViewer3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      _updateContent();
    }
  }

  Future<void> _updateContent() async {
    final engine = ref.read(avatarEngineProvider);
    if (widget.config is AvatarConfigLoaded) {
      final url = (widget.config as AvatarConfigLoaded).remoteUrl;
      await engine.loadContent(
        avatarUrl: url, 
        animationAsset: 'assets/animations/idle.glb'
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPlaceholder();
    }

    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    final engine = ref.watch(avatarEngineProvider);
    
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: engine.controller != null 
        ? Container(
            color: Colors.transparent,
            child: WebViewWidget(
              key: _webViewKey, // Use stable key (updated once by refresh)
              controller: engine.controller!
            ),
          )
        : const SizedBox(),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Loading coach...',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.3),
                ],
              ),
            ),
            child: const Icon(
              Icons.psychology,
              size: 30,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Coach Avatar',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                _errorMessage!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


