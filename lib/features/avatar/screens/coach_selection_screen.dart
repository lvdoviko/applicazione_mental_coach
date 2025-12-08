import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/avatar_selection_step.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/user/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';
import 'package:applicazione_mental_coach/features/chat/providers/chat_provider.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

class CoachSelectionScreen extends ConsumerStatefulWidget {
  const CoachSelectionScreen({super.key});

  @override
  ConsumerState<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends ConsumerState<CoachSelectionScreen> {
  String? _selectedAvatarId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current avatar ID
    final avatarState = ref.read(avatarProvider);
    if (avatarState is AvatarStateLoaded && avatarState.config is AvatarConfigLoaded) {
      final config = avatarState.config as AvatarConfigLoaded;
      // Heuristic to determine ID from URL or other means if ID isn't directly stored in config
      // But wait, AvatarConfigLoaded doesn't seem to have the ID directly exposed easily?
      // Actually, let's check UserProvider, it might have the avatarId.
      final user = ref.read(userProvider);
      _selectedAvatarId = user?.avatarId;
    }
  }

  void _handleAvatarSelected(String id) {
    setState(() {
      _selectedAvatarId = id;
    });
  }

  Future<void> _handleNext() async {
    if (_selectedAvatarId == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Update User Provider
      await ref.read(userProvider.notifier).updateUser(
        avatarId: _selectedAvatarId,
      );

      // 2. Load the new avatar
      // This will trigger the download and update the AvatarProvider state
      await ref.read(avatarProvider.notifier).loadAvatarFromId(_selectedAvatarId!);

      // 3. Reset Chat & Prepare Welcome Message
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final coachName = _selectedAvatarId == 'atlas' 
            ? l10n.coachAtlas 
            : l10n.coachSerena;
        
        final welcomeText = l10n.welcomeMessage(coachName);

        // Reset chat session and inject the new welcome message to be streamed
        await ref.read(chatProvider.notifier).resetChat(
          welcomeMessageText: welcomeText,
        );

        // Navigate directly to Chat Screen
        if (mounted) {
          context.go(AppRoute.chat.path);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  Color(0xFF1C2541), // Deep Blue
                  Color(0xFF000000), // Black
                ],
              ),
            ),
            child: SafeArea(
              child: SizedBox.expand( // Force full size for the Stack in AvatarSelectionStep
                child: AvatarSelectionStep(
                  selectedAvatarId: _selectedAvatarId,
                  onAvatarSelected: _handleAvatarSelected,
                  onNext: _handleNext,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    const Text(
                      "Preparing your coach...",
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
