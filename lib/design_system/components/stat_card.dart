import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

enum StatCardVariant { primary, secondary, success, warning, info }

class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trend,
    this.trendValue,
    this.variant = StatCardVariant.primary,
    this.onTap,
    this.sparklineData,
    this.isLoading = false,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final StatTrend? trend;
  final String? trendValue;
  final StatCardVariant variant;
  final VoidCallback? onTap;
  final List<double>? sparklineData;
  final bool isLoading;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.title}: ${widget.value}',
      button: widget.onTap != null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: _getBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBorderColor(context),
                  width: 1,
                ),
              ),
              child: widget.isLoading
                  ? _buildLoadingState()
                  : _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getAccentColor(),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: _getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trend != null && widget.trendValue != null)
              _buildTrendIndicator(),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.value,
          style: AppTypography.h2.copyWith(
            color: _getTextPrimaryColor(context),
            fontWeight: AppTypography.bold,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.subtitle!,
            style: AppTypography.bodySmall.copyWith(
              color: _getTextSecondaryColor(context),
            ),
          ),
        ],
        if (widget.sparklineData != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildSparkline(),
        ],
      ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildShimmer(height: 16, width: 120),
        const SizedBox(height: AppSpacing.sm),
        _buildShimmer(height: 24, width: 80),
        const SizedBox(height: AppSpacing.xs),
        _buildShimmer(height: 12, width: 100),
      ],
    );
  }

  Widget _buildShimmer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = widget.trend == StatTrend.up;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            widget.trendValue!,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: AppTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkline() {
    if (widget.sparklineData == null || widget.sparklineData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: SparklinePainter(
          data: widget.sparklineData!,
          color: _getAccentColor(),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? AppColors.darkSurface : AppColors.white;
  }

  Color _getBorderColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? AppColors.grey700 : AppColors.grey200;
  }

  Color _getTextPrimaryColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? AppColors.darkTextSecondary : AppColors.grey600;
  }

  Color _getAccentColor() {
    switch (widget.variant) {
      case StatCardVariant.primary:
        return AppColors.primary;
      case StatCardVariant.secondary:
        return AppColors.secondary;
      case StatCardVariant.success:
        return AppColors.success;
      case StatCardVariant.warning:
        return AppColors.warning;
      case StatCardVariant.info:
        return AppColors.info;
    }
  }
}

enum StatTrend { up, down, neutral }

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - minValue) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Add gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return data != oldDelegate.data || color != oldDelegate.color;
  }
}