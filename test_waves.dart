import 'package:flutter/material.dart';
import 'package:applicazione_mental_coach/design_system/components/lofi_waves_background.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';

void main() {
  runApp(const WavesTestApp());
}

class WavesTestApp extends StatelessWidget {
  const WavesTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waves Test',
      home: Scaffold(
        body: LoFiWavesBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'KAIX',
                  style: AppTypography.largeTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Lo-Fi Waves Test',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Inizia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}