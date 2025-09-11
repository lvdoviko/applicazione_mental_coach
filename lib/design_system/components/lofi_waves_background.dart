import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

/// **Lo-Fi Waves Background Component**
/// 
/// **Functional Description:**
/// Gentle, flowing wave animation with lo-fi pastello colors that creates
/// a calming and minimalist visual effect perfect for onboarding screens.
/// 
/// **Visual Specifications:**
/// - 3-4 overlapping sinusoidal waves with different frequencies
/// - Colors: primary (#7DAEA9), secondary (#E6D9F2), accent (#D4C4E8)
/// - Very low opacity (0.05-0.15) to maintain minimal aesthetic
/// - Smooth 6-8 second animation cycles with custom easing
/// - Paper texture background (#FBF9F8) as base
/// 
/// **Performance:**
/// - CustomPainter with optimized rendering
/// - RepaintBoundary for isolation
/// - Automatic pause when app backgrounded
/// - 60fps smooth animations
/// 
/// **Accessibility:**
/// - Respects reduce motion preferences
/// - No accessibility barriers
/// - Purely decorative element
class LoFiWavesBackground extends StatefulWidget {
  const LoFiWavesBackground({
    super.key,
    this.child,
    this.animationDuration = const Duration(seconds: 20),
    this.waves = 6,
    this.respectMotionPreference = true,
  });

  final Widget? child;
  final Duration animationDuration;
  final int waves;
  final bool respectMotionPreference;

  @override
  State<LoFiWavesBackground> createState() => _LoFiWavesBackgroundState();
}

class _LoFiWavesBackgroundState extends State<LoFiWavesBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  bool _shouldAnimate = true;

  @override
  void initState() {
    super.initState();
    _checkMotionPreference();
    _setupAnimation();
  }

  void _checkMotionPreference() {
    if (widget.respectMotionPreference) {
      // Check if user prefers reduced motion
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      _shouldAnimate = !platformDispatcher.accessibilityFeatures.reduceMotion;
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Custom smooth easing curve for fluid wave motion
    _waveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const InfiniteWaveCurve(),
    );

    if (_shouldAnimate) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // Paper texture base
      child: _shouldAnimate
          ? AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: LoFiWavesPainter(
                      animationValue: _waveAnimation.value,
                      waves: widget.waves,
                    ),
                    child: widget.child,
                  ),
                );
              },
            )
          : widget.child,
    );
  }
}

/// Custom curve that creates smooth, linear infinite wave motion
class InfiniteWaveCurve extends Curve {
  const InfiniteWaveCurve();

  @override
  double transformInternal(double t) {
    // Linear progression for continuous movement
    return t;
  }
}

/// Custom painter that renders the lo-fi waves
class LoFiWavesPainter extends CustomPainter {
  LoFiWavesPainter({
    required this.animationValue,
    required this.waves,
  });

  final double animationValue;
  final int waves;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Define wave parameters for each wave layer
    final waveConfigs = [
      // Wave 1 - Primary teal, deepest and largest
      WaveConfig(
        color: AppColors.primary.withOpacity(0.15),
        amplitude: 100.0,
        frequency: 0.7,
        phase: animationValue * 4 * math.pi, // Slower continuous movement
        yOffset: size.height * 0.8,
      ),
      // Wave 2 - Secondary lavender, large middle layer  
      WaveConfig(
        color: AppColors.secondary.withOpacity(0.12),
        amplitude: 85.0,
        frequency: 0.9,
        phase: (animationValue * 4 * math.pi) + (math.pi / 4),
        yOffset: size.height * 0.68,
      ),
      // Wave 3 - Accent purple, prominent layer
      WaveConfig(
        color: AppColors.accent.withOpacity(0.10),
        amplitude: 70.0,
        frequency: 1.1,
        phase: (animationValue * 4 * math.pi) + (math.pi / 2),
        yOffset: size.height * 0.55,
      ),
      // Wave 4 - Teal wave reaching feature section
      WaveConfig(
        color: AppColors.primary.withOpacity(0.08),
        amplitude: 55.0,
        frequency: 1.3,
        phase: (animationValue * 4 * math.pi) + (3 * math.pi / 4),
        yOffset: size.height * 0.40,
      ),
      // Wave 5 - Covering Personal Conversations area
      WaveConfig(
        color: AppColors.secondary.withOpacity(0.06),
        amplitude: 45.0,
        frequency: 1.5,
        phase: (animationValue * 4 * math.pi) + (math.pi),
        yOffset: size.height * 0.25,
      ),
      // Wave 6 - Higher Personal Conversations coverage
      WaveConfig(
        color: AppColors.accent.withOpacity(0.05),
        amplitude: 35.0,
        frequency: 1.7,
        phase: (animationValue * 4 * math.pi) + (5 * math.pi / 4),
        yOffset: size.height * 0.12,
      ),
      // Wave 7 - Extra top layer reaching upper content
      WaveConfig(
        color: AppColors.primary.withOpacity(0.03),
        amplitude: 25.0,
        frequency: 2.0,
        phase: (animationValue * 4 * math.pi) + (3 * math.pi / 2),
        yOffset: size.height * 0.05,
      ),
    ];

    // Draw waves from back to front for proper layering
    for (int i = waveConfigs.length - 1; i >= 0; i--) {
      _drawWave(canvas, size, paint, waveConfigs[i]);
    }
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, WaveConfig config) {
    paint.color = config.color;
    
    final path = Path();
    final waveHeight = size.height - config.yOffset;
    
    // Start path from left edge
    path.moveTo(0, size.height);
    path.lineTo(0, config.yOffset + waveHeight);

    // Generate wave points
    final steps = (size.width / 4).ceil(); // Smooth curve resolution
    for (int i = 0; i <= steps; i++) {
      final x = (i / steps) * size.width;
      final waveValue = math.sin((x * config.frequency / size.width * 2 * math.pi) + config.phase);
      final y = config.yOffset + (waveValue * config.amplitude) + waveHeight;
      
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        // Use smooth curves for fluid motion
        final prevX = ((i - 1) / steps) * size.width;
        final controlPointOffset = (x - prevX) / 2;
        path.quadraticBezierTo(
          prevX + controlPointOffset,
          y,
          x,
          y,
        );
      }
    }

    // Close path to fill bottom area
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LoFiWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Configuration for individual wave properties
class WaveConfig {
  const WaveConfig({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.yOffset,
  });

  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;
  final double yOffset;
}