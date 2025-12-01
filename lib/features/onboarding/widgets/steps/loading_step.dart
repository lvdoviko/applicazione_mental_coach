import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class LoadingStep extends StatefulWidget {
  final VoidCallback onFinished;
  final String userName;
  final String coachName;

  const LoadingStep({
    super.key,
    required this.onFinished,
    required this.userName,
    required this.coachName,
  });

  @override
  State<LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<LoadingStep> {
  int _currentTextIndex = 0;
  late List<String> _loadingTexts;
  Timer? _textTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _loadingTexts = [
      l10n.loadingConfiguring(widget.coachName),
      l10n.loadingCalibrating(widget.userName),
      l10n.loadingReady
    ];
    if (_textTimer == null) {
      _startLoadingSequence();
    }
  }

  @override
  void initState() {
    super.initState();
    // Moved initialization to didChangeDependencies to access context for l10n
  }

  void _startLoadingSequence() {
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentTextIndex < _loadingTexts.length - 1) {
        setState(() {
          _currentTextIndex++;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), widget.onFinished);
      }
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsating Logo Effect
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5),
                        blurRadius: 20 * value,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
            onEnd: () {}, // Loop handled by parent if needed, but simple tween is fine for now or use AnimationController for continuous loop
          ),
          const SizedBox(height: AppSpacing.xxl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingTexts[_currentTextIndex],
              key: ValueKey<int>(_currentTextIndex),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
