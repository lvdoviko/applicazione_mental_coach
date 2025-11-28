import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/avatar/widgets/avatar_viewer_3d.dart';
import 'package:applicazione_mental_coach/features/avatar/widgets/rpm_avatar_creator.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/design_system/components/glass_drawer.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';

/// Avatar Screen - Manage 3D Coach Avatar
/// 
/// Features:
/// - View current 3D avatar
/// - Create/Edit avatar via Ready Player Me
/// - Delete avatar
class AvatarScreen extends ConsumerWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const GlassDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Coach Avatar',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        // Leading icon is automatically handled by Scaffold when drawer is present
        actions: [
          if (avatarState is AvatarStateLoaded &&
              avatarState.config is AvatarConfigLoaded)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Avatar',
              onPressed: () => _showDeleteConfirmation(context, ref),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF1C2541), // Deep Blue
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: _buildBody(context, ref, avatarState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AvatarState state) {
    return switch (state) {
      AvatarStateLoading() => _buildLoadingState(),
      AvatarStateLoaded(:final config) => _buildLoadedState(context, ref, config),
      AvatarStateError(:final failure) => _buildErrorState(context, ref, failure.message),
      AvatarStateDownloading(:final progress) => _buildDownloadingState(progress),
    };
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, WidgetRef ref, AvatarConfig config) {
    if (config is AvatarConfigEmpty) {
      return _buildEmptyState(context);
    }

    final loadedConfig = config as AvatarConfigLoaded;

    return Stack(
      children: [
        // 1. Full Screen Avatar Viewer
        Positioned.fill(
          child: AvatarViewer3D(
            config: loadedConfig,
            enableCameraControls: true,
            autoRotate: true,
            animationName: 'idle',
          ),
        ),

        // 2. Floating Info Badge (HUD Style)
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 20,
          child: _buildInfoBadge(loadedConfig),
        ),

        // 3. Floating Action Button (Pill)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: _buildEditButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(AvatarConfigLoaded config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, color: Colors.white.withOpacity(0.7), size: 14),
              const SizedBox(width: 6),
              Text(
                'Updated: ${_formatDate(config.lastUpdated)}',
                style: GoogleFonts.nunito(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2979FF).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _openAvatarCreator(context),
        icon: const Icon(Icons.checkroom, color: Colors.white),
        label: Text(
          'Customize Look',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          // Gradient background workaround for ElevatedButton
          backgroundBuilder: (context, states, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF4FC3F7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }

  // Workaround since backgroundBuilder is not standard in all Flutter versions yet
  // We'll wrap the button in a Container with gradient and make button transparent
  // Actually, let's use the Container wrapping approach which is safer.

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Create Your Coach',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Design a personalized 3D avatar for your mental coach',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF4FC3F7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2979FF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openAvatarCreator(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Create Avatar',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String message) {
    return Center(
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
              style: AppTypography.h2.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => ref.read(avatarProvider.notifier).reload(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadingState(double progress) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Downloading avatar...',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.caption.copyWith(
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openAvatarCreator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RpmAvatarCreator(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text(
          'Delete Avatar',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete your coach avatar? This action cannot be undone.',
          style: GoogleFonts.nunito(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(avatarProvider.notifier).deleteAvatar();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}