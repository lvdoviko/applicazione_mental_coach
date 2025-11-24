import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:o3d/o3d.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';

/// 3D Avatar Viewer with Local-First loading
/// 
/// Features:
/// - Loads .glb from local file system (offline support)
/// - Applies external animations via animation-src
/// - Configurable camera controls
/// - Error fallback to placeholder
class AvatarViewer3D extends StatefulWidget {
  final AvatarConfig config;
  final double width;
  final double height;
  final bool enableCameraControls;
  final bool autoRotate;
  final String? animationName; // 'idle' or 'talking'

  const AvatarViewer3D({
    super.key,
    required this.config,
    this.width = 200,
    this.height = 200,
    this.enableCameraControls = false,
    this.autoRotate = false,
    this.animationName,
  });

  @override
  State<AvatarViewer3D> createState() => _AvatarViewer3DState();
}

class _AvatarViewer3DState extends State<AvatarViewer3D> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  O3DController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = O3DController();
    _verifyAvatarFile();
  }

  /// Verify avatar file exists before loading
  Future<void> _verifyAvatarFile() async {
    if (widget.config is! AvatarConfigLoaded) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No avatar configured';
        _isLoading = false;
      });
      return;
    }

    final config = widget.config as AvatarConfigLoaded;
    final file = File(config.localPath);

    if (!await file.exists()) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Avatar file not found';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
  }

  /// Get animation asset path based on animation name
  String? _getAnimationPath() {
    // For now, we only have one animation (Standing_Greeting)
    // In the future, you can add logic to select different animations
    if (widget.animationName != null) {
      return 'assets/animations/Standing_Greeting.glb';
    }
    return null;
  }

  @override
  void dispose() {
    // O3DController doesn't have a dispose method
    // The WebView is automatically disposed when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPlaceholder();
    }

    if (_isLoading) {
      return _buildLoadingPlaceholder();
    }

    final config = widget.config as AvatarConfigLoaded;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: O3D(
        controller: _controller,
        // Load from local file using file:// protocol
        src: 'file://${config.localPath}',
        // Apply animation if specified
        animationName: _getAnimationPath(),
        // Camera settings
        autoRotate: widget.autoRotate,
        cameraControls: widget.enableCameraControls,
        // Styling
        backgroundColor: AppColors.background,
        // Performance
        ar: false, // Disable AR for better performance
        autoPlay: true,
      ),
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
