import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class LanguageStep extends StatelessWidget {
  final Function(Locale) onLanguageSelected;
  final Locale? selectedLocale;

  const LanguageStep({
    super.key,
    required this.onLanguageSelected,
    this.selectedLocale,
  });

  @override
  Widget build(BuildContext context) {
    // We can't rely on AppLocalizations.of(context) for the title yet 
    // because the user hasn't selected the language.
    // We'll show a generic welcome or both languages.
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.journeyStartsHere,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildLanguageOption(
            context,
            locale: const Locale('it'),
            flag: '🇮🇹',
            name: 'Italiano',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLanguageOption(
            context,
            locale: const Locale('en'),
            flag: '🇬🇧',
            name: 'English',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required Locale locale,
    required String flag,
    required String name,
  }) {
    final isSelected = selectedLocale?.languageCode == locale.languageCode;
    
    return GestureDetector(
      onTap: () => onLanguageSelected(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 85, // Altezza generosa
        decoration: BoxDecoration(
          // SFONDO:
          // Se selezionato: Blu leggerissimo (Vetro colorato)
          // Se non selezionato: Bianco quasi invisibile (Vetro pulito)
          color: isSelected 
              ? const Color(0xFF4A90E2).withOpacity(0.20) 
              : Colors.white.withOpacity(0.05),
          
          borderRadius: BorderRadius.circular(20),
          
          // BORDO:
          // Se selezionato: Blu Elettrico (Focus)
          // Se non selezionato: Bianco sottile (Definizione)
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4A90E2) 
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          
          // GLOW (Solo se selezionato):
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
