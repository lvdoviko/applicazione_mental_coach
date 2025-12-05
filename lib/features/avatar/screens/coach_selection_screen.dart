import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/avatar_selection_step.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/user/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart';

class CoachSelectionScreen extends ConsumerStatefulWidget {
  const CoachSelectionScreen({super.key});

  @override
  ConsumerState<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends ConsumerState<CoachSelectionScreen> {
  String? _selectedAvatarId;

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

    // 1. Update User Provider
    await ref.read(userProvider.notifier).updateUser(
      avatarId: _selectedAvatarId,
    );

    // 2. Load the new avatar
    // This will trigger the download and update the AvatarProvider state
    await ref.read(avatarProvider.notifier).loadAvatarFromId(_selectedAvatarId!);

    if (mounted) {
      // Navigate directly to Chat Screen
      context.go(AppRoute.chat.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
    );
  }
}
