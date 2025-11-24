import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

class QuickReplyChips extends StatelessWidget {
  const QuickReplyChips({
    super.key,
    required this.replies,
    required this.onReplySelected,
    this.isVisible = true,
    this.maxDisplayed = 3,
  });

  final List<String> replies;
  final Function(String reply) onReplySelected;
  final bool isVisible;
  final int maxDisplayed;

  @override
  Widget build(BuildContext context) {
    if (!isVisible || replies.isEmpty) return const SizedBox.shrink();

    final displayReplies = replies.take(maxDisplayed).toList();

    return Semantics(
      label: 'Quick reply suggestions',
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Wrap(
            spacing: AppSpacing.quickReplySpacing,
            runSpacing: AppSpacing.quickReplySpacing,
            children: displayReplies
                .asMap()
                .entries
                .map((entry) => _buildChip(
                      entry.value,
                      entry.key,
                      context,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String reply, int index, BuildContext context) {
    // Performance Dark Mode styling
    final backgroundColor = AppColors.surfaceVariant;
    final borderColor = AppColors.primary.withOpacity(0.3);
    final textColor = AppColors.textPrimary;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ActionChip(
        label: Text(
          reply,
          style: AppTypography.caption.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        onPressed: () => onReplySelected(reply),
        pressElevation: 4,
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.2),
      ),
    );
  }
}

// Predefined quick replies for different contexts
class QuickReplyPresets {
  static const List<String> empathetic = [
    "Tell me more",
    "I understand",
    "How can I help?",
  ];

  static const List<String> motivational = [
    "I'm ready to try",
    "What's the first step?", 
    "Let's do this",
  ];

  static const List<String> reflective = [
    "I need to think about this",
    "That makes sense",
    "Can you explain more?",
  ];

  static const List<String> supportive = [
    "I'm feeling overwhelmed",
    "I need encouragement",
    "Talk to a human coach",
  ];

  static const List<String> wellness = [
    "Check my progress",
    "Set a goal",
    "Review my data",
  ];

  static const List<String> onboarding = [
    "I'm an athlete",
    "I'm part of a team",
    "I'm a coach",
  ];

  // A/B test hook: different response styles
  static List<String> getContextualReplies(String context, {String variant = 'A'}) {
    switch (context.toLowerCase()) {
      case 'empathetic':
        return variant == 'A' ? empathetic : [
          "Please continue",
          "I hear you", 
          "What would help?",
        ];
      case 'motivational':
        return variant == 'A' ? motivational : [
          "I'm motivated",
          "Show me how",
          "I'm committed",
        ];
      case 'supportive':
        return variant == 'A' ? supportive : [
          "I'm struggling",
          "I need support",
          "Connect me with help",
        ];
      default:
        return empathetic;
    }
  }
}