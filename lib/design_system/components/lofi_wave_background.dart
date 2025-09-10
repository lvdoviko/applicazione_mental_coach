import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

class LofiWaveBackground extends StatefulWidget {
  const LofiWaveBackground({super.key});

  @override
  State<LofiWaveBackground> createState() => _LofiWaveBackgroundState();
}

class _LofiWaveBackgroundState extends State<LofiWaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;
  late AnimationController _wave3Controller;
  late AnimationController _wave4Controller;

  @override
  void initState() {
    super.initState();
    
    // Create animation controllers with different durations for organic movement
    _wave1Controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _wave2Controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    
    _wave3Controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _wave4Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _wave3Controller.dispose();
    _wave4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.warmPeach.withValues(alpha: 0.1),
                AppColors.warmGold.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        
        // Wave layers - back to front
        AnimatedBuilder(
          animation: _wave4Controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                animationValue: _wave4Controller.value,
                color: AppColors.warmYellow.withValues(alpha: 0.08),
                amplitude: 30,
                frequency: 0.8,
                phase: 0,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _wave3Controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                animationValue: _wave3Controller.value,
                color: AppColors.warmCoral.withValues(alpha: 0.12),
                amplitude: 25,
                frequency: 1.2,
                phase: math.pi / 3,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _wave2Controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                animationValue: _wave2Controller.value,
                color: AppColors.warmTerracotta.withValues(alpha: 0.1),
                amplitude: 35,
                frequency: 0.6,
                phase: math.pi / 2,
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _wave1Controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: WavePainter(
                animationValue: _wave1Controller.value,
                color: AppColors.warmGold.withValues(alpha: 0.15),
                amplitude: 20,
                frequency: 1.5,
                phase: math.pi,
              ),
            );
          },
        ),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double amplitude;
  final double frequency;
  final double phase;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Create multiple wave layers for more organic look
    for (int i = 0; i < 3; i++) {
      final layerPath = Path();
      final waveHeight = size.height * (0.3 + (i * 0.2));
      final layerAmplitude = amplitude * (1 - i * 0.3);
      final timeOffset = animationValue * 2 * math.pi + phase + (i * math.pi / 4);
      
      layerPath.moveTo(0, waveHeight);
      
      for (double x = 0; x <= size.width; x += 2) {
        final normalizedX = x / size.width;
        final wave1 = math.sin(normalizedX * frequency * 2 * math.pi + timeOffset) * layerAmplitude;
        final wave2 = math.sin(normalizedX * frequency * 4 * math.pi + timeOffset * 1.5) * (layerAmplitude * 0.5);
        final wave3 = math.sin(normalizedX * frequency * 6 * math.pi + timeOffset * 0.7) * (layerAmplitude * 0.3);
        
        final y = waveHeight + wave1 + wave2 + wave3;
        layerPath.lineTo(x, y);
      }
      
      layerPath.lineTo(size.width, size.height);
      layerPath.lineTo(0, size.height);
      layerPath.close();
      
      canvas.drawPath(layerPath, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}