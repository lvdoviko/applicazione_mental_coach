import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class UserDetailsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const UserDetailsStep({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.userDetailsTitle,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.userDetailsSubtitle,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Section (Clean Glass Input)
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05), // Sfondo quasi trasparente
                      borderRadius: BorderRadius.circular(16),
                      // Bordo sottile bianco (NON BLU)
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1), 
                    ),
                    child: Center(
                      child: TextField(
                        controller: nameController,
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
                        cursorColor: const Color(0xFF4A90E2), // Solo il cursore è blu
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.white60),
                          hintText: l10n.nameLabel,
                          hintStyle: GoogleFonts.nunito(color: Colors.white30),
                          
                        // RIMUOVE TUTTI I BORDI NATIVI
                        border: InputBorder.none, 
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        
                        // FIX: Remove ghost background
                        filled: false, 
                        fillColor: Colors.transparent,
                        
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: AppSpacing.xl),

                  // Gender Section
                  _buildSectionLabel(l10n.genderLabel.toUpperCase()),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: _buildGenderPill(context, 'male', l10n.genderMale, Icons.male)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildGenderPill(context, 'female', l10n.genderFemale, Icons.female)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildGenderPill(context, 'other', l10n.genderOther, Icons.wc)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Age Section
                  const SizedBox(height: 24), // Added breathing room
                  _buildSectionLabel(l10n.yourAgeLabel),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    height: 180, // Increased height for larger items
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: CupertinoPicker(
                      itemExtent: 60, // Increased to avoid cutting numbers
                      magnification: 1.2,
                      useMagnifier: true,
                      backgroundColor: Colors.transparent, // Ensure transparency
                      scrollController: FixedExtentScrollController(initialItem: 0),
                      onSelectedItemChanged: (index) {
                        ageController.text = (index + 10).toString();
                      },
                      selectionOverlay: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: const Color(0xFF4A90E2).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      children: List.generate(90, (index) {
                        return Center(
                          child: Text(
                            "${index + 10}",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 24, // Increased font size
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full Width Next Button (Bottom)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0, // Shadow handled by Container
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  l10n.continueButton,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGenderPill(BuildContext context, String value, String label, IconData icon) {
    final isSelected = selectedGender == value;
    return GestureDetector(
      onTap: () => onGenderChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          // SFONDO: Se selezionato, Blu al 20%. Se no, Bianco al 5%.
          color: isSelected 
              ? const Color(0xFF4A90E2).withOpacity(0.20) 
              : Colors.white.withOpacity(0.05),
          
          borderRadius: BorderRadius.circular(16),
          
          // BORDO: Se selezionato, Blu Pieno (2px). Se no, Bianco Sottile (1px).
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4A90E2) 
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          
          // GLOW: Solo se selezionato
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              // Icona bianca se selezionata, altrimenti un po' spenta
              color: isSelected ? Colors.white : Colors.white70, 
              size: 24
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
