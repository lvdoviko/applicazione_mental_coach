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
                  // Removed label "COME TI CHIAMI?" as requested
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: l10n.nameLabel,
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                  _buildSectionLabel(l10n.yourAgeLabel),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Selection Overlay (Magnifier effect)
                        Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // Wheel Scroll View
                        ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            ageController.text = (index + 10).toString();
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 90,
                            builder: (context, index) {
                              final age = index + 10;
                              return Center(
                                child: Text(
                                  '$age',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Full Width Next Button (Bottom)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.5),
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
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
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
