import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/ios_button.dart';
import '../../health/services/health_permissions_service.dart';
import '../models/consent_model.dart';
import '../providers/consent_providers.dart';

/// GDPR-compliant consent and permissions screen
/// Handles data processing consent and health data permissions
class ConsentPermissionsScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onComplete;

  const ConsentPermissionsScreen({
    super.key,
    this.isInitialSetup = true,
    this.onComplete,
  });

  @override
  ConsumerState<ConsentPermissionsScreen> createState() => _ConsentPermissionsScreenState();
}

class _ConsentPermissionsScreenState extends ConsumerState<ConsentPermissionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Consent states
  bool _dataProcessingConsent = false;
  bool _healthDataConsent = false;
  bool _marketingConsent = false;
  bool _analyticsConsent = false;

  // Health permissions states
  bool _healthKitPermissionGranted = false;
  bool _healthKitPermissionRequested = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildDataProcessingConsentPage(),
                  _buildHealthDataConsentPage(),
                  _buildHealthPermissionsPage(),
                  _buildOptionalConsentsPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: List.generate(6, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < 5 ? AppSpacing.xs : 0,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.privacy_tip_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Privacy & Permissions',
            style: AppTypography.headingLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          
          Text(
            'KAIX respects your privacy and follows GDPR requirements. We\'ll walk you through the permissions needed to provide personalized mental wellness coaching.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Your data is encrypted and never shared with third parties without your explicit consent.',
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProcessingConsentPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Data Processing Consent',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'Required for basic app functionality',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildConsentItem(
            title: 'Process personal data for AI coaching',
            description: 'We process your messages and profile information to provide personalized mental wellness guidance through our AI coach.',
            isRequired: true,
            value: _dataProcessingConsent,
            onChanged: (value) => setState(() => _dataProcessingConsent = value),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          _buildDataProcessingDetails(),
        ],
      ),
    );
  }

  Widget _buildHealthDataConsentPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Health Data Processing',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'For enhanced personalized coaching',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildConsentItem(
            title: 'Process health and wellness data',
            description: 'Allow KAIX to process your health metrics (sleep, activity, heart rate) to provide more personalized mental wellness advice.',
            isRequired: false,
            value: _healthDataConsent,
            onChanged: (value) => setState(() => _healthDataConsent = value),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          _buildHealthDataDetails(),
        ],
      ),
    );
  }

  Widget _buildHealthPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Health App Permissions',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            _healthDataConsent 
                ? 'Grant access to your health data'
                : 'Health data consent not granted',
            style: AppTypography.bodySmall.copyWith(
              color: _healthDataConsent ? AppColors.textSecondary : AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          if (!_healthDataConsent) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Health permissions are disabled because health data consent was not granted on the previous step.',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildHealthPermissionCard(),
            const SizedBox(height: AppSpacing.md),
            if (!_healthKitPermissionGranted && _healthKitPermissionRequested)
              _buildPermissionDeniedCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthPermissionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_outline, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'HealthKit Access',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'We\'ll request access to:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          
          ...['Sleep Analysis', 'Heart Rate', 'Steps', 'Active Energy', 'Workouts'].map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Text(item, style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          IOSButton(
            text: _healthKitPermissionGranted 
                ? 'Permissions Granted ✓'
                : 'Grant HealthKit Access',
            onPressed: _healthKitPermissionGranted ? null : _requestHealthPermissions,
            style: _healthKitPermissionGranted 
                ? IOSButtonStyle.secondary 
                : IOSButtonStyle.primary,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalConsentsPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Optional Preferences',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'These help us improve your experience',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildConsentItem(
            title: 'Analytics and app improvement',
            description: 'Help us improve KAIX by sharing anonymous usage analytics.',
            isRequired: false,
            value: _analyticsConsent,
            onChanged: (value) => setState(() => _analyticsConsent = value),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          _buildConsentItem(
            title: 'Product updates and tips',
            description: 'Receive occasional emails about new features and mental wellness tips.',
            isRequired: false,
            value: _marketingConsent,
            onChanged: (value) => setState(() => _marketingConsent = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Privacy Summary',
            style: AppTypography.headingMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildSummaryItem(
            'Data Processing', 
            _dataProcessingConsent ? 'Granted ✓' : 'Denied ✗',
            _dataProcessingConsent,
          ),
          _buildSummaryItem(
            'Health Data Processing', 
            _healthDataConsent ? 'Granted ✓' : 'Denied ✗',
            _healthDataConsent,
          ),
          _buildSummaryItem(
            'HealthKit Permissions', 
            _healthKitPermissionGranted ? 'Granted ✓' : 'Not granted',
            _healthKitPermissionGranted,
          ),
          _buildSummaryItem(
            'Analytics', 
            _analyticsConsent ? 'Enabled ✓' : 'Disabled',
            _analyticsConsent,
          ),
          _buildSummaryItem(
            'Marketing', 
            _marketingConsent ? 'Enabled ✓' : 'Disabled',
            _marketingConsent,
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You can change these preferences anytime in Settings. Your choices are saved securely and in compliance with GDPR.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentItem({
    required String title,
    required String description,
    required bool isRequired,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                value ? 'Granted' : 'Denied',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: value ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String status, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodyMedium),
          Text(
            status,
            style: AppTypography.bodyMedium.copyWith(
              color: isGranted ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProcessingDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What data we process:',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...['Chat messages and interactions', 'Profile information', 'App usage patterns', 'Wellness preferences'].map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('• $item', style: AppTypography.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDataDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health data we may access:',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...['Sleep duration and quality', 'Heart rate and variability', 'Daily activity and steps', 'Workout data', 'Stress indicators'].map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text('• $item', style: AppTypography.bodySmall),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Permissions Denied',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'HealthKit access was denied. You can grant permissions later in iOS Settings > Health > Data Access & Devices > KAIX.',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: IOSButton(
                text: 'Back',
                onPressed: _goToPreviousPage,
                style: IOSButtonStyle.secondary,
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
          
          Expanded(
            flex: _currentPage == 0 ? 1 : 2,
            child: IOSButton(
              text: _getNextButtonText(),
              onPressed: _canProceed() ? _goToNextPage : null,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  String _getNextButtonText() {
    switch (_currentPage) {
      case 0: return 'Start Setup';
      case 5: return 'Complete Setup';
      default: return 'Continue';
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return true;
      case 1: return _dataProcessingConsent; // Required
      case 2: return true; // Health data consent is optional
      case 3: return true; // Health permissions are optional
      case 4: return true; // Analytics and marketing are optional
      case 5: return true; // Summary page
      default: return false;
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  Future<void> _requestHealthPermissions() async {
    if (!_healthDataConsent) return;
    
    setState(() => _isLoading = true);
    
    try {
      // This would need proper initialization with SharedPreferences
      // For now, we'll simulate the result
      // final prefs = await SharedPreferences.getInstance();
      // final permissionsService = HealthPermissionsService(prefs);
      // final granted = await permissionsService.requestPermissions();
      const granted = true; // Simulate successful permission grant
      
      setState(() {
        _healthKitPermissionGranted = granted;
        _healthKitPermissionRequested = true;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _healthKitPermissionGranted = false;
        _healthKitPermissionRequested = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeSetup() async {
    setState(() => _isLoading = true);
    
    // Save consent preferences
    final consent = ConsentData(
      dataProcessingConsent: _dataProcessingConsent,
      healthDataConsent: _healthDataConsent,
      marketingConsent: _marketingConsent,
      analyticsConsent: _analyticsConsent,
      healthPermissionsGranted: _healthKitPermissionGranted,
      consentVersion: '1.0',
      timestamp: DateTime.now(),
    );
    
    try {
      await ref.read(consentNotifierProvider.notifier).updateConsent(consent);
      
      setState(() => _isLoading = false);
      
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error - could show a snackbar
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}