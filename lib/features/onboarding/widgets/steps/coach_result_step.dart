import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class CoachResultStep extends StatelessWidget {
  final String assignedCoachId;
  final VoidCallback onStart;

  const CoachResultStep({
    super.key,
    required this.assignedCoachId,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final isAtlas = assignedCoachId == 'atlas';
    final coachName = isAtlas ? l10n.coachAtlas : l10n.coachSerena;
    final coachRole = isAtlas ? l10n.coachAtlasDesc : l10n.coachSerenaDesc;
    final imageUrl = isAtlas 
        ? 'https://models.readyplayer.me/6929b1e97b7a88e1f60a6f9e.png?bodyType=halfbody'
        : 'https://models.readyplayer.me/69286d45132e61458cee2d1f.png?bodyType=halfbody';
    final coachColor = isAtlas ? const Color(0xFF2962FF) : const Color(0xFF00E5FF);

    return Stack(
      children: [
        // 1. CONTENT
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        l10n.coachResultTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.coachResultSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // MATCHED CARD (Larger and Centered)
                      SizedBox(
                        height: 480,
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: PremiumGlassCard(
                            padding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                // Avatar Image
                                Positioned(
                                  top: 20,
                                  left: 0,
                                  right: 0,
                                  bottom: 120, 
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl, 
                                      fit: BoxFit.cover, 
                                      alignment: Alignment.topCenter,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(color: coachColor),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Info Overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 120,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          coachName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          coachRole,
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. FIXED BUTTON (Let's Start)
        Positioned(
          left: 24,
          right: 24,
          bottom: 50,
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
                  onStart();
                },
                child: Center(
                  child: Text(
                    l10n.letsStart,
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
}
