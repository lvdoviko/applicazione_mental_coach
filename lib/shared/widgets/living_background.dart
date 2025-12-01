import 'dart:async';
import 'dart:ui';
import 'dart:math' as Math;
import 'package:flutter/material.dart';

class LivingBackground extends StatefulWidget {
  const LivingBackground({super.key});

  @override
  State<LivingBackground> createState() => _LivingBackgroundState();
}

class _LivingBackgroundState extends State<LivingBackground> with TickerProviderStateMixin {
  // Parametri per animare le posizioni delle "luci"
  late AnimationController _controller;
  
  // Variabili per l'animazione di respiro (Scale)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Controller per la rotazione lenta
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Molto lento (Calm)
      vsync: this,
    )..repeat(); // Loop infinito

    // Controller per il respiro (Pulsazione)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colori del Brand
    final color1 = const Color(0xFF4A90E2); // Blu Elettrico (Brand)
    final color2 = const Color(0xFF1C2541); // Blu Notte
    final color3 = const Color(0xFF0D1322); // Scuro profondo (Sfondo base)

    return Stack(
      children: [
        // 1. Sfondo Base (Blu Scurissimo, non nero piatto)
        Container(color: color3),

        // 2. Luce 1 (Blu Brand) - ENORME
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.2 + (50 * Math.sin(_controller.value * 2 * Math.pi)),
              left: MediaQuery.of(context).size.width * 0.1 + (30 * Math.cos(_controller.value * 2 * Math.pi)),
              child: child!,
            );
          },
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 500, // Molto grande
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color1.withOpacity(0.4),
              ),
            ),
          ),
        ),

        // 3. Luce 2 (Blu Notte) - ENORME e opposta
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1 + (60 * Math.cos(_controller.value * 2 * Math.pi)),
              right: -100 + (40 * Math.sin(_controller.value * 2 * Math.pi)),
              child: child!,
            );
          },
          child: Container(
            width: 600, // Ancora più grande
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color2.withOpacity(0.6),
            ),
          ),
        ),

        // 4. IL SEGRETO: Blur Estremo (Mesh Effect)
        // Questo fonde le palle di colore in un'aurora liquida
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0), // Blur altissimo
            child: Container(
              color: Colors.transparent, // Necessario per il filtro
            ),
          ),
        ),
        
        // 5. Velo scuro per leggibilità (Opzionale, leggero)
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }
}
