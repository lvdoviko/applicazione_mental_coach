import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/components/chat_bubble.dart';
import 'package:applicazione_mental_coach/design_system/components/message_composer.dart';
import 'package:applicazione_mental_coach/design_system/components/quick_reply_chips.dart';
import 'package:applicazione_mental_coach/design_system/components/escalation_modal.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeDummyMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeDummyMessages() {
    // Dummy conversation for demonstration
    _messages.addAll([
      ChatMessage(
        id: '1',
        content: 'Hello! I\'m your AI Wellbeing Coach. I\'m here to support you on your mental wellness journey. How are you feeling today?',
        type: ChatBubbleType.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        id: '2',
        content: 'Hi! I\'ve been feeling a bit overwhelmed with training lately.',
        type: ChatBubbleType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        status: ChatBubbleStatus.read,
      ),
      ChatMessage(
        id: '3',
        content: 'I understand that training can feel overwhelming sometimes. It\'s completely normal to feel this way, especially when you\'re pushing yourself to improve. Can you tell me more about what specifically feels overwhelming?',
        type: ChatBubbleType.ai,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildQuickReplies(),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.softBlue, AppColors.deepTeal],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Coach',
                style: AppTypography.h4,
              ),
              Text(
                'Online • Always here for you',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showEscalationModal,
          icon: const Icon(Icons.support_agent),
          tooltip: 'Talk to human coach',
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement chat options menu
          },
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return ChatBubble(
          message: message.content,
          type: message.type,
          timestamp: message.timestamp,
          status: message.status,
          isAnimated: index == _messages.length - 1,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(
        right: AppSpacing.huge,
        bottom: AppSpacing.chatBubbleMargin,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chatBubblePadding,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: _buildAnimatedDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (0.5 * value),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.grey400.withOpacity(value),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = _getContextualQuickReplies();
    
    return QuickReplyChips(
      replies: quickReplies,
      onReplySelected: _sendMessage,
      isVisible: quickReplies.isNotEmpty,
    );
  }

  List<String> _getContextualQuickReplies() {
    if (_messages.isEmpty) return [];
    
    final lastMessage = _messages.last;
    if (lastMessage.type == ChatBubbleType.user) return [];
    
    // Context-based replies based on AI's last message
    if (lastMessage.content.contains('overwhelming')) {
      return QuickReplyPresets.getContextualReplies('supportive');
    } else if (lastMessage.content.contains('feeling')) {
      return QuickReplyPresets.getContextualReplies('empathetic');
    }
    
    return QuickReplyPresets.empathetic;
  }

  Widget _buildMessageComposer() {
    return MessageComposer(
      onSendMessage: _sendMessage,
      hintText: 'Share what\'s on your mind...',
      onVoiceStart: () {
        // TODO: Implement voice recording start
      },
      onVoiceStop: () {
        // TODO: Implement voice recording stop
      },
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      type: ChatBubbleType.user,
      timestamp: DateTime.now(),
      status: ChatBubbleStatus.sending,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Simulate message delivery
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) {
          _messages[index] = userMessage.copyWith(status: ChatBubbleStatus.delivered);
        }
      });
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      _simulateAIResponse(message);
    });
  }

  void _simulateAIResponse(String userMessage) {
    final aiResponse = _generateContextualResponse(userMessage);
    
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: aiResponse,
      type: ChatBubbleType.ai,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isTyping = false;
      _messages.add(aiMessage);
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  String _generateContextualResponse(String userMessage) {
    // Simple contextual response generation (placeholder for AI integration)
    final message = userMessage.toLowerCase();
    
    if (message.contains('stress') || message.contains('anxious')) {
      return 'It sounds like you\'re dealing with stress. That\'s completely understandable. Let\'s explore some techniques that might help you feel more grounded. Have you tried any breathing exercises recently?';
    } else if (message.contains('tired') || message.contains('fatigue')) {
      return 'Feeling tired can really impact your performance and wellbeing. Rest is just as important as training. How has your sleep been lately? Are you getting enough recovery time?';
    } else if (message.contains('motivation') || message.contains('unmotivated')) {
      return 'It\'s natural for motivation to fluctuate - even elite athletes experience this. What usually helps you reconnect with your passion for your sport?';
    } else if (message.contains('pressure')) {
      return 'Pressure can be challenging to navigate. Remember, it\'s often a sign that you care deeply about your performance. Let\'s talk about ways to channel that energy positively.';
    }
    
    return 'Thank you for sharing that with me. I\'m here to listen and support you. Can you tell me more about how this is affecting you?';
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showEscalationModal() {
    showDialog(
      context: context,
      builder: (context) => EscalationModal(
        onSubmit: _handleEscalationRequest,
        chatContext: {
          'messages_count': _messages.length,
          'last_message': _messages.isNotEmpty ? _messages.last.content : '',
          'session_duration': DateTime.now().difference(
            _messages.isNotEmpty 
                ? _messages.first.timestamp 
                : DateTime.now(),
          ).inMinutes,
        },
      ),
    );
  }

  Future<void> _handleEscalationRequest(EscalationRequest request) async {
    // TODO: Implement actual escalation API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Add system message about escalation
    final escalationMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'I\'ve submitted your request for human support. A qualified coach will contact you within 24 hours. In the meantime, I\'m still here if you need immediate support.',
      type: ChatBubbleType.ai,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(escalationMessage);
    });
  }
}

class ChatMessage {
  final String id;
  final String content;
  final ChatBubbleType type;
  final DateTime timestamp;
  final ChatBubbleStatus status;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = ChatBubbleStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    ChatBubbleType? type,
    DateTime? timestamp,
    ChatBubbleStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}