import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_waves_background.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

/// **Lo-Fi Minimal Onboarding Screen**
/// 
/// **Functional Description:**
/// Clean single-screen introduction with gentle micro-copy, smooth CTA transitions,
/// and paper-like background. Introduces users to the AI coach with minimal friction.
/// 
/// **Visual Specifications:**
/// - Background: #FBF9F8 (paper texture)
/// - Primary CTA: #7DAEA9 with 12px radius
/// - Typography: Inter with relaxed line-heights, generous whitespace
/// - Spacing: 64px sections, 24px margins
/// - Animations: 350ms easeOutCubic, smooth fade-ins
/// 
/// **Accessibility:**
/// - Semantic labels for screen readers
/// - High contrast text (4.5:1 minimum)  
/// - Focus management and keyboard navigation
/// - Dynamic Type support
/// 
/// **Performance:**
/// - Stateless when possible, minimal animations
/// - Preloaded assets, optimized widget tree
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              l10n?.skip ?? 'Skip',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              semanticsLabel: 'Skip onboarding',
            ),
          ),
        ],
      ),
      body: LoFiWavesBackground(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeroSection(l10n!),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        _buildFeaturePoints(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActionButtons(l10n),
              const SizedBox(height: AppSpacing.elementSpacing),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations l10n) {
    return Column(
      children: [
        _buildHeroIllustration(),
        const SizedBox(height: AppSpacing.elementSpacing),
        _buildHeadlineText(l10n),
        const SizedBox(height: AppSpacing.lg),
        _buildSubtitleText(l10n),
      ],
    );
  }

  Widget _buildHeroIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.psychology_outlined,
        size: 56,
        color: AppColors.primary,
        semanticLabel: 'AI Coach illustration',
      ),
    );
  }

  Widget _buildHeadlineText(AppLocalizations l10n) {
    return Text(
      l10n.onboardingTitle,
      style: AppTypography.headingLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      semanticsLabel: 'Welcome to your AI coach',
    );
  }

  Widget _buildSubtitleText(AppLocalizations l10n) {
    return Text(
      l10n.onboardingSubtitle,
      style: AppTypography.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
      semanticsLabel: 'Supporting your mental wellness journey',
    );
  }

  Widget _buildFeaturePoints() {
    final features = [
      {'icon': Icons.chat_bubble_outline, 'text': 'Personal conversations'},
      {'icon': Icons.psychology_outlined, 'text': 'AI-powered insights'},
      {'icon': Icons.lock_outline, 'text': 'Private and secure'},
    ];

    return Column(
      children: features
          .map((feature) => _buildFeaturePoint(
                feature['icon'] as IconData,
                feature['text'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildFeaturePoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Column(
      children: [
        _buildPrimaryButton(l10n),
        const SizedBox(height: AppSpacing.md),
        _buildSecondaryButton(l10n),
      ],
    );
  }

  Widget _buildPrimaryButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleGetStarted,
        child: Text(
          l10n.getStarted,
          semanticsLabel: 'Get started with AI coach',
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(AppLocalizations l10n) {
    return TextButton(
      onPressed: _handleSkip,
      child: Text(
        'Learn more',
        style: AppTypography.buttonMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        semanticsLabel: 'Learn more about features',
      ),
    );
  }

  void _handleGetStarted() {
    HapticFeedback.lightImpact();
    // TODO: Save onboarding completion and navigate to chat
    try {
      AppRoute.chat.go(context);
    } catch (e) {
      // Fallback navigation
      Navigator.of(context).pushReplacementNamed('/chat');
    }
  }

  void _handleSkip() {
    HapticFeedback.selectionClick();
    // TODO: Navigate to dashboard or main app
    try {
      AppRoute.dashboard.go(context);
    } catch (e) {
      // Fallback navigation 
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }
}