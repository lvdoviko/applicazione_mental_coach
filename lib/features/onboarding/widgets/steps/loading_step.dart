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
  final Future<void>? initializationFuture; // New parameter

  const LoadingStep({
    super.key,
    required this.onFinished,
    required this.userName,
    required this.coachName,
    this.initializationFuture,
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
    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_currentTextIndex < _loadingTexts.length - 1) {
        setState(() {
          _currentTextIndex++;
        });
      } else {
        timer.cancel();
        
        // Wait for initialization to complete if provided
        if (widget.initializationFuture != null) {
          await widget.initializationFuture;
        }
        
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), widget.onFinished);
        }
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
          // Large Logo
          SizedBox(
            height: 160, // Occupy less layout space
            child: OverflowBox(
              minHeight: 240,
              maxHeight: 240,
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md), // Reduced from xxl
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
          const SizedBox(height: 180), // Push content up visually (increased)
        ],
      ),
    );
  }
}
