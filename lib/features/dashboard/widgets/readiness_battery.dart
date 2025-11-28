import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

class ReadinessBattery extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final String label;

  const ReadinessBattery({
    super.key,
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70, // Brighter text
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * percentage,
                    decoration: BoxDecoration(
                      gradient: AppColors.readinessBatteryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
              Center(
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
