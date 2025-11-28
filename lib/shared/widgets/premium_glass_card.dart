import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const PremiumGlassCard({
    Key? key,
    required this.child,
    this.height,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // Bordi molto arrotondati
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur dello sfondo
          child: Container(
            height: height,
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Gradiente vetro scuro (dall'alto a sinistra al basso a destra)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1C2541).withOpacity(0.6), // Blu notte trasparente
                  const Color(0xFF000000).withOpacity(0.8), // Nero trasparente
                ],
              ),
              // Bordo di luce sottile
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.1), // Leggero bagliore blu
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
