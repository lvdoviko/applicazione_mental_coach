import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class UserDetailsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final Function(DateTime) onDobSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const UserDetailsStep({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onDobSelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // 1. CENTERED SCROLLABLE CONTENT
        Positioned.fill(
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Spacer for fixed Header (Back Button)
                        const SizedBox(height: 80), 

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
                        
                        // Name Section (Clean Glass Input)
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1), 
                          ),
                          child: Center(
                            child: TextField(
                              controller: nameController,
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
                              cursorColor: AppColors.primary,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_outline, color: Colors.white60),
                                hintText: l10n.nameLabel,
                                hintStyle: GoogleFonts.nunito(color: Colors.white30),
                                border: InputBorder.none, 
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
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

                        // Date of Birth Section
                        const SizedBox(height: 24),
                        _buildSectionLabel(l10n.dateOfBirthLabel.toUpperCase()),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showDatePicker(context, l10n);
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                            ),
                            child: Center(
                              child: IgnorePointer( // Make it read-only
                                child: TextField(
                                  controller: dobController,
                                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
                                  cursorColor: AppColors.primary,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.white60),
                                    hintText: l10n.dateFormat,
                                    hintStyle: GoogleFonts.nunito(color: Colors.white30),
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Spacer for fixed Footer
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. FIXED BACK BUTTON (Top Left)
        Positioned(
          top: 60, // Safe Area approx
          left: 24,
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

        // 3. FIXED FOOTER (Button + Privacy)
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
                    l10n.continueButton,
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

        // 4. PRIVACY REASSURANCE
        Positioned(
          left: 24,
          right: 24,
          bottom: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white30, size: 12),
              const SizedBox(width: 8),
              Text(
                l10n.dataPrivacyReassurance,
                style: GoogleFonts.nunito(
                  color: Colors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
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
          color: isSelected 
              ? AppColors.primary.withOpacity(0.20) 
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
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

  void _showDatePicker(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E), // Dark background matching theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime(2000, 1, 1),
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      onDobSelected(newDate); // Update state dynamically
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 70), // Exactly matching the 'bottom: 70' of other buttons
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.confirmDate,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
