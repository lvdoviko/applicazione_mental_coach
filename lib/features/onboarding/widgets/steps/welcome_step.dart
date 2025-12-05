import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const WelcomeStep({super.key, required this.onNext, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. SCROLLABLE CONTENT
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), // Bottom padding for button
            child: Column(
              children: [
                // NAVIGAZIONE (Singolo Tasto Back)
                Row(
                  children: [
                    if (onBack != null)
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                
                // const SizedBox(height: 20), // Removed to push content up

                // HERO LOGO
                Padding(
                  padding: const EdgeInsets.only(top: 30), // Restored top padding
                  child: SizedBox(
                    height: 180, // Occupy less layout space to pull text closer
                    child: OverflowBox(
                      minHeight: 280,
                      maxHeight: 280,
                      child: Image.asset(
                        'assets/icons/app_logo.png',
                        width: 280,
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8), // Significantly reduced spacing

                // TITOLO
                Text(
                  AppLocalizations.of(context)!.onboardingTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  AppLocalizations.of(context)!.onboardingSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 40),

                // FEATURE ICONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(Icons.chat_bubble_outline, AppLocalizations.of(context)!.welcomeFeature1),
                    _buildFeatureItem(Icons.favorite_border, AppLocalizations.of(context)!.welcomeFeature2),
                    _buildFeatureItem(Icons.lock_outline, AppLocalizations.of(context)!.welcomeFeature3),
                  ],
                ),
                
                // Extra space for scrolling content above fixed bottom area
                const SizedBox(height: 140), 
              ],
            ),
          ),
        ),

        // 2. FIXED BUTTON (Aligned with other steps at 70px)
        Positioned(
          left: 24,
          right: 24,
          bottom: 70, 
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNext();
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.getStarted,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. TERMS & PRIVACY (Below button)
        Positioned(
          left: 24,
          right: 24,
          bottom: 20,
          child: Text(
            AppLocalizations.of(context)!.welcomeTerms,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 1. Sfondo più luminoso (Vetro)
            color: Colors.white.withOpacity(0.08), 
            // 2. Bordo per definizione
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            // 3. Leggero Glow
            boxShadow: [
               BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 15)
            ]
          ),
          // 4. Icona Bianca (Per contrasto massimo)
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.white70, // Grigio chiaro per non competere col titolo
            height: 1.2
          ),
        ),
      ],
    );
  }
}
