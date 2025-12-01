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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
