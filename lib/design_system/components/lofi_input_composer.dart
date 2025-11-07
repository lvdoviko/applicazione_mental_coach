import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Input Composer Component**
/// 
/// **Functional Description:**
/// Clean message input interface with voice recording, attachment support,
/// and smooth send animations. Persistent bottom positioning.
/// 
/// **Visual Specifications:**
/// - Background: #FFFFFF surface
/// - Input field: #F8F6F5 with 12px radius
/// - Send button: #7DAEA9 with scale animation
/// - Voice button: Breathing animation when recording
/// - Typography: Inter 16px placeholders
/// - Padding: 16px all around
/// 
/// **Component Name:** LoFiInputComposer
/// 
/// **Accessibility:**
/// - Voice input announcements
/// - Send button semantic labels  
/// - Focus management for keyboard
/// - Haptic feedback for actions
/// 
/// **Performance:**
/// - Debounced input processing
/// - Optimized animation controllers
/// - Minimal rebuilds on text changes
typedef MessageCallback = void Function(String message);
typedef VoidCallback = void Function();

class LoFiInputComposer extends StatefulWidget {
  final MessageCallback onSendMessage;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceStop;
  final VoidCallback? onAttachmentTap;
  final String hintText;
  final bool isEnabled;
  final bool isRecording;

  const LoFiInputComposer({
    super.key,
    required this.onSendMessage,
    this.onVoiceStart,
    this.onVoiceStop,
    this.onAttachmentTap,
    this.hintText = 'Type a message...',
    this.isEnabled = true,
    this.isRecording = false,
  });

  @override
  State<LoFiInputComposer> createState() => _LoFiInputComposerState();
}

class _LoFiInputComposerState extends State<LoFiInputComposer>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _pulseController;
  late AnimationController _sendController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sendScaleAnimation;
  
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _textController.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _sendController = AnimationController(
      duration: AppAnimations.micro,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sendScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _sendController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void didUpdateWidget(LoFiInputComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _sendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.composerPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.onAttachmentTap != null) ...[
                _buildAttachmentButton(),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: _buildTextInput(),
              ),
              const SizedBox(width: AppSpacing.sm),
              _hasText ? _buildSendButton() : _buildVoiceButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Semantics(
      label: 'Message input',
      hint: 'Type your message to the AI coach',
      textField: true,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.composerMinHeight,
          maxHeight: 120,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: widget.isEnabled,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.composerPlaceholder,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          onSubmitted: _hasText ? _sendMessage : null,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Semantics(
      label: 'Send message',
      hint: 'Sends your message to the AI coach',
      button: true,
      enabled: _hasText && widget.isEnabled,
      child: GestureDetector(
        onTapDown: (_) => _sendController.forward(),
        onTapUp: (_) => _sendController.reverse(),
        onTapCancel: () => _sendController.reverse(),
        onTap: _hasText ? _sendMessage : null,
        child: ScaleTransition(
          scale: _sendScaleAnimation,
          child: Container(
            width: AppSpacing.composerMinHeight,
            height: AppSpacing.composerMinHeight,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.send_rounded,
              color: AppColors.surface,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Semantics(
      label: widget.isRecording ? 'Stop recording' : 'Start voice recording',
      hint: widget.isRecording 
          ? 'Tap to stop voice recording and send message'
          : 'Tap to start recording a voice message',
      button: true,
      enabled: widget.isEnabled,
      liveRegion: widget.isRecording,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _pulseAnimation.value : 1.0,
            child: GestureDetector(
              onTap: _toggleVoiceRecording,
              child: Container(
                width: AppSpacing.composerMinHeight,
                height: AppSpacing.composerMinHeight,
                decoration: BoxDecoration(
                  color: widget.isRecording
                      ? AppColors.error
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRecording ? Icons.stop : Icons.mic,
                  color: widget.isRecording
                      ? AppColors.surface
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Semantics(
      label: 'Add attachment',
      hint: 'Tap to add files, images, or other attachments to your message',
      button: true,
      enabled: widget.isEnabled,
      child: GestureDetector(
        onTap: widget.onAttachmentTap,
        child: Container(
          width: AppSpacing.composerMinHeight,
          height: AppSpacing.composerMinHeight,
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.attach_file,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _sendMessage([String? text]) {
    final message = text ?? _textController.text.trim();
    if (message.isNotEmpty && widget.isEnabled) {
      HapticFeedback.lightImpact();
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  void _toggleVoiceRecording() {
    HapticFeedback.selectionClick();
    if (widget.isRecording) {
      widget.onVoiceStop?.call();
    } else {
      widget.onVoiceStart?.call();
    }
  }
}