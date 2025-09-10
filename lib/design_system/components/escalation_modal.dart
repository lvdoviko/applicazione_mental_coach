import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

enum EscalationReason {
  needsHumanSupport,
  emergencySupport,
  technicalIssue,
  feedbackComplaint,
  generalInquiry,
}

class EscalationRequest {
  final EscalationReason reason;
  final String message;
  final String? urgencyLevel;
  final Map<String, dynamic>? context;

  const EscalationRequest({
    required this.reason,
    required this.message,
    this.urgencyLevel,
    this.context,
  });
}

class EscalationModal extends StatefulWidget {
  const EscalationModal({
    super.key,
    required this.onSubmit,
    this.initialReason = EscalationReason.needsHumanSupport,
    this.chatContext,
  });

  final Function(EscalationRequest request) onSubmit;
  final EscalationReason initialReason;
  final Map<String, dynamic>? chatContext;

  @override
  State<EscalationModal> createState() => _EscalationModalState();
}

class _EscalationModalState extends State<EscalationModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  EscalationReason _selectedReason = EscalationReason.needsHumanSupport;
  String? _selectedUrgency;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.initialReason;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmGold.withOpacity(0.1),
            AppColors.warmTerracotta.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warmGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent,
              color: AppColors.warmGold,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connect with Human Support',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'We\'re here to help you personally',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReasonSelector(),
          const SizedBox(height: AppSpacing.lg),
          if (_selectedReason == EscalationReason.emergencySupport)
            _buildUrgencySelector(),
          if (_selectedReason == EscalationReason.emergencySupport)
            const SizedBox(height: AppSpacing.lg),
          _buildMessageField(),
          if (_selectedReason == EscalationReason.emergencySupport)
            _buildEmergencyNote(),
        ],
      ),
    );
  }

  Widget _buildReasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you need help with?',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        ...EscalationReason.values.map(
          (reason) => RadioListTile<EscalationReason>(
            title: Text(
              _getReasonTitle(reason),
              style: AppTypography.bodyMedium,
            ),
            subtitle: Text(
              _getReasonDescription(reason),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedReason = value);
              }
            },
            activeColor: AppColors.warmTerracotta,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    final urgencyLevels = ['Low', 'Medium', 'High', 'Critical'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urgency Level',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: urgencyLevels.map((urgency) {
            final isSelected = _selectedUrgency == urgency;
            final color = _getUrgencyColor(urgency);
            
            return ChoiceChip(
              label: Text(urgency),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedUrgency = urgency);
                }
              },
              selectedColor: color.withOpacity(0.2),
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? AppTypography.medium : null,
              ),
              side: BorderSide(
                color: isSelected ? color : AppColors.grey300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _messageController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Please describe your situation or question...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.warmTerracotta, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyNote() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'If this is a mental health emergency, please contact emergency services immediately.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                  : const Text('Request Support'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide additional details'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = EscalationRequest(
      reason: _selectedReason,
      message: _messageController.text.trim(),
      urgencyLevel: _selectedUrgency,
      context: widget.chatContext,
    );

    try {
      await widget.onSubmit(request);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Support request submitted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getReasonTitle(EscalationReason reason) {
    switch (reason) {
      case EscalationReason.needsHumanSupport:
        return 'Need Human Coach';
      case EscalationReason.emergencySupport:
        return 'Emergency Support';
      case EscalationReason.technicalIssue:
        return 'Technical Issue';
      case EscalationReason.feedbackComplaint:
        return 'Feedback/Complaint';
      case EscalationReason.generalInquiry:
        return 'General Question';
    }
  }

  String _getReasonDescription(EscalationReason reason) {
    switch (reason) {
      case EscalationReason.needsHumanSupport:
        return 'Connect with a qualified human coach';
      case EscalationReason.emergencySupport:
        return 'Urgent mental health support needed';
      case EscalationReason.technicalIssue:
        return 'App functionality problems';
      case EscalationReason.feedbackComplaint:
        return 'Share feedback or report issues';
      case EscalationReason.generalInquiry:
        return 'Other questions or concerns';
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }
}