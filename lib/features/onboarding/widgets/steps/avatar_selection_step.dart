import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class AvatarSelectionStep extends StatelessWidget {
  final String? selectedAvatarId;
  final Function(String) onAvatarSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AvatarSelectionStep({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // 1. CONTENT
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), // Bottom padding for button
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // 1. Align to top
              children: [
                // 2. Fixed Top Spacing (Increased for header clearance)
                const SizedBox(height: 60),

                Text(
                  l10n.avatarSelectionTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.avatarSelectionSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                
                const SizedBox(height: 20), // Reduced spacing

                // AVATAR CARDS
                SizedBox(
                  height: 450, // Maximized height
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAvatarCard(
                        id: 'atlas',
                        name: l10n.coachAtlas,
                        role: l10n.coachAtlasDesc,
                        imageUrl: 'https://models.readyplayer.me/6929b1e97b7a88e1f60a6f9e.png?bodyType=halfbody',
                        color: const Color(0xFF2962FF),
                        isSelected: selectedAvatarId == 'atlas',
                        onTap: () => onAvatarSelected('atlas'),
                      ),
                      const SizedBox(width: 16),
                      _buildAvatarCard(
                        id: 'serena',
                        name: l10n.coachSerena,
                        role: l10n.coachSerenaDesc,
                        imageUrl: 'https://models.readyplayer.me/69286d45132e61458cee2d1f.png?bodyType=halfbody',
                        color: const Color(0xFF00E5FF),
                        isSelected: selectedAvatarId == 'serena',
                        onTap: () => onAvatarSelected('serena'),
                      ),
                    ],
                  ),
                ),

                // 3. Safety Spacing at Bottom
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        
        // 2. BACK BUTTON (Global Position)
        Positioned(
          top: 0,
          left: 24,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
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
            ),
          ),
        ),

        // 3. FIXED BUTTON
        Positioned(
          left: 24,
          right: 24,
          bottom: 70, // Aligned with WelcomeStep
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
                onTap: selectedAvatarId != null 
                  ? () {
                      HapticFeedback.lightImpact();
                      onNext();
                    } 
                  : null,
                child: Center(
                  child: Text(
                    l10n.startJourney,
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

  Widget _buildAvatarCard({
    required String id,
    required String name,
    required String role,
    required String imageUrl,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 160, // Fixed width for the card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: PremiumGlassCard(
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Avatar Image
              Positioned(
                top: 15,
                left: 0,
                right: 0,
                bottom: 100, // Leave space for text
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Hero(
                    tag: isSelected ? 'coach_avatar' : 'avatar_$id', // Only hero the selected one
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: color,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 64,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Info
              Positioned(
                bottom: 24,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      role,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white70,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
