import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class PersonalityStep extends StatefulWidget {
  final ValueChanged<String> onPersonalitySelected;
  final VoidCallback onBack;

  const PersonalityStep({
    super.key,
    required this.onPersonalitySelected,
    required this.onBack,
  });

  @override
  State<PersonalityStep> createState() => _PersonalityStepState();
}

class _PersonalityStepState extends State<PersonalityStep> {
  String? _selectedId;

  void _handleSelection(String id) {
    setState(() {
      _selectedId = id;
    });
  }

  void _handleNext() {
    if (_selectedId != null) {
      widget.onPersonalitySelected(_selectedId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // 5 Personalità: Competitivo, Disciplinato, Riflessivo, Empatico, Energetico
    final List<Map<String, String>> _personalities = [
      {
        'id': 'Competitivo',
        'label': l10n.traitCompetitive,
        'description': l10n.traitCompetitiveDesc,
        'icon': '🏆',
      },
      {
        'id': 'Disciplinato',
        'label': l10n.traitDisciplined,
        'description': l10n.traitDisciplinedDesc,
        'icon': '📏',
      },
      {
        'id': 'Riflessivo',
        'label': l10n.traitReflective,
        'description': l10n.traitReflectiveDesc,
        'icon': '🧘',
      },
      {
        'id': 'Empatico',
        'label': l10n.traitEmpathetic,
        'description': l10n.traitEmpatheticDesc,
        'icon': '🤗',
      },
      {
        'id': 'Energetico',
        'label': l10n.traitEnergetic,
        'description': l10n.traitEnergeticDesc,
        'icon': '⚡',
      },
    ];

    return Stack(
      children: [
        // 1. SCROLLABLE CONTENT
        Positioned.fill(
          child: SingleChildScrollView(
             padding: const EdgeInsets.fromLTRB(24, 20, 24, 120), // Bottom padding for button
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Back Button)
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
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
                const SizedBox(height: AppSpacing.md),
                
                // Titles
                Text(
                  l10n.personalityTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.personalitySubtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _personalities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = _personalities[index];
                    final isSelected = _selectedId == item['id'];

                    return GestureDetector(
                      onTap: () => _handleSelection(item['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(AppSpacing.md),
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
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                item['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label']!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description']!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // 2. FIXED BUTTON (Blue/Glass Style)
        Positioned(
          left: 24,
          right: 24,
          bottom: 70, 
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _selectedId != null ? AppColors.primary : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _selectedId != null ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _selectedId != null ? () {
                  HapticFeedback.lightImpact();
                  _handleNext();
                } : null,
                child: Center(
                  child: Text(
                    l10n.continueButton,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _selectedId != null ? Colors.white : Colors.white38,
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
