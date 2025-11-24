import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

class DailyPulse extends StatefulWidget {
  final ValueChanged<double> onMoodChanged;

  const DailyPulse({super.key, required this.onMoodChanged});

  @override
  State<DailyPulse> createState() => _DailyPulseState();
}

class _DailyPulseState extends State<DailyPulse> {
  double _currentValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Pulse',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('😔', style: TextStyle(fontSize: 24)),
              Text('😐', style: TextStyle(fontSize: 24)),
              Text('⚡️', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.white,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _currentValue,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onMoodChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
