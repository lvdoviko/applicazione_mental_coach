import 'dart:ui' as org_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/language_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/user_details_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/avatar_selection_step.dart';
import 'package:applicazione_mental_coach/features/onboarding/widgets/steps/loading_step.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/features/user/providers/user_provider.dart';
import 'package:applicazione_mental_coach/core/providers/locale_provider.dart';

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
    _nextPage();
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
    // Navigate to loading step
    _nextPage();
  }

  Future<void> _handleLoadingFinished() async {
    // Save all data
    await ref.read(userProvider.notifier).updateUser(
      name: _nameController.text,
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      languageCode: _selectedLocale?.languageCode,
      isOnboardingCompleted: true,
    );

    print('User data saved.');

    try {
      AppRoute.chat.go(context);
    } catch (e) {
      Navigator.of(context).pushReplacementNamed('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirstPage = _currentPage == 0;
    final isLoadingStep = _currentPage == 3; // Assuming LoadingStep is index 3

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Global Background (Aurora Effect)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E1B4B), // Indigo 950
                  Color(0xFF000000), // Black
                ],
              ),
            ),
          ),
          // Subtle radial overlay for depth
          Positioned(
            top: -100,
            left: -100,
            child: ImageFiltered(
              imageFilter: org_ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4F46E5).withOpacity(0.2), // Indigo
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: org_ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEC4899).withOpacity(0.1), // Pink
                ),
              ),
            ),
          ),

          // 2. Page Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar (Back Button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      if (!isFirstPage && !isLoadingStep)
                        IconButton(
                          onPressed: _previousPage,
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                          ),
                        )
                      else
                        const SizedBox(height: 48), // Placeholder to keep layout stable
                    ],
                  ),
                ),
                
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
                        // Back is handled globally now, but we keep the callback if needed or remove it from widget
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
