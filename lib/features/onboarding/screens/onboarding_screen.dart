import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Your AI Coach',
      subtitle: 'Supporting your mental wellness journey with empathy and understanding',
      icon: Icons.psychology,
      primaryColor: AppColors.deepTeal,
      content: 'Your personal AI wellness coach is here to provide support, guidance, and encouragement tailored specifically for athletes and sports teams.',
    ),
    OnboardingPage(
      title: 'Privacy & Data Security',
      subtitle: 'Your data is encrypted and secure',
      icon: Icons.security,
      primaryColor: AppColors.softBlue,
      content: 'We use end-to-end encryption and follow GDPR compliance. Your conversations and health data are never shared without your explicit consent.',
    ),
    OnboardingPage(
      title: 'Health Data Integration',
      subtitle: 'Connect with your wearables for personalized insights',
      icon: Icons.favorite,
      primaryColor: AppColors.lime,
      content: 'Securely connect your Apple HealthKit or Google Health Connect data to receive personalized wellness recommendations.',
    ),
    OnboardingPage(
      title: 'Human Support Available',
      subtitle: 'Connect with qualified coaches when you need it',
      icon: Icons.support_agent,
      primaryColor: AppColors.orange,
      content: 'While our AI provides 24/7 support, you can always escalate to speak with a qualified human coach for additional guidance.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSkipButton(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => _completeOnboarding(),
          child: Text(
            'Skip',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.onboardingHorizontal,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPageIcon(page),
          const SizedBox(height: AppSpacing.onboardingVertical),
          _buildPageTitle(page),
          const SizedBox(height: AppSpacing.lg),
          _buildPageSubtitle(page),
          const SizedBox(height: AppSpacing.xxl),
          _buildPageContent(page),
        ],
      ),
    );
  }

  Widget _buildPageIcon(OnboardingPage page) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              page.primaryColor,
              page.primaryColor.withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: page.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          page.icon,
          color: AppColors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildPageTitle(OnboardingPage page) {
    return Text(
      page.title,
      style: AppTypography.h1,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPageSubtitle(OnboardingPage page) {
    return Text(
      page.subtitle,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.grey600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Text(
      page.content,
      style: AppTypography.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: AppSpacing.xxl),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.deepTeal
                : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Row(
      children: [
        if (_currentPage > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        Expanded(
          flex: _currentPage > 0 ? 1 : 2,
          child: ElevatedButton(
            onPressed: isLastPage ? _requestPermissions : _nextPage,
            child: Text(isLastPage ? 'Get Started' : 'Continue'),
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      await Permission.notification.request();
      
      // Request health data permission
      if (await Health().hasPermissions([
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ]) != true) {
        await Health().requestAuthorization([
          HealthDataType.STEPS,
          HealthDataType.HEART_RATE,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.WORKOUT,
        ]);
      }
      
      _completeOnboarding();
    } catch (e) {
      // Handle permission errors gracefully
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // TODO: Save onboarding completion status
    AppRoute.chat.go(context);
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final Color primaryColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.primaryColor,
  });
}