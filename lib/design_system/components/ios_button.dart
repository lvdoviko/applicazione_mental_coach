import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';

enum IOSButtonStyle { primary, secondary, tertiary }
enum IOSButtonSize { small, medium, large }

class IOSButton extends StatefulWidget {
  const IOSButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = IOSButtonStyle.primary,
    this.size = IOSButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final IOSButtonStyle style;
  final IOSButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? width;

  @override
  State<IOSButton> createState() => _IOSButtonState();
}

class _IOSButtonState extends State<IOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: _getHeight(),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                border: _getBorder(),
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: _getPadding(),
                  child: widget.isLoading
                      ? _buildLoadingIndicator()
                      : _buildContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _getTextColor(),
            size: _getIconSize(),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: _getTextStyle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  bool get _isEnabled => widget.isEnabled && widget.onPressed != null && !widget.isLoading;

  Color _getBackgroundColor() {
    if (!_isEnabled) {
      return AppColors.grey300;
    }

    switch (widget.style) {
      case IOSButtonStyle.primary:
        return _isPressed 
          ? AppColors.warmTerracotta.withValues(alpha: 0.8)
          : AppColors.warmTerracotta;
      case IOSButtonStyle.secondary:
        return _isPressed 
          ? AppColors.grey200
          : AppColors.grey100;
      case IOSButtonStyle.tertiary:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (!_isEnabled) {
      return AppColors.grey500;
    }

    switch (widget.style) {
      case IOSButtonStyle.primary:
        return AppColors.white;
      case IOSButtonStyle.secondary:
        return AppColors.warmTerracotta;
      case IOSButtonStyle.tertiary:
        return AppColors.warmTerracotta;
    }
  }

  Border? _getBorder() {
    if (widget.style == IOSButtonStyle.tertiary) {
      return Border.all(
        color: _isEnabled ? AppColors.warmTerracotta : AppColors.grey300,
        width: 1.5,
      );
    }
    return null;
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 12;
      case IOSButtonSize.medium:
        return 16;
      case IOSButtonSize.large:
        return 20;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 40;
      case IOSButtonSize.medium:
        return 48;
      case IOSButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return 16;
      case IOSButtonSize.medium:
        return 18;
      case IOSButtonSize.large:
        return 20;
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case IOSButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case IOSButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case IOSButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = switch (widget.size) {
      IOSButtonSize.small => AppTypography.bodyMedium,
      IOSButtonSize.medium => AppTypography.callout,
      IOSButtonSize.large => AppTypography.bodyLarge,
    };

    return baseStyle.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }
}