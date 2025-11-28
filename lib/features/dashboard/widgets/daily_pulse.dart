import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';

class DailyPulse extends StatefulWidget {
  final ValueChanged<double> onMoodChanged;

  const DailyPulse({super.key, required this.onMoodChanged});

  @override
  State<DailyPulse> createState() => _DailyPulseState();
}

class _DailyPulseState extends State<DailyPulse> {
  double _currentValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Pulse',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('😔', style: TextStyle(fontSize: 24)),
              Text('😐', style: TextStyle(fontSize: 24)),
              Text('⚡️', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: Colors.transparent, // Use transparent to show gradient
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.1),
              thumbShape: _GlowThumbShape(),
              trackShape: _GradientTrackShape(),
            ),
            child: Slider(
              value: _currentValue,
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onMoodChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const _GlowThumbShape({this.thumbRadius = 14.0}); // Increased size

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Glow
    final Paint glowPaint = Paint()
      ..color = _getColorForValue(value).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15); // Increased blur
    canvas.drawCircle(center, thumbRadius + 8, glowPaint); // Increased glow radius

    // Thumb
    final Paint thumbPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, thumbRadius, thumbPaint);
  }

  Color _getColorForValue(double value) {
    // Gradient from Yellow (sad) to Red/Orange (charged)
    return Color.lerp(Colors.yellow, Colors.redAccent, value) ?? Colors.orange;
  }
}

class _GradientTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.yellow, Colors.redAccent],
      ).createShader(trackRect);

    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    final Paint activeTrackPaint = activePaint;
    final Paint inactiveTrackPaint = inactivePaint;

    final Canvas canvas = context.canvas;

    // Draw inactive track
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(4)),
      inactiveTrackPaint,
    );

    // Draw active track
    final Rect activeTrackRect = Rect.fromLTWH(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx - trackRect.left,
      trackRect.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, const Radius.circular(4)),
      activeTrackPaint,
    );
  }
}
