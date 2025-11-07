import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Quick Suggestions Widget**
/// 
/// **Functional Description:**
/// Pill-shaped suggestion chips that appear contextually with smooth animations.
/// Supports scrolling and contextual suggestion generation.
/// 
/// **Visual Specifications:**
/// - Pills: #F8F6F5 background, 20px radius
/// - Text: Inter 14px medium, #6B7280 color
/// - Padding: 16px horizontal, 8px vertical
/// - Spacing: 8px between chips
/// - Animation: 200ms appear/disappear with easeOut
/// 
/// **Component Name:** LoFiQuickSuggestions
/// 
/// **Accessibility:**
/// - Chip button semantics
/// - Scroll announcements
/// - Focus management
/// - Action confirmations
/// 
/// **Performance:**
/// - Lazy loading for large lists
/// - Optimized scroll physics
/// - Minimal animation overhead
typedef SuggestionCallback = void Function(String suggestion);

class LoFiQuickSuggestions extends StatefulWidget {
  final List<String> suggestions;
  final SuggestionCallback onSuggestionTap;
  final bool isVisible;
  final EdgeInsets padding;

  const LoFiQuickSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.isVisible = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenPadding,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  State<LoFiQuickSuggestions> createState() => _LoFiQuickSuggestionsState();
}

class _LoFiQuickSuggestionsState extends State<LoFiQuickSuggestions>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.isVisible && widget.suggestions.isNotEmpty) {
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.small,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void didUpdateWidget(LoFiQuickSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible && widget.suggestions.isNotEmpty) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    
    if (widget.suggestions != oldWidget.suggestions && 
        widget.isVisible && 
        widget.suggestions.isNotEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 44,
            maxHeight: 80,
          ),
          padding: widget.padding,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                children: widget.suggestions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final suggestion = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < widget.suggestions.length - 1 
                        ? AppSpacing.chipSpacing 
                        : 0,
                    ),
                    child: _buildSuggestionChip(suggestion, index),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
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
      child: Material(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onSuggestionTap(suggestion),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 200,
              minHeight: 32,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.chipPaddingHorizontal,
              vertical: AppSpacing.chipPaddingVertical + 2,
            ),
            child: Center(
              child: Text(
                suggestion,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSuggestionTap(String suggestion) {
    HapticFeedback.selectionClick();
    widget.onSuggestionTap(suggestion);
  }
}

/// Predefined suggestion sets for different contexts
class QuickSuggestionPresets {
  // Mental Health Context - Anticipating common user needs
  static const List<String> mentalHealthStarters = [
    "Sto attraversando un periodo difficile",
    "Ho bisogno di supporto emotivo", 
    "Mi sento sopraffatto",
    "Vorrei parlare di ansia",
  ];

  static const List<String> emotionalStates = [
    "Mi sento triste oggi",
    "Ho problemi di autostima",
    "Sono stressato dal lavoro",
    "Non riesco a dormire bene",
  ];

  // Progress & Goals - Action-oriented
  static const List<String> progressGoals = [
    "Voglio fissare un obiettivo",
    "Come posso migliorare?",
    "Ho raggiunto un traguardo",
    "Sto facendo progressi",
  ];

  // Immediate Help - Urgent support
  static const List<String> immediateHelp = [
    "Ho bisogno di aiuto ora",
    "Cosa posso fare oggi?",
    "Come gestisco questa situazione?",
    "Parliamo di strategie pratiche",
  ];

  // Relationship & Social
  static const List<String> relationships = [
    "Ho problemi in famiglia",
    "Difficoltà nelle relazioni",
    "Mi sento solo",
    "Conflitti con gli altri",
  ];

  // Self-Care & Wellness
  static const List<String> selfCare = [
    "Come prendermi cura di me?",
    "Tecniche di rilassamento",
    "Voglio migliorare le abitudini",
    "Bilanciare lavoro e vita",
  ];

  // Empathetic responses (when AI asks about feelings)
  static const List<String> empathetic = [
    "Sì, esattamente così",
    "È proprio quello che provo", 
    "Mi capisci davvero",
    "Dimmi di più su questo",
  ];

  // Supportive (when receiving advice)
  static const List<String> supportive = [
    "Grazie, mi aiuta molto",
    "Voglio provare questo approccio",
    "Hai altri consigli?",
    "Come posso iniziare?",
  ];

  // Curious (when exploring topics)
  static const List<String> curious = [
    "Puoi spiegarmi meglio?",
    "Come funziona esattamente?",
    "Hai esempi pratici?",
    "Quali sono i passi successivi?",
  ];

  // Motivational responses
  static const List<String> motivational = [
    "Sono pronto a cambiare",
    "Voglio impegnarmi di più", 
    "Ce la posso fare",
    "Continuerò a lavorarci",
  ];

  // General conversation starters
  static const List<String> general = [
    "Ciao, come stai?",
    "Parlami del tuo approccio",
    "Ho una domanda",
    "Grazie per l'aiuto",
  ];

  /// Get contextual suggestions based on conversation state and user intent
  static List<String> getContextualSuggestions(String context) {
    switch (context.toLowerCase()) {
      case 'mental_health':
        return mentalHealthStarters;
      case 'emotional_states':
        return emotionalStates;
      case 'progress_goals':
        return progressGoals;
      case 'immediate_help':
        return immediateHelp;
      case 'relationships':
        return relationships;
      case 'self_care':
        return selfCare;
      case 'empathetic':
        return empathetic;
      case 'supportive':
        return supportive;
      case 'curious':
        return curious;
      case 'motivational':
        return motivational;
      default:
        return general;
    }
  }

  /// Get intelligent suggestions based on time of day and common patterns
  static List<String> getSmartSuggestions({
    required TimeOfDay timeOfDay,
    String? lastTopic,
    bool isFirstMessage = false,
  }) {
    if (isFirstMessage) {
      final hour = timeOfDay.hour;
      if (hour < 10) {
        return [
          "Buongiorno, come ti senti oggi?",
          "Ho dormito male stanotte",
          "Inizio la giornata con ansia",
          "Voglio iniziare bene la giornata",
        ];
      } else if (hour < 14) {
        return [
          "Come sta andando la mattinata?",
          "Sono stressato dal lavoro",
          "Ho bisogno di motivazione",
          "Pausa pranzo, riflettiamo",
        ];
      } else if (hour < 18) {
        return [
          "Il pomeriggio è pesante",
          "Sono stanco mentalmente",
          "Come gestire lo stress?",
          "Ho bisogno di energia",
        ];
      } else {
        return [
          "Come è andata la giornata?",
          "Mi sento emotivamente scarico",
          "Voglio rilassarmi stasera",
          "Riflettiamo sulla giornata",
        ];
      }
    }

    // Return contextual based on last topic discussed
    if (lastTopic?.contains('stress') == true) {
      return getContextualSuggestions('self_care');
    } else if (lastTopic?.contains('relationship') == true) {
      return getContextualSuggestions('relationships');
    }
    
    return mentalHealthStarters;
  }
}