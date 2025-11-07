import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';

/// **Lo-Fi Error State Component**
/// 
/// **Functional Description:**
/// Gentle error display with helpful messaging and recovery actions.
/// Includes retry buttons and escalation options.
/// 
/// **Visual Specifications:**
/// - Error icon: #FCA5A5 soft red in circle background
/// - Typography: Inter 20px heading, 16px body
/// - Actions: Primary retry, secondary support
/// - Background: Subtle #FFFAFA error tint
/// - Border radius: 12px on action cards
/// 
/// **Component Name:** LoFiErrorState
/// 
/// **Accessibility:**
/// - Error announcements
/// - Retry button semantics
/// - Clear action labels
/// - Focus management
/// 
/// **Performance:**
/// - Stateless error display
/// - Minimal animation overhead
/// - Efficient action handling
enum ErrorSeverity { info, warning, error, critical }

class LoFiErrorState extends StatefulWidget {
  final String title;
  final String message;
  final String? details;
  final IconData? icon;
  final ErrorSeverity severity;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool canDismiss;
  final VoidCallback? onDismiss;
  final bool isAnimated;

  const LoFiErrorState({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.icon,
    this.severity = ErrorSeverity.error,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.canDismiss = false,
    this.onDismiss,
    this.isAnimated = true,
  });

  @override
  State<LoFiErrorState> createState() => _LoFiErrorStateState();
}

class _LoFiErrorStateState extends State<LoFiErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _setupAnimations();
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.easeOut,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    
    if (widget.isAnimated) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                (_shakeAnimation.value * 10 * (1 - _shakeAnimation.value)) * 
                (widget.severity == ErrorSeverity.critical ? 1 : 0),
                0,
              ),
              child: content,
            );
          },
        ),
      );
    }
    
    return content;
  }

  Widget _buildContent() {
    return Semantics(
      label: '${_getSeverityLabel()}: ${widget.title}',
      hint: widget.message,
      liveRegion: widget.severity == ErrorSeverity.critical,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.screenPadding),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getAccentColor().withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.canDismiss) _buildDismissButton(),
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildMessage(),
            if (widget.details != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildDetails(),
            ],
            if (widget.primaryActionText != null || 
                widget.secondaryActionText != null) ...[
              const SizedBox(height: AppSpacing.sectionSpacing),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDismissButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: widget.onDismiss,
        icon: const Icon(
          Icons.close,
          color: AppColors.textSecondary,
          size: 20,
        ),
        tooltip: 'Dismiss',
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getAccentColor().withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon ?? _getDefaultIcon(),
            color: _getAccentColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            widget.title,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.message,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.6,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildDetails() {
    return ExpansionTile(
      title: Text(
        'Technical Details',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.details!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        if (widget.primaryActionText != null) ...[
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: widget.primaryActionText!,
              hint: 'Primary action button',
              button: true,
              child: ElevatedButton(
                onPressed: _handlePrimaryAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(),
                ),
                child: Text(
                  widget.primaryActionText!,
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (widget.secondaryActionText != null) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: widget.secondaryActionText!,
              hint: 'Secondary action button',
              button: true,
              child: TextButton(
                onPressed: _handleSecondaryAction,
                child: Text(
                  widget.secondaryActionText!,
                  style: AppTypography.buttonMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (widget.severity) {
      case ErrorSeverity.info:
        return AppColors.info.withOpacity(0.05);
      case ErrorSeverity.warning:
        return AppColors.warning.withOpacity(0.05);
      case ErrorSeverity.error:
        return AppColors.error.withOpacity(0.05);
      case ErrorSeverity.critical:
        return AppColors.error.withOpacity(0.1);
    }
  }

  Color _getAccentColor() {
    switch (widget.severity) {
      case ErrorSeverity.info:
        return AppColors.info;
      case ErrorSeverity.warning:
        return AppColors.warning;
      case ErrorSeverity.error:
      case ErrorSeverity.critical:
        return AppColors.error;
    }
  }

  IconData _getDefaultIcon() {
    switch (widget.severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }

  void _handlePrimaryAction() {
    HapticFeedback.lightImpact();
    widget.onPrimaryAction?.call();
  }

  void _handleSecondaryAction() {
    HapticFeedback.selectionClick();
    widget.onSecondaryAction?.call();
  }

  String _getSeverityLabel() {
    switch (widget.severity) {
      case ErrorSeverity.info:
        return 'Information';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }
}

/// Predefined error states for common scenarios
class ErrorStatePresets {
  static LoFiErrorState networkError({
    VoidCallback? onRetry,
  }) => LoFiErrorState(
    title: 'Connection Error',
    message: 'Unable to connect to the server. Please check your internet connection and try again.',
    icon: Icons.wifi_off_outlined,
    severity: ErrorSeverity.error,
    primaryActionText: 'Retry',
    onPrimaryAction: onRetry,
  );

  static LoFiErrorState serverError({
    VoidCallback? onRetry,
    VoidCallback? onContactSupport,
  }) => LoFiErrorState(
    title: 'Server Error',
    message: 'Something went wrong on our end. Our team has been notified and is working on a fix.',
    icon: Icons.cloud_off_outlined,
    severity: ErrorSeverity.error,
    primaryActionText: 'Try Again',
    onPrimaryAction: onRetry,
    secondaryActionText: 'Contact Support',
    onSecondaryAction: onContactSupport,
  );

  static LoFiErrorState validationError({
    required String message,
    VoidCallback? onFix,
  }) => LoFiErrorState(
    title: 'Invalid Input',
    message: message,
    icon: Icons.warning_amber_outlined,
    severity: ErrorSeverity.warning,
    primaryActionText: 'Fix Input',
    onPrimaryAction: onFix,
    canDismiss: true,
  );

  static LoFiErrorState permissionDenied({
    VoidCallback? onGrantPermission,
    VoidCallback? onSkip,
  }) => LoFiErrorState(
    title: 'Permission Required',
    message: 'This feature requires additional permissions to function properly.',
    icon: Icons.security_outlined,
    severity: ErrorSeverity.warning,
    primaryActionText: 'Grant Permission',
    onPrimaryAction: onGrantPermission,
    secondaryActionText: 'Skip for Now',
    onSecondaryAction: onSkip,
  );

  static LoFiErrorState maintenanceMode({
    VoidCallback? onCheckAgain,
  }) => LoFiErrorState(
    title: 'Under Maintenance',
    message: 'The app is temporarily unavailable for scheduled maintenance. Please try again shortly.',
    icon: Icons.build_outlined,
    severity: ErrorSeverity.info,
    primaryActionText: 'Check Again',
    onPrimaryAction: onCheckAgain,
  );
}