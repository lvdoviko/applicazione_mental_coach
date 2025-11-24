import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Performance Message Bubble Component**
/// 
/// **Functional Description:**
/// High-performance message bubbles with citation support (RAG) and distinct styling.
/// 
/// **Visual Specifications:**
/// - User bubble: Deep Indigo
/// - Bot bubble: Dark Surface
/// - Citation: Clickable chip for RAG transparency
enum MessageType { user, bot, system }
enum MessageStatus { sending, sent, delivered, read, error }

class LoFiMessageBubble extends StatefulWidget {
  final String message;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isAnimated;
  final VoidCallback? onRetry;
  final String? citation; // New: RAG Citation

  const LoFiMessageBubble({
    super.key,
    required this.message,
    required this.type,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.isAnimated = false,
    this.onRetry,
    this.citation,
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
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome, // Abstract/AI icon
        color: AppColors.white,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.textSecondary,
        size: 16,
      ),
    );
  }

  Widget _buildBubble() {
    final isUser = widget.type == MessageType.user;
    final backgroundColor = isUser ? AppColors.userBubble : AppColors.botBubble;
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _getBorderRadius(isUser),
        border: isUser ? null : Border.all(color: AppColors.border),
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
          if (widget.citation != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildCitationChip(),
          ],
          if (_shouldShowTimestamp()) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildTimestamp(isUser ? AppColors.textPrimary : AppColors.textSecondary),
          ],
        ],
      ),
    );
  }

  Widget _buildCitationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              widget.citation!,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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