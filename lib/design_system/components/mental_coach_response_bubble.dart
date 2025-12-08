import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

/// **Mental Coach Response Bubble**
/// 
/// Enterprise-grade chat bubble for AI responses.
/// Features:
/// - Performance optimization via [RepaintBoundary] and [BackdropFilter] containment
/// - Centralized Design Tokens integration
/// - Markdown rendering with custom styling
/// - Typing indicator
class MentalCoachResponseBubble extends StatelessWidget {
  final String text;
  final bool isStreaming;

  const MentalCoachResponseBubble({
    super.key,
    required this.text,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    final baseTextColor = AppColors.textPrimary;
    final accentColor = AppColors.accent;
    final cardBgColor = AppColors.botBubble.withOpacity(0.7);
    final borderColor = AppColors.border.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(
        left: AppSpacing.sm, // Aligned with LofiMessageBubble
        right: AppSpacing.massive, // Not full width
        bottom: AppSpacing.messageBubbleMargin,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        // PERFORMANCE: RepaintBoundary isolates this intense graphical effect
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBgColor,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: AppTypography.chatBubbleBot.copyWith(
                         color: baseTextColor.withOpacity(0.9),
                         height: 1.6, // Enterprise readability
                      ),
                      strong: AppTypography.chatBubbleBot.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                      listBullet: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                      ),
                      blockSpacing: 12.0,
                      h1: AppTypography.h3.copyWith(color: baseTextColor),
                      h2: AppTypography.h4.copyWith(color: baseTextColor),
                      // Ensure code blocks look decent if ever used
                      code: GoogleFonts.firaCode(
                          backgroundColor: Colors.black26, 
                          color: accentColor,
                          fontSize: 14
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: _TypingIndicator(color: accentColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Piccolo widget animato per il cursore
class _TypingIndicator extends StatefulWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 5)
          ]
        ),
      ),
    );
  }
}
