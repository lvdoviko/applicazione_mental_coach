import 'dart:ui' as org_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/language_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/welcome_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/user_details_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/personality_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/coach_result_step.dart';
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
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

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
  // final TextEditingController _ageController = TextEditingController(); // Removed
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String? _selectedAvatarId;
  String? _selectedPersonality;
  Future<void>? _initializationFuture; // Store the future
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    // _ageController.dispose();
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
        _selectedDateOfBirth != null && 
        _selectedGender != null) {
      _nextPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void _handlePersonalitySelected(String personalityId) async {
    setState(() {
      _selectedPersonality = personalityId;
      _isAnalyzing = true;
    });

    // 🧠 Matching Algorithm
    // Competitivo, Disciplinato -> Atlas
    // Riflessivo, Empatico, Energetico -> Serena
    String assignedCoachId;
    if (['Competitivo', 'Disciplinato'].contains(personalityId)) {
      assignedCoachId = 'atlas';
    } else {
      assignedCoachId = 'serena'; // Default ID
    }

    // UX: Simulate Analysis
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _selectedAvatarId = assignedCoachId;
        _isAnalyzing = false;
      });
      
      // Proceed to Result Step
      _nextPage();
    }
  }

  void _handleCoachResultStart() {
      // Start initialization when moving to loading step
      _initializationFuture = _initializeBackend();
      _nextPage();
  }

  Future<void> _initializeBackend() async {
    print('🚀 Starting Backend Initialization...');
    
    // Calculate accurate age
    int age = 0;
    if (_selectedDateOfBirth != null) {
      final now = DateTime.now();
      age = now.year - _selectedDateOfBirth!.year;
      if (now.month < _selectedDateOfBirth!.month || 
          (now.month == _selectedDateOfBirth!.month && now.day < _selectedDateOfBirth!.day)) {
        age--;
      }
    }

    // 1. Save User Data
    await ref.read(userProvider.notifier).updateUser(
      name: _nameController.text,
      age: age,
      gender: _selectedGender,
      languageCode: _selectedLocale?.languageCode,
      isOnboardingCompleted: true,
      avatarId: _selectedAvatarId,
      personality: _selectedPersonality,
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
                        dobController: _dobController,
                        selectedGender: _selectedGender,
                        onGenderChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        onDobSelected: (date) {
                          setState(() {
                             _selectedDateOfBirth = date;
                             // Format: dd/MM/yyyy
                             _dobController.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                          });
                        },
                        onNext: _handleUserDetailsNext,
                        onBack: _previousPage, 
                      ),
                      // NEW: Personality Step (Algorithm)
                      PersonalityStep(
                        onPersonalitySelected: _handlePersonalitySelected,
                        onBack: _previousPage,
                      ),
                      // NEW: Coach Result Step
                      if (_selectedAvatarId != null)
                        CoachResultStep(
                          assignedCoachId: _selectedAvatarId!,
                          onStart: _handleCoachResultStart,
                        ),
                      // Result/Loading Step
                      LoadingStep(
                        onFinished: _handleLoadingFinished,
                        userName: _nameController.text,
                        coachName: _selectedAvatarId == 'atlas' ? 'Atlas' : 'Serena',
                        initializationFuture: _initializationFuture, 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Analysis Overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.assigningCoach(_nameController.text),
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Inter',
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
