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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Message composer',
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.white,
          ),
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
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDarkMode 
                                ? AppColors.grey600 
                                : AppColors.grey300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDarkMode 
                                ? AppColors.grey600 
                                : AppColors.grey300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: isDarkMode 
                                ? AppColors.warmGold 
                                : AppColors.warmTerracotta,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDarkMode 
                            ? AppColors.grey800 
                            : AppColors.grey50,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (widget.supportsSpeech && _speechEnabled)
                  _buildVoiceButton(),
                const SizedBox(width: AppSpacing.sm),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: _isListening ? AppColors.error : AppColors.grey100,
              shape: BoxShape.circle,
              border: _isListening
                  ? Border.all(color: AppColors.error.withOpacity(0.3), width: 2)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _toggleListening,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? AppColors.white : AppColors.grey600,
                  size: 20,
                  semanticLabel: _isListening ? 'Stop recording' : 'Start voice recording',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    final canSend = _hasText && widget.enabled;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: canSend 
            ? (isDarkMode ? AppColors.warmGold : AppColors.warmTerracotta)
            : AppColors.grey300,
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