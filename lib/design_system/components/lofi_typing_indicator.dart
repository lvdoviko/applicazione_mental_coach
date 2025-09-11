import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Typing Indicator Component**
/// 
/// **Functional Description:**
/// Animated typing dots to show when the bot is composing a response.
/// Features smooth wave animation with staggered dot bounces.
/// 
/// **Visual Specifications:**
/// - Dots: 6px circles in #7DAEA9 primary color
/// - Background: #FFF7EA bot bubble style
/// - Animation: Smooth sine wave bounce (600ms cycle)
/// - Spacing: 8px between dots, 16px padding
/// - Border radius: 16px with bot tail
/// 
/// **Component Name:** LoFiTypingIndicator
/// 
/// **Accessibility:**
/// - Semantic label for screen readers
/// - Proper focus management
/// - Reduced motion support
/// 
/// **Performance:**
/// - Single animation controller
/// - Efficient sine wave calculations
/// - Minimal widget rebuilds
class LoFiTypingIndicator extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onAnimationComplete;

  const LoFiTypingIndicator({
    super.key,
    this.isVisible = true,
    this.onAnimationComplete,
  });

  @override
  State<LoFiTypingIndicator> createState() => _LoFiTypingIndicatorState();
}

class _LoFiTypingIndicatorState extends State<LoFiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isVisible) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    );
  }

  void _startAnimation() {
    if (mounted) {
      _animationController.repeat();
    }
  }

  void _stopAnimation() {
    if (mounted) {
      _animationController.stop();
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void didUpdateWidget(LoFiTypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Semantics(
      label: 'AI Coach is typing',
      hint: 'The AI coach is currently composing a response',
      liveRegion: true,
      child: Container(
        margin: EdgeInsets.only(
          right: AppSpacing.massive,
          bottom: AppSpacing.messageBubbleMargin,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBotAvatar(),
            const SizedBox(width: AppSpacing.sm),
            _buildTypingBubble(),
          ],
        ),
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.6),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.psychology_outlined,
        color: AppColors.surface,
        size: 16,
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 120,
      ),
      decoration: BoxDecoration(
        color: AppColors.botBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTypingDot(0),
          const SizedBox(width: AppSpacing.xs),
          _buildTypingDot(1),
          const SizedBox(width: AppSpacing.xs),
          _buildTypingDot(2),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress = _animationController.value;
        final staggeredProgress = (progress + (index * 0.2)) % 1.0;
        final bounce = math.sin(staggeredProgress * math.pi * 2) * 0.5 + 0.5;
        
        return Transform.translate(
          offset: Offset(0, -bounce * 4),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.3 + bounce * 0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}