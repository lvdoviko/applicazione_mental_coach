import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

enum IOSChatBubbleType { user, ai }

class IOSChatBubble extends StatelessWidget {
  const IOSChatBubble({
    super.key,
    required this.message,
    required this.type,
    this.timestamp,
    this.isLoading = false,
  });

  final String message;
  final IOSChatBubbleType type;
  final DateTime? timestamp;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isUser = type == IOSChatBubbleType.user;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: AppSpacing.sm),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(),
                    borderRadius: _getBorderRadius(),
                  ),
                  child: isLoading 
                    ? _buildLoadingIndicator()
                    : _buildMessageText(),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _buildTimestamp(),
                ],
              ],
            ),
          ),
          
          if (isUser) const SizedBox(width: AppSpacing.sm),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.warmTerracotta,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: AppColors.white,
        size: 18,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warmGold,
            AppColors.warmOrange,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.white,
        size: 18,
      ),
    );
  }

  Widget _buildMessageText() {
    final isUser = type == IOSChatBubbleType.user;
    
    return Text(
      message,
      style: AppTypography.bodyMedium.copyWith(
        color: isUser ? AppColors.white : AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (index) => 
          Container(
            margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.3, end: 1.0),
              builder: (context, value, child) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 150 * (index + 1)),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.warmTerracotta.withValues(alpha: value),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    final isUser = type == IOSChatBubbleType.user;
    
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 0 : 40,
        right: isUser ? 40 : 0,
      ),
      child: Text(
        _formatTimestamp(),
        style: AppTypography.caption.copyWith(
          color: AppColors.grey500,
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    final isUser = type == IOSChatBubbleType.user;
    return isUser ? AppColors.warmTerracotta : AppColors.grey100;
  }

  BorderRadius _getBorderRadius() {
    final isUser = type == IOSChatBubbleType.user;
    
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 6),
      bottomRight: Radius.circular(isUser ? 6 : 20),
    );
  }

  String _formatTimestamp() {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}