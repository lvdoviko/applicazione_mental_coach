import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSendMessage,
    this.hintText = 'Share what\'s on your mind...',
    this.enabled = true,
    this.maxLines = 5,
    this.onVoiceStart,
    this.onVoiceStop,
    this.supportsSpeech = true,
  });

  final Function(String message) onSendMessage;
  final String hintText;
  final bool enabled;
  final int maxLines;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceStop;
  final bool supportsSpeech;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();

  bool _isListening = false;
  bool _speechEnabled = false;
  bool _hasText = false;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _textController.addListener(_onTextChanged);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeSpeech() async {
    if (!widget.supportsSpeech) return;
    
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        setState(() => _isListening = false);
        _pulseController.stop();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          _pulseController.stop();
          widget.onVoiceStop?.call();
        }
      },
    );
    setState(() {});
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSendMessage(text);
    _textController.clear();
    _focusNode.unfocus();
  }

  void _toggleListening() {
    if (!_speechEnabled || !widget.enabled) return;

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US', // A/B test hook: could be dynamic
    );

    setState(() => _isListening = true);
    _pulseController.repeat(reverse: true);
    widget.onVoiceStart?.call();
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
    _pulseController.stop();
    widget.onVoiceStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Force dark mode for consistency
    const isDarkMode = true;

    return Semantics(
      label: 'Message composer',
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          // Background decoration removed to make it transparent
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 48,
                      maxHeight: 48.0 * widget.maxLines,
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: AppTypography.composerPlaceholder,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.grey600,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.grey600,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.warmGold,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.grey800,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildVoiceButton removed

  Widget _buildSendButton() {
    final canSend = _hasText && widget.enabled;
    // Force dark mode colors
    const isDarkMode = true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: canSend 
            ? AppColors.warmGold
            : AppColors.grey700,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: canSend ? _sendMessage : null,
          child: Icon(
            Icons.send,
            color: canSend ? AppColors.white : AppColors.grey500,
            size: 20,
            semanticLabel: 'Send message',
          ),
        ),
      ),
    );
  }
}