import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/avatar/widgets/avatar_viewer_3d.dart';
import 'package:applicazione_mental_coach/features/avatar/widgets/rpm_avatar_creator.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/design_system/components/glass_drawer.dart';

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
      backgroundColor: AppColors.background,
      drawer: const GlassDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Your Coach Avatar',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
      body: _buildBody(context, ref, avatarState),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3D Avatar Preview
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: AvatarViewer3D(
                config: loadedConfig,
                width: 300,
                height: 400,
                enableCameraControls: true,
                autoRotate: true,
                animationName: 'idle',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Avatar Info
          _buildInfoCard(loadedConfig),
          const SizedBox(height: AppSpacing.lg),

          // Edit Button
          ElevatedButton.icon(
            onPressed: () => _openAvatarCreator(context),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Avatar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

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
              ),
              child: const Icon(
                Icons.psychology,
                size: 60,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Create Your Coach',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Design a personalized 3D avatar for your mental coach',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _openAvatarCreator(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Avatar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
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
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(AvatarConfigLoaded config) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar Details',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Last Updated', _formatDate(config.lastUpdated)),
          if (config.gender != null)
            _buildInfoRow('Gender', config.gender!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
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
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Avatar',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete your coach avatar? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
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