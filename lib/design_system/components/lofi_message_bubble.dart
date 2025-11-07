import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Message Bubble Component**
/// 
/// **Functional Description:**
/// Soft, rounded message bubbles with distinct styling for user/bot messages.
/// Includes smooth fade-in animations and proper spacing.
/// 
/// **Visual Specifications:**
/// - User bubble: #DCEEF9 background, #0F1724 text
/// - Bot bubble: #FFF7EA background, #0F1724 text  
/// - Border radius: 16px with tail variations
/// - Padding: 16px horizontal, 12px vertical
/// - Typography: Inter 16px regular, 1.4 line-height
/// - Shadow: Subtle 0.06 opacity for depth
/// 
/// **Component Name:** LoFiMessageBubble
/// 
/// **Accessibility:**
/// - Semantic labels for message type
/// - High contrast text (4.5:1 ratio)
/// - VoiceOver message grouping
/// - Timestamp announcements
/// 
/// **Performance:**
/// - Stateless widget with const constructors
/// - Minimal rebuild scope
/// - Optimized animation controllers
enum MessageType { user, bot, system }
enum MessageStatus { sending, sent, delivered, read, error }

class LoFiMessageBubble extends StatefulWidget {
  final String message;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isAnimated;
  final VoidCallback? onRetry;

  const LoFiMessageBubble({
    super.key,
    required this.message,
    required this.type,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.isAnimated = false,
    this.onRetry,
  });

  @override
  State<LoFiMessageBubble> createState() => _LoFiMessageBubbleState();
}

class _LoFiMessageBubbleState extends State<LoFiMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statusAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _statusFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isAnimated) {
      _startAnimation();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _statusAnimationController = AnimationController(
      duration: AppAnimations.small,
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _statusFadeAnimation = CurvedAnimation(
      parent: _statusAnimationController,
      curve: AppAnimations.easeOut,
    );
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
        if (widget.status == MessageStatus.sending) {
          _statusAnimationController.repeat();
        } else {
          _statusAnimationController.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(LoFiMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _statusAnimationController.reset();
      if (widget.status == MessageStatus.sending) {
        _statusAnimationController.repeat();
      } else {
        _statusAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnimated) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildBubbleContent(),
          ),
        ),
      );
    }
    return _buildBubbleContent();
  }

  Widget _buildBubbleContent() {
    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      liveRegion: widget.type == MessageType.bot,
      child: Container(
        margin: EdgeInsets.only(
          left: widget.type == MessageType.user ? AppSpacing.massive : 0,
          right: widget.type == MessageType.bot ? AppSpacing.massive : 0,
          bottom: AppSpacing.messageBubbleMargin,
        ),
        child: Row(
          mainAxisAlignment: widget.type == MessageType.user
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.type == MessageType.bot) ...[
              _buildBotAvatar(),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: _buildBubble(),
            ),
            if (widget.type == MessageType.user) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildUserAvatar(),
              const SizedBox(width: AppSpacing.sm),
              _buildStatusIndicator(),
            ],
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

  Widget _buildUserAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warmTerracotta.withOpacity(0.8),
            AppColors.warmGold.withOpacity(0.6),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.surface,
        size: 16,
      ),
    );
  }

  Widget _buildBubble() {
    final isUser = widget.type == MessageType.user;
    final backgroundColor = isUser ? AppColors.userBubble : AppColors.botBubble;
    final textColor = isUser ? AppColors.userBubbleText : AppColors.botBubbleText;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _getBorderRadius(isUser),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.messageBubblePadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: isUser
                ? AppTypography.chatBubbleUser
                : AppTypography.chatBubbleBot,
          ),
          if (_shouldShowTimestamp()) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildTimestamp(textColor),
          ],
        ],
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isUser) {
    const radius = 16.0;
    const tailRadius = 4.0;
    
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(tailRadius),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(tailRadius),
        bottomRight: Radius.circular(radius),
      );
    }
  }

  Widget _buildTimestamp(Color textColor) {
    return Text(
      _formatTimestamp(widget.timestamp),
      style: AppTypography.chatTimestamp.copyWith(
        color: textColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.type != MessageType.user) return const SizedBox.shrink();
    
    IconData icon;
    Color color;
    
    switch (widget.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = AppColors.textTertiary;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = AppColors.textTertiary;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = AppColors.textSecondary;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.primary;
        break;
      case MessageStatus.error:
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
    }

    Widget statusWidget = Semantics(
      label: _getStatusDescription(),
      hint: widget.status == MessageStatus.error && widget.onRetry != null 
          ? 'Double tap to retry sending message' 
          : null,
      button: widget.status == MessageStatus.error && widget.onRetry != null,
      child: FadeTransition(
        opacity: _statusFadeAnimation,
        child: widget.status == MessageStatus.sending 
            ? _buildPulsingIcon(icon, color)
            : Icon(
                icon,
                size: 16,
                color: color,
              ),
      ),
    );

    if (widget.status == MessageStatus.error && widget.onRetry != null) {
      return GestureDetector(
        onTap: widget.onRetry,
        child: statusWidget,
      );
    }

    return ExcludeSemantics(
      child: statusWidget,
    );
  }

  Widget _buildPulsingIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _statusAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + 0.6 * (0.5 + 0.5 * math.sin(_statusAnimationController.value * math.pi * 2)),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        );
      },
    );
  }

  bool _shouldShowTimestamp() {
    // Show timestamp for system messages or if needed for context
    return widget.type == MessageType.system;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _getSemanticLabel() {
    final sender = widget.type == MessageType.user ? 'You' : 'AI Coach';
    final time = _formatTimestamp(widget.timestamp);
    final status = _getStatusDescription();
    
    return '$sender said: ${widget.message}. Sent $time. $status';
  }

  String _getSemanticHint() {
    switch (widget.type) {
      case MessageType.user:
        return 'Your message';
      case MessageType.bot:
        return 'AI Coach response';
      case MessageType.system:
        return 'System message';
    }
  }

  String _getStatusDescription() {
    if (widget.type != MessageType.user) return '';
    
    switch (widget.status) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.error:
        return 'Failed to send. Double tap to retry.';
    }
  }
}