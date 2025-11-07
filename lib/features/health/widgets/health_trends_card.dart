import 'package:flutter/material.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../models/wearable_snapshot.dart';

/// Card widget to display health trends over time with simple visualizations
class HealthTrendsCard extends StatelessWidget {
  final List<WearableSnapshot> snapshots;

  const HealthTrendsCard({
    super.key,
    required this.snapshots,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshots.length < 3) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            const Icon(Icons.timeline, size: 48, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dati insufficienti per le tendenze',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            Text(
              'Servono almeno 3 giorni di dati',
              style: AppTypography.caption.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.warmTerracotta),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Tendenze Recenti',
                style: AppTypography.h4,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildTrendItem(
            'Qualità del Sonno',
            _calculateSleepTrend(),
            _getSleepTrendDescription(),
            Icons.bedtime,
            AppColors.warmGold,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTrendItem(
            'Variabilità Cardiaca',
            _calculateHRVTrend(),
            _getHRVTrendDescription(),
            Icons.monitor_heart,
            AppColors.warmTerracotta,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTrendItem(
            'Livello di Stress',
            _calculateStressTrend(),
            _getStressTrendDescription(),
            Icons.psychology,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    String title,
    String trend,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildTrendIndicator(trend),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(String trend) {
    IconData icon;
    Color color;
    String text;

    switch (trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = Colors.green;
        text = 'In miglioramento';
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = Colors.red;
        text = 'In peggioramento';
        break;
      case 'stable':
      default:
        icon = Icons.trending_flat;
        color = AppColors.grey400;
        text = 'Stabile';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Trend calculation methods

  String _calculateSleepTrend() {
    final recent = snapshots.take(3).toList();
    final older = snapshots.skip(3).take(3).toList();
    
    if (older.isEmpty) return 'stable';
    
    final recentAvg = recent
        .map((s) => s.sleep.avgHours)
        .reduce((a, b) => a + b) / recent.length;
    
    final olderAvg = older
        .map((s) => s.sleep.avgHours)
        .reduce((a, b) => a + b) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }

  String _calculateHRVTrend() {
    final recent = snapshots.take(3).toList();
    final older = snapshots.skip(3).take(3).toList();
    
    if (older.isEmpty) return 'stable';
    
    final recentAvg = recent
        .map((s) => s.physio.hrvDeltaPct)
        .reduce((a, b) => a + b) / recent.length;
    
    final olderAvg = older
        .map((s) => s.physio.hrvDeltaPct)
        .reduce((a, b) => a + b) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    if (difference > 5) return 'improving';
    if (difference < -5) return 'declining';
    return 'stable';
  }

  String _calculateStressTrend() {
    final recent = snapshots.take(3).toList();
    final older = snapshots.skip(3).take(3).toList();
    
    if (older.isEmpty) return 'stable';
    
    final recentAvg = recent
        .map((s) => s.physio.getStressScore())
        .reduce((a, b) => a + b) / recent.length;
    
    final olderAvg = older
        .map((s) => s.physio.getStressScore())
        .reduce((a, b) => a + b) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    // For stress, lower is better
    if (difference < -1) return 'improving';
    if (difference > 1) return 'declining';
    return 'stable';
  }

  String _getSleepTrendDescription() {
    final trend = _calculateSleepTrend();
    final recent = snapshots.take(3).toList();
    final avgHours = recent
        .map((s) => s.sleep.avgHours)
        .reduce((a, b) => a + b) / recent.length;
    
    switch (trend) {
      case 'improving':
        return 'Stai dormendo di più negli ultimi giorni (${avgHours.toStringAsFixed(1)}h media)';
      case 'declining':
        return 'Il sonno è diminuito recentemente (${avgHours.toStringAsFixed(1)}h media)';
      case 'stable':
      default:
        return 'Durata del sonno costante (${avgHours.toStringAsFixed(1)}h media)';
    }
  }

  String _getHRVTrendDescription() {
    final trend = _calculateHRVTrend();
    final recent = snapshots.take(3).toList();
    final avgDelta = recent
        .map((s) => s.physio.hrvDeltaPct)
        .reduce((a, b) => a + b) / recent.length;
    
    switch (trend) {
      case 'improving':
        return 'HRV in aumento, recupero migliorato (+${avgDelta.toStringAsFixed(1)}%)';
      case 'declining':
        return 'HRV in calo, possibile stress (${avgDelta.toStringAsFixed(1)}%)';
      case 'stable':
      default:
        return 'HRV stabile negli ultimi giorni (${avgDelta.toStringAsFixed(1)}%)';
    }
  }

  String _getStressTrendDescription() {
    final trend = _calculateStressTrend();
    final recent = snapshots.take(3).toList();
    final avgStress = recent
        .map((s) => s.physio.getStressScore())
        .reduce((a, b) => a + b) / recent.length;
    
    switch (trend) {
      case 'improving':
        return 'Stress in diminuzione, situazione migliorata (${avgStress.toStringAsFixed(1)}/10)';
      case 'declining':
        return 'Stress in aumento, servono strategie di gestione (${avgStress.toStringAsFixed(1)}/10)';
      case 'stable':
      default:
        return 'Livello di stress costante (${avgStress.toStringAsFixed(1)}/10)';
    }
  }
}