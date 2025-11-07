import 'package:flutter/material.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';

/// Card widget to display individual health metrics with trend indicators
class HealthMetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String trend; // 'improving', 'declining', 'stable'
  final Color color;
  final IconData icon;

  const HealthMetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        break;
      case 'stable':
      default:
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.grey400;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        trendIcon,
        color: trendColor,
        size: 16,
      ),
    );
  }
}