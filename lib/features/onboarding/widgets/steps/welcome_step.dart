import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';

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
                
                const SizedBox(height: 40),

                // TITOLO
                Text(
                  "Il Tuo Coach AI\nPersonale",
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
                  "Supportiamo il tuo percorso di benessere mentale con empatia e comprensione.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 60),

                // FEATURE ICONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(Icons.chat_bubble_outline, "Conversazioni\nsu Misura"),
                    _buildFeatureItem(Icons.favorite_border, "Supporto\nH24"),
                    _buildFeatureItem(Icons.lock_outline, "Privacy\nTotale"),
                  ],
                ),

                const SizedBox(height: 40),

                // TERMS & PRIVACY (Inside ScrollView)
                Text(
                  "Continuando accetti i Termini di Servizio\ne la Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. FIXED BUTTON (Bottom Anchor)
        Positioned(
          left: 24,
          right: 24,
          bottom: 40,
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
                onTap: onNext,
                child: Center(
                  child: Text(
                    "Inizia",
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
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05), 
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
            boxShadow: [
               BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10)
            ]
          ),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.white70,
            height: 1.2
          ),
        ),
      ],
    );
  }
}
