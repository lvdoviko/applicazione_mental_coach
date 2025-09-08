import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

enum AvatarStyle { modern, classic, sport, minimal }
enum AvatarExpression { neutral, happy, focused, determined }

class AvatarConfig {
  final AvatarStyle style;
  final AvatarExpression expression;
  final Color primaryColor;
  final Color secondaryColor;
  final String? accessory;

  const AvatarConfig({
    required this.style,
    required this.expression,
    required this.primaryColor,
    required this.secondaryColor,
    this.accessory,
  });

  AvatarConfig copyWith({
    AvatarStyle? style,
    AvatarExpression? expression,
    Color? primaryColor,
    Color? secondaryColor,
    String? accessory,
  }) {
    return AvatarConfig(
      style: style ?? this.style,
      expression: expression ?? this.expression,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accessory: accessory ?? this.accessory,
    );
  }
}

class AvatarCustomizer extends StatefulWidget {
  const AvatarCustomizer({
    super.key,
    required this.onConfigChanged,
    this.initialConfig = const AvatarConfig(
      style: AvatarStyle.modern,
      expression: AvatarExpression.neutral,
      primaryColor: AppColors.deepTeal,
      secondaryColor: AppColors.softBlue,
    ),
    this.showPreview = true,
    this.compactMode = false,
  });

  final Function(AvatarConfig config) onConfigChanged;
  final AvatarConfig initialConfig;
  final bool showPreview;
  final bool compactMode;

  @override
  State<AvatarCustomizer> createState() => _AvatarCustomizerState();
}

class _AvatarCustomizerState extends State<AvatarCustomizer>
    with SingleTickerProviderStateMixin {
  late AvatarConfig _currentConfig;
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _previewAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.elasticOut,
    ));

    _previewController.forward();
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _updateConfig(AvatarConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
    });
    widget.onConfigChanged(newConfig);
    
    // Trigger preview animation
    _previewController.reset();
    _previewController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Avatar customization options',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showPreview) ...[
            _buildPreview(),
            const SizedBox(height: AppSpacing.xxl),
          ],
          _buildStyleSelector(),
          const SizedBox(height: AppSpacing.xl),
          _buildExpressionSelector(),
          const SizedBox(height: AppSpacing.xl),
          _buildColorSelector(),
          if (!widget.compactMode) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildAccessorySelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: AnimatedBuilder(
        animation: _previewAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _previewAnimation.value,
            child: AvatarPreview(config: _currentConfig, size: 120),
          );
        },
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avatar Style',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: AvatarStyle.values.map((style) {
            final isSelected = _currentConfig.style == style;
            return ChoiceChip(
              label: Text(_getStyleName(style)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _updateConfig(_currentConfig.copyWith(style: style));
                }
              },
              selectedColor: AppColors.deepTeal.withOpacity(0.2),
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.deepTeal : null,
                fontWeight: isSelected ? AppTypography.medium : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpressionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expression',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: AvatarExpression.values.map((expression) {
            final isSelected = _currentConfig.expression == expression;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getExpressionIcon(expression)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(_getExpressionName(expression)),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _updateConfig(_currentConfig.copyWith(expression: expression));
                }
              },
              selectedColor: AppColors.softBlue.withOpacity(0.2),
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.softBlue : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colors',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildColorPalette(
                    AppColors.avatarColors,
                    _currentConfig.primaryColor,
                    (color) => _updateConfig(
                      _currentConfig.copyWith(primaryColor: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accent',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildColorPalette(
                    AppColors.avatarColors,
                    _currentConfig.secondaryColor,
                    (color) => _updateConfig(
                      _currentConfig.copyWith(secondaryColor: color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPalette(
    List<Color> colors,
    Color selectedColor,
    Function(Color) onColorSelected,
  ) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.textPrimary, width: 3)
                  : Border.all(color: AppColors.grey200, width: 1),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 16,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessorySelector() {
    final accessories = ['none', 'cap', 'headband', 'glasses'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessories',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          children: accessories.map((accessory) {
            final isSelected = _currentConfig.accessory == accessory;
            final isNone = accessory == 'none';
            
            return ChoiceChip(
              label: Text(isNone ? 'None' : _capitalizeFirst(accessory)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _updateConfig(_currentConfig.copyWith(
                    accessory: isNone ? null : accessory,
                  ));
                }
              },
              selectedColor: AppColors.orange.withOpacity(0.2),
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.orange : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getStyleName(AvatarStyle style) {
    switch (style) {
      case AvatarStyle.modern:
        return 'Modern';
      case AvatarStyle.classic:
        return 'Classic';
      case AvatarStyle.sport:
        return 'Athletic';
      case AvatarStyle.minimal:
        return 'Minimal';
    }
  }

  String _getExpressionName(AvatarExpression expression) {
    switch (expression) {
      case AvatarExpression.neutral:
        return 'Neutral';
      case AvatarExpression.happy:
        return 'Happy';
      case AvatarExpression.focused:
        return 'Focused';
      case AvatarExpression.determined:
        return 'Determined';
    }
  }

  String _getExpressionIcon(AvatarExpression expression) {
    switch (expression) {
      case AvatarExpression.neutral:
        return '😐';
      case AvatarExpression.happy:
        return '😊';
      case AvatarExpression.focused:
        return '🤔';
      case AvatarExpression.determined:
        return '💪';
    }
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

// Avatar Preview Widget (placeholder for actual implementation)
class AvatarPreview extends StatelessWidget {
  const AvatarPreview({
    super.key,
    required this.config,
    this.size = 80,
  });

  final AvatarConfig config;
  final double size;

  @override
  Widget build(BuildContext context) {
    // This would be replaced with actual avatar rendering logic
    // For now, showing a simplified representation
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.primaryColor,
            config.secondaryColor,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getExpressionIcon(),
          style: TextStyle(fontSize: size * 0.4),
        ),
      ),
    );
  }

  String _getExpressionIcon() {
    switch (config.expression) {
      case AvatarExpression.neutral:
        return '😐';
      case AvatarExpression.happy:
        return '😊';
      case AvatarExpression.focused:
        return '🤔';
      case AvatarExpression.determined:
        return '💪';
    }
  }
}