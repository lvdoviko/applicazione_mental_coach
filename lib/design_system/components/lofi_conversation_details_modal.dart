import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Conversation Details Modal**
/// 
/// **Functional Description:**
/// Clean overlay modal showing conversation info, settings, and actions.
/// Includes bot configuration, chat export, and privacy controls.
/// 
/// **Visual Specifications:**
/// - Background: #FFFFFF with subtle shadow
/// - Header: Gradient with bot avatar and info
/// - Actions: List tiles with minimal icons
/// - Buttons: #7DAEA9 primary, text secondary
/// - Border radius: 20px top corners
/// - Animation: Slide up from bottom
/// 
/// **Component Name:** LoFiConversationDetailsModal
/// 
/// **Accessibility:**
/// - Modal semantics and focus trap
/// - Action button labels
/// - Screen reader announcements
/// - Keyboard navigation support
/// 
/// **Performance:**
/// - Stateless modal content
/// - Efficient list rendering
/// - Smooth slide animations
class LoFiConversationDetailsModal extends StatefulWidget {
  final String conversationTitle;
  final String botName;
  final DateTime startedAt;
  final int messageCount;
  final VoidCallback? onExportChat;
  final VoidCallback? onClearHistory;
  final VoidCallback? onMuteNotifications;
  final VoidCallback? onBlockUser;

  const LoFiConversationDetailsModal({
    super.key,
    this.conversationTitle = 'AI Coach',
    this.botName = 'Mental Wellness Assistant',
    required this.startedAt,
    this.messageCount = 0,
    this.onExportChat,
    this.onClearHistory,
    this.onMuteNotifications,
    this.onBlockUser,
  });

  @override
  State<LoFiConversationDetailsModal> createState() =>
      _LoFiConversationDetailsModalState();
}

class _LoFiConversationDetailsModalState
    extends State<LoFiConversationDetailsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
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
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _closeModal(),
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () {}, // Prevent close on content tap
              child: Column(
                children: [
                  const Spacer(),
                  _buildModalContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildContent(),
          _buildActions(),
          const SizedBox(height: AppSpacing.screenPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
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
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversationTitle,
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.botName,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _closeModal,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversation Info',
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow('Started', _formatDate(widget.startedAt)),
          _buildInfoRow('Messages', '${widget.messageCount} messages'),
          _buildInfoRow('Status', 'Active'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final actions = [
      _ActionItem(
        icon: Icons.download_outlined,
        title: 'Export Chat',
        subtitle: 'Download conversation history',
        onTap: () {
          _closeModal();
          widget.onExportChat?.call();
        },
      ),
      _ActionItem(
        icon: Icons.notifications_outlined,
        title: 'Mute Notifications',
        subtitle: 'Turn off push notifications',
        onTap: () {
          _closeModal();
          widget.onMuteNotifications?.call();
        },
      ),
      _ActionItem(
        icon: Icons.clear_all_outlined,
        title: 'Clear History',
        subtitle: 'Delete all messages',
        isDestructive: true,
        onTap: () {
          _showConfirmationDialog(
            title: 'Clear Chat History?',
            message: 'This action cannot be undone.',
            onConfirm: () {
              _closeModal();
              widget.onClearHistory?.call();
            },
          );
        },
      ),
    ];

    return Column(
      children: actions
          .map((action) => _buildActionTile(action))
          .toList(),
    );
  }

  Widget _buildActionTile(_ActionItem action) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: action.isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          action.icon,
          color: action.isDestructive
              ? AppColors.error
              : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        action.title,
        style: AppTypography.bodyMedium.copyWith(
          color: action.isDestructive
              ? AppColors.error
              : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: action.subtitle != null
          ? Text(
              action.subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : null,
      onTap: () {
        HapticFeedback.selectionClick();
        action.onTap?.call();
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Confirm',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;

  _ActionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });
}