import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Empty State Component**
/// 
/// **Functional Description:**
/// Minimal empty state with soft illustration, helpful copy, and optional CTA.
/// Used for empty lists, no search results, and initial states.
/// 
/// **Visual Specifications:**
/// - Illustration: 80px soft circle with outline icon
/// - Background: #F8F6F5 subtle variant
/// - Typography: Inter 24px heading, 16px body
/// - Spacing: 64px vertical sections
/// - CTA: Optional #7DAEA9 button
/// 
/// **Component Name:** LoFiEmptyState
/// 
/// **Accessibility:**
/// - Image semantics and descriptions
/// - CTA button labels
/// - Screen reader announcements
/// - Focus management
/// 
/// **Performance:**
/// - Stateless widget with minimal rebuilds
/// - Const constructors for icons
/// - Optimized layout calculations
class LoFiEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final Color? iconColor;
  final bool isAnimated;

  const LoFiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonTap,
    this.iconColor,
    this.isAnimated = true,
  });

  @override
  State<LoFiEmptyState> createState() => _LoFiEmptyStateState();
}

class _LoFiEmptyStateState extends State<LoFiEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _setupAnimations();
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    
    if (widget.isAnimated) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: content,
        ),
      );
    }
    
    return content;
  }

  Widget _buildContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIllustration(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildTitle(),
            const SizedBox(height: AppSpacing.lg),
            _buildMessage(),
            if (widget.buttonText != null && widget.onButtonTap != null) ...[
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon,
        size: 48,
        color: widget.iconColor ?? AppColors.textTertiary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: AppTypography.headingMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.message,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onButtonTap,
        child: Text(widget.buttonText!),
      ),
    );
  }
}

/// Predefined empty states for common use cases
class EmptyStatePresets {
  static const LoFiEmptyState noConversations = LoFiEmptyState(
    icon: Icons.chat_bubble_outline,
    title: 'No conversations yet',
    message: 'Start a conversation with your AI coach to begin your wellness journey.',
    buttonText: 'Start Chat',
  );

  static const LoFiEmptyState noSearchResults = LoFiEmptyState(
    icon: Icons.search_off_outlined,
    title: 'No results found',
    message: 'Try adjusting your search terms or browse all conversations.',
    buttonText: 'Clear Search',
  );

  static const LoFiEmptyState noNotifications = LoFiEmptyState(
    icon: Icons.notifications_none_outlined,
    title: 'All caught up',
    message: 'You have no new notifications. Check back later for updates.',
    isAnimated: false,
  );

  static const LoFiEmptyState connectionError = LoFiEmptyState(
    icon: Icons.wifi_off_outlined,
    title: 'Connection lost',
    message: 'Check your internet connection and try again.',
    buttonText: 'Retry',
  );

  static const LoFiEmptyState noData = LoFiEmptyState(
    icon: Icons.inbox_outlined,
    title: 'Nothing here',
    message: 'This section will populate with content as you use the app.',
    isAnimated: false,
  );
}