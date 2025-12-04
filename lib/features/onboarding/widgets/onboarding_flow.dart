import 'dart:ui' as org_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/language_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/welcome_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/user_details_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/avatar_selection_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/loading_step.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/features/user/providers/user_provider.dart';
import 'package:applicazione_mental_coach/core/providers/locale_provider.dart';
import 'package:applicazione_mental_coach/shared/widgets/living_background.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/avatar/providers/avatar_provider.dart';
import 'package:applicazione_mental_coach/features/chat/providers/chat_provider.dart';
import 'package:applicazione_mental_coach/features/avatar/services/avatar_engine.dart'; // Import AvatarEngine
import 'package:applicazione_mental_coach/features/avatar/domain/models/avatar_config.dart'; // Import AvatarConfigLoaded
import 'package:webview_flutter/webview_flutter.dart'; // Import WebViewWidget

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State
  Locale? _selectedLocale;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  String? _selectedAvatarId;
  Future<void>? _initializationFuture; // Store the future

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleLanguageSelected(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    ref.read(localeProvider.notifier).setLocale(locale);
    
    // Add a small delay so the user can see the selection feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _handleUserDetailsNext() {
    if (_nameController.text.isNotEmpty && 
        _ageController.text.isNotEmpty && 
        _selectedGender != null) {
      _nextPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void _handleAvatarSelected(String id) {
    setState(() {
      _selectedAvatarId = id;
    });
  }

  void _handleAvatarNext() {
    // Start initialization when moving to loading step
    _initializationFuture = _initializeBackend();
    _nextPage();
  }

  Future<void> _initializeBackend() async {
    print('🚀 Starting Backend Initialization...');
    
    // 1. Save User Data
    await ref.read(userProvider.notifier).updateUser(
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      languageCode: _selectedLocale?.languageCode,
      isOnboardingCompleted: true,
      avatarId: _selectedAvatarId,
    );
    print('✅ User data saved.');

    // 2. Start Parallel Initialization
    await Future.wait([
      // A. Connect WebSocket
      ref.read(chatProvider.notifier).connect().then((_) => print('✅ WebSocket Connected')),
      
      // B. Pre-load Avatar & Initialize Engine
      _initializeAvatarEngine(),

      // C. Pre-cache Background Image
      precacheImage(const AssetImage('assets/images/sfondo_chat.png'), context).then((_) => print('✅ Background Cached')),
    ]);
    
    print('🚀 Backend Initialization Complete!');
  }

  Future<void> _initializeAvatarEngine() async {
    if (_selectedAvatarId == null) return;

    // 1. Download Avatar (if needed)
    await ref.read(avatarProvider.notifier).loadAvatarFromId(_selectedAvatarId!);
    print('✅ Avatar Downloaded');

    // 2. Initialize Engine & Load Content
    final engine = ref.read(avatarEngineProvider);
    await engine.initialize();
    
    // 3. Get URL (Robust Fallback)
    String? avatarUrl;
    final avatarState = ref.read(avatarProvider);
    
    if (avatarState is AvatarStateLoaded && avatarState.config is AvatarConfigLoaded) {
      avatarUrl = (avatarState.config as AvatarConfigLoaded).remoteUrl;
    } else {
      // Fallback: Manually determine URL if state isn't ready yet
      if (_selectedAvatarId == 'atlas') {
        avatarUrl = 'https://models.readyplayer.me/6929b1e97b7a88e1f60a6f9e.glb?bodyType=fullbody&quality=high';
      } else {
        avatarUrl = 'https://models.readyplayer.me/69286d45132e61458cee2d1f.glb?bodyType=fullbody&quality=high';
      }
      print('⚠️ Using Fallback URL for Avatar Engine');
    }

    if (avatarUrl != null) {
      await engine.loadContent(
        avatarUrl: avatarUrl, 
        animationAsset: 'assets/animations/idle.glb'
      );
      
      // Wait for JS Signal (max 10 seconds)
      try {
        await engine.waitForAvatarLoad().timeout(const Duration(seconds: 10));
        print('✅ Avatar Visually Ready (JS Signal Received)');
      } catch (e) {
        print('⚠️ Avatar Load Timeout (Proceeding anyway)');
      }
      
      print('✅ Avatar Engine Warmed Up');
    }
  }

  void _handleLoadingFinished() {
    try {
      AppRoute.chat.go(context);
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(avatarEngineProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Hidden WebView to warm up the engine
          // Required on iOS: loadHtmlString hangs if controller is not attached to a view
          if (engine.controller != null)
            Offstage(
              offstage: true,
              child: WebViewWidget(controller: engine.controller!),
            ),

          SafeArea(
            top: true,
            bottom: false, // Allow content to extend to the bottom (fix for raised buttons)
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      LanguageStep(
                        onLanguageSelected: _handleLanguageSelected,
                        selectedLocale: _selectedLocale,
                      ),
                      WelcomeStep(
                        onNext: _nextPage,
                        onBack: _previousPage,
                      ),
                      UserDetailsStep(
                        nameController: _nameController,
                        ageController: _ageController,
                        selectedGender: _selectedGender,
                        onGenderChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        onNext: _handleUserDetailsNext,
                        onBack: _previousPage, 
                      ),
                      AvatarSelectionStep(
                        selectedAvatarId: _selectedAvatarId,
                        onAvatarSelected: _handleAvatarSelected,
                        onNext: _handleAvatarNext,
                        onBack: _previousPage,
                      ),
                      LoadingStep(
                        onFinished: _handleLoadingFinished,
                        userName: _nameController.text,
                        coachName: _selectedAvatarId == 'atlas' ? 'Atlas' : 'Serena',
                        initializationFuture: _initializationFuture, // Pass the future
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
