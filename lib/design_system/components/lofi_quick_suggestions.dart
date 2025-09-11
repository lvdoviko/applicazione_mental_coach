import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Quick Suggestions Widget**
/// 
/// **Functional Description:**
/// Pill-shaped suggestion chips that appear contextually with smooth animations.
/// Supports scrolling and contextual suggestion generation.
/// 
/// **Visual Specifications:**
/// - Pills: #F8F6F5 background, 20px radius
/// - Text: Inter 14px medium, #6B7280 color
/// - Padding: 16px horizontal, 8px vertical
/// - Spacing: 8px between chips
/// - Animation: 200ms appear/disappear with easeOut
/// 
/// **Component Name:** LoFiQuickSuggestions
/// 
/// **Accessibility:**
/// - Chip button semantics
/// - Scroll announcements
/// - Focus management
/// - Action confirmations
/// 
/// **Performance:**
/// - Lazy loading for large lists
/// - Optimized scroll physics
/// - Minimal animation overhead
typedef SuggestionCallback = void Function(String suggestion);

class LoFiQuickSuggestions extends StatefulWidget {
  final List<String> suggestions;
  final SuggestionCallback onSuggestionTap;
  final bool isVisible;
  final EdgeInsets padding;

  const LoFiQuickSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.isVisible = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenPadding,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  State<LoFiQuickSuggestions> createState() => _LoFiQuickSuggestionsState();
}

class _LoFiQuickSuggestionsState extends State<LoFiQuickSuggestions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isVisible && widget.suggestions.isNotEmpty) {
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.small,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void didUpdateWidget(LoFiQuickSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible && widget.suggestions.isNotEmpty) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    
    if (widget.suggestions != oldWidget.suggestions && 
        widget.isVisible && 
        widget.suggestions.isNotEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 44,
          padding: widget.padding,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.suggestions.length,
            separatorBuilder: (context, index) => 
                const SizedBox(width: AppSpacing.chipSpacing),
            itemBuilder: (context, index) {
              final suggestion = widget.suggestions[index];
              return _buildSuggestionChip(suggestion, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onSuggestionTap(suggestion),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chipPaddingHorizontal,
              vertical: AppSpacing.chipPaddingVertical,
            ),
            child: Text(
              suggestion,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSuggestionTap(String suggestion) {
    HapticFeedback.selectionClick();
    widget.onSuggestionTap(suggestion);
  }
}

/// Predefined suggestion sets for different contexts
class QuickSuggestionPresets {
  static const List<String> empathetic = [
    "Tell me more",
    "I understand", 
    "That sounds hard",
    "You're not alone",
  ];

  static const List<String> supportive = [
    "I'm here for you",
    "Let's work through this",
    "You've got this",
    "Take your time",
  ];

  static const List<String> curious = [
    "What happened?",
    "How did it feel?",
    "What's on your mind?",
    "Can you share more?",
  ];

  static const List<String> motivational = [
    "Keep going",
    "I believe in you", 
    "You're strong",
    "Progress matters",
  ];

  static const List<String> general = [
    "Yes",
    "No",
    "Maybe later",
    "I need help",
    "Thank you",
  ];

  /// Get contextual suggestions based on conversation state
  static List<String> getContextualSuggestions(String context) {
    switch (context.toLowerCase()) {
      case 'empathetic':
        return empathetic;
      case 'supportive':
        return supportive;
      case 'curious':
        return curious;
      case 'motivational':
        return motivational;
      default:
        return general;
    }
  }
}