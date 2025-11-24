import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

enum ChatBubbleType { user, ai }

enum ChatBubbleStatus { sending, sent, delivered, read, error }

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.type,
    this.timestamp,
    this.status = ChatBubbleStatus.sent,
    this.showAvatar = true,
    this.onRetry,
    this.isAnimated = false,
  });

  final String message;
  final ChatBubbleType type;
  final DateTime? timestamp;
  final ChatBubbleStatus status;
  final bool showAvatar;
  final VoidCallback? onRetry;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final isUser = type == ChatBubbleType.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: isUser ? 'Your message' : 'AI coach message',
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? AppSpacing.huge : 0,
          right: isUser ? 0 : AppSpacing.huge,
          bottom: AppSpacing.chatBubbleMargin,
        ),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser && showAvatar) _buildAvatar(),
            if (!isUser && showAvatar) const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildBubble(isDarkMode),
                  if (timestamp != null || status != ChatBubbleStatus.sent)
                    const SizedBox(height: AppSpacing.xs),
                  if (timestamp != null || status != ChatBubbleStatus.sent)
                    _buildMetadata(),
                ],
              ),
            ),
            if (isUser && showAvatar) const SizedBox(width: AppSpacing.sm),
            if (isUser && showAvatar) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: type == ChatBubbleType.user
            ? AppColors.warmTerracotta
            : AppColors.warmGold,
        shape: BoxShape.circle,
      ),
      child: Icon(
        type == ChatBubbleType.user ? Icons.person : Icons.psychology,
        color: AppColors.white,
        size: 18,
      ),
    );
  }

  Widget _buildBubble(bool isDarkMode) {
    Color bubbleColor;
    Color textColor;

    if (type == ChatBubbleType.user) {
      bubbleColor = AppColors.userBubble;
      textColor = AppColors.userBubbleText;
    } else {
      bubbleColor = isDarkMode ? AppColors.grey700 : AppColors.aiBubble;
      textColor = isDarkMode 
          ? AppColors.textPrimary 
          : AppColors.aiBubbleText;
    }

    Widget bubbleContent = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.chatBubblePadding,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(type == ChatBubbleType.user ? 16 : 4),
          bottomRight: Radius.circular(type == ChatBubbleType.user ? 4 : 16),
        ),
      ),
      child: Text(
        message,
        style: type == ChatBubbleType.user
            ? AppTypography.chatBubbleUser
            : AppTypography.chatBubbleAI.copyWith(color: textColor),
      ),
    );

    if (isAnimated && type == ChatBubbleType.ai) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
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
        child: bubbleContent,
      );
    }

    return bubbleContent;
  }

  Widget _buildMetadata() {
    return Padding(
      padding: EdgeInsets.only(
        left: type == ChatBubbleType.user ? 0 : AppSpacing.sm,
        right: type == ChatBubbleType.user ? AppSpacing.sm : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timestamp != null) ...[
            Text(
              _formatTimestamp(timestamp!),
              style: AppTypography.chatTimestamp,
            ),
            if (status != ChatBubbleStatus.sent)
              const SizedBox(width: AppSpacing.xs),
          ],
          if (status != ChatBubbleStatus.sent) _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case ChatBubbleStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.grey400),
          ),
        );
      case ChatBubbleStatus.error:
        return GestureDetector(
          onTap: onRetry,
          child: const Icon(
            Icons.error_outline,
            size: 12,
            color: AppColors.error,
          ),
        );
      case ChatBubbleStatus.delivered:
        return const Icon(
          Icons.done,
          size: 12,
          color: AppColors.grey400,
        );
      case ChatBubbleStatus.read:
        return const Icon(
          Icons.done_all,
          size: 12,
          color: AppColors.success,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}