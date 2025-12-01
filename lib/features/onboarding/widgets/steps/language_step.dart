import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class LanguageStep extends StatelessWidget {
  final Function(Locale) onLanguageSelected;

  const LanguageStep({
    super.key,
    required this.onLanguageSelected,
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
    return PremiumGlassCard(
      onTap: () => onLanguageSelected(locale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            flag,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
