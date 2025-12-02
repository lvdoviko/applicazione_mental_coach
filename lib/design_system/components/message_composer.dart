import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech initialization error: $error');
          if (mounted) {
            setState(() => _isListening = false);
            _pulseController.stop();
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (mounted && (status == 'done' || status == 'notListening')) {
            setState(() => _isListening = false);
            _pulseController.stop();
            widget.onVoiceStop?.call();
          }
        },
      );
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      _speechEnabled = false;
    }
    
    if (mounted) {
      setState(() {});
    }
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
    if (!_speechEnabled) return;
    
    try {
      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'it_IT', // Changed to Italian as default
      );

      if (mounted) {
        setState(() => _isListening = true);
        _pulseController.repeat(reverse: true);
        widget.onVoiceStart?.call();
      }
    } catch (e) {
      debugPrint('Start listening failed: $e');
    }
  }

  void _stopListening() async {
    try {
      await _speechToText.stop();
      if (mounted) {
        setState(() => _isListening = false);
        _pulseController.stop();
        widget.onVoiceStop?.call();
      }
    } catch (e) {
      debugPrint('Stop listening failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Margini laterali e dal fondo per farla "galleggiare"
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35), // Forma a pillola
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Sfocatura forte
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5), // Padding interno
            decoration: BoxDecoration(
              // Sfondo UNICO semitrasparente (uniforma i colori)
              color: const Color(0xFF0D1322).withOpacity(0.80), 
              // Bordo sottile bianco per l'effetto vetro
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                // 1. CAMPO DI TESTO (Trasparente e Pulito)
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    textAlignVertical: TextAlignVertical.center, // Allineamento verticale perfetto
                    style: GoogleFonts.nunito(color: Colors.white, fontSize: 16),
                    cursorColor: const Color(0xFF4A90E2), // Cursore blu elegante
                    decoration: InputDecoration(
                      hintText: "Scrivi un messaggio...",
                      hintStyle: GoogleFonts.nunito(color: Colors.white38),
                      
                      // 1. TRASPARENZA TOTALE (Fix per i "3 colori")
                      filled: true,
                      fillColor: Colors.transparent,
                      
                      // 2. RIMUOVIAMO TUTTI I BORDI
                      border: const OutlineInputBorder(borderSide: BorderSide.none), 
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none), 
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                      errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                      disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                      
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                const SizedBox(width: 10),

                // 2. BOTTONE INVIO (Integrato nella pillola)
                Container(
                  height: 45, width: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2), // Blu Elettrico del brand
                    shape: BoxShape.circle,
                    // Ombra interna per profondità
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  ),
                  child: IconButton(
                    // Icona INVIO leggermente spostata per centratura ottica
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 2.0),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods removed as they are now inline or unused
}