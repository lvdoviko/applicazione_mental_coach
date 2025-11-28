import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';

class MorningBriefingCard extends StatelessWidget {
  final String greeting;
  final String insight;
  final String actionLabel;
  final VoidCallback onActionTap;

  const MorningBriefingCard({
    super.key,
    required this.greeting,
    required this.insight,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTypography.h3.copyWith(
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            insight,
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              height: 1.3,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2979FF), Color(0xFF4FC3F7)], // Electric Blue -> Light Blue
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30), // Pill shape
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2979FF).withOpacity(0.6), // Stronger Blue Glow
                  blurRadius: 20, // Higher blur
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                actionLabel,
                style: AppTypography.buttonLarge.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
