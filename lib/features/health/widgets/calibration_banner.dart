import 'package:flutter/material.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';

/// Banner widget to prompt user to start calibration mode
class CalibrationBanner extends StatelessWidget {
  final VoidCallback onStartCalibration;
  final VoidCallback? onDismiss;

  const CalibrationBanner({
    super.key,
    required this.onStartCalibration,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmGold.withValues(alpha: 0.1),
            AppColors.warmOrange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warmGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warmGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.warmGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modalità Calibrazione',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Raccomandato per i primi 7-14 giorni',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.grey500,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Per fornirti consigli più accurati, attiva la modalità calibrazione. Ti chiederemo di inserire brevi auto-valutazioni giornaliere per tarare i nostri algoritmi sui tuoi pattern personali.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onStartCalibration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Avvia Calibrazione',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () => _showCalibrationInfo(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(
                  'Scopri di più',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.warmGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCalibrationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warmGold),
            SizedBox(width: AppSpacing.sm),
            Text('Modalità Calibrazione'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'La modalità calibrazione ti aiuta a ottenere consigli più personalizzati dal tuo AI Coach.',
                style: AppTypography.bodyMedium.copyWith(height: 1.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Come funziona:',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildInfoPoint('📝', 'Ti chiediamo 2-3 auto-valutazioni al giorno'),
              _buildInfoPoint('📊', 'Analizziamo i tuoi pattern personali'),
              _buildInfoPoint('🎯', 'Tariamo le soglie di alert sui tuoi dati'),
              _buildInfoPoint('🤖', 'L\'AI impara il tuo stile di vita'),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Durata consigliata: 7-14 giorni per risultati ottimali.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.grey600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}