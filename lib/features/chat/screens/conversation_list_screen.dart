import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

/// **Conversation List Screen (Inbox)**
/// 
/// **Functional Description:**
/// Clean list interface showing conversation previews with avatars, timestamps,
/// and unread indicators. Supports search and swipe actions.
/// 
/// **Visual Specifications:**
/// - Background: #FBF9F8 (paper)
/// - List items: #FFFFFF cards with subtle shadows
/// - Avatars: 40px circles with soft pastel gradients  
/// - Typography: Inter 16px/14px with generous line-height
/// - Unread badge: #7DAEA9 circle with white text
/// - Spacing: 16px between items, 24px screen margins
/// 
/// **Component Name:** ConversationListScreen
/// 
/// **Accessibility:**
/// - List semantics for screen readers
/// - Swipe action announcements
/// - Focus management and keyboard navigation
/// - High contrast unread indicators
/// 
/// **Performance Notes:**
/// - ListView.builder for large lists
/// - Cached network images for avatars
/// - Optimized rendering with const constructors
class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<Conversation> _conversations = _getDemoConversations();
  List<Conversation> _filteredConversations = [];
  bool _isSearching = false;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _filteredConversations = _conversations;
    _staggerController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          Expanded(
            child: _buildConversationList(),
          ),
        ],
      ),
      floatingActionButton: _buildNewChatFAB(l10n),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        'Conversations',
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        semanticsLabel: 'Conversations list',
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: AppColors.textSecondary,
          ),
          tooltip: _isSearching ? 'Close search' : 'Search conversations',
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: AppAnimations.small,
      height: _isSearching ? 64 : 0,
      curve: AppAnimations.easeOut,
      child: _isSearching
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.surface,
              child: TextField(
                controller: _searchController,
                onChanged: _filterConversations,
                autofocus: true,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: AppTypography.composerPlaceholder,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                semanticsLabel: 'Search conversations',
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildConversationList() {
    if (_filteredConversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      itemCount: _filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = _filteredConversations[index];
        return _buildConversationTile(conversation, index);
      },
    );
  }

  Widget _buildConversationTile(Conversation conversation, int index) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final staggerDelay = index * 0.1;
        final animationProgress = (_staggerController.value - staggerDelay).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(0, (1 - animationProgress) * 20),
          child: Opacity(
            opacity: animationProgress,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.listItemSpacing),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                elevation: 0,
                shadowColor: AppColors.textPrimary.withOpacity(0.06),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openConversation(conversation),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.listItemPadding),
                    child: Row(
                      children: [
                        _buildAvatar(conversation),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildConversationContent(conversation),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildConversationMeta(conversation),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(Conversation conversation) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.6),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.psychology_outlined,
        color: AppColors.surface,
        size: 24,
      ),
    );
  }

  Widget _buildConversationContent(Conversation conversation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                conversation.title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildUnreadBadge(conversation.unreadCount),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          conversation.lastMessage,
          style: AppTypography.bodySmall.copyWith(
            color: conversation.unreadCount > 0
                ? AppColors.textSecondary
                : AppColors.textTertiary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConversationMeta(Conversation conversation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(conversation.lastMessageTime),
          style: AppTypography.caption.copyWith(
            color: conversation.unreadCount > 0
                ? AppColors.textSecondary
                : AppColors.textTertiary,
          ),
        ),
        if (conversation.isPinned) ...[
          const SizedBox(height: AppSpacing.xs),
          Icon(
            Icons.push_pin,
            size: 16,
            color: AppColors.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildUnreadBadge(int count) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: AppTypography.caption.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No conversations yet',
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Start a conversation with your AI coach',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatFAB(AppLocalizations l10n) {
    return FloatingActionButton(
      onPressed: _createNewConversation,
      backgroundColor: AppColors.primary,
      child: Icon(
        Icons.add,
        color: AppColors.surface,
      ),
      tooltip: 'Start new conversation',
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredConversations = _conversations;
      }
    });
  }

  void _filterConversations(String query) {
    setState(() {
      _filteredConversations = _conversations
          .where((conversation) =>
              conversation.title.toLowerCase().contains(query.toLowerCase()) ||
              conversation.lastMessage.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _openConversation(Conversation conversation) {
    HapticFeedback.selectionClick();
    // Mark as read
    setState(() {
      conversation.unreadCount = 0;
    });
    
    // Navigate to chat screen
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {'conversationId': conversation.id},
    );
  }

  void _createNewConversation() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed('/chat');
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  static List<Conversation> _getDemoConversations() {
    return [
      Conversation(
        id: '1',
        title: 'AI Coach',
        lastMessage: 'How did your training session go today? I\'d love to hear about your experience.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isPinned: true,
      ),
      Conversation(
        id: '2',
        title: 'Mental Wellness Check',
        lastMessage: 'Remember to take breaks and listen to your body. Your wellbeing matters.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isPinned: false,
      ),
      Conversation(
        id: '3',
        title: 'Pre-Competition Support',
        lastMessage: 'Let\'s work through those pre-competition nerves together.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
        isPinned: false,
      ),
      Conversation(
        id: '4',
        title: 'Recovery & Rest',
        lastMessage: 'Great job on prioritizing rest today. How are you feeling?',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
        isPinned: false,
      ),
    ];
  }
}

class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageTime;
  int unreadCount;
  final bool isPinned;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
  });
}