import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/morning_briefing_card.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/readiness_battery.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/daily_pulse.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/design_system/components/glass_drawer.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const GlassDrawer(),
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.5), // Center top
            radius: 1.2,
            colors: [
              Color(0xFF1C2541), // Deep Blue
              Color(0xFF080a10), // Almost Black
            ],
          ),
        ),
        child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(), // Custom AppBar inside body
              const SizedBox(height: AppSpacing.md),
              // 1. Morning Briefing (Anticipatory UI)
              MorningBriefingCard(
                greeting: AppLocalizations.of(context)!.welcomeUser('Alex'),
                insight: AppLocalizations.of(context)!.morningBriefingInsight,
                actionLabel: AppLocalizations.of(context)!.startActivation,
                onActionTap: () {
                  // TODO: Start activation protocol
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Readiness & Pulse (Biometric Empathy)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: PremiumGlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ReadinessBattery(
                        percentage: 0.85,
                        label: AppLocalizations.of(context)!.mentalEnergy,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 6,
                    child: DailyPulse(
                      onMoodChanged: (value) {
                        // TODO: Log mood
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Health Integration (Data Context)
              _buildHealthSection(),
              const SizedBox(height: AppSpacing.xl),

              // 4. Insights (Mastery)
              _buildInsights(),
            ],
          ),
        ),
      ),
    ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Kaix',
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.biometrics,
          style: AppTypography.h4.copyWith(color: Colors.white, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: AppSpacing.md),
        PremiumGlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              _buildBiometricItem(Icons.bedtime, AppLocalizations.of(context)!.sleep, '7h 30m', const Color(0xFF22D3EE)), // Cyan
              _buildDivider(),
              _buildBiometricItem(Icons.favorite, AppLocalizations.of(context)!.hrv, '55ms', const Color(0xFF4ADE80)), // Neon Green
              _buildDivider(),
              _buildBiometricItem(Icons.monitor_heart, AppLocalizations.of(context)!.rhr, '48bpm', const Color(0xFFF472B6)), // Pink
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Ensure centering
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20), // Reduced size
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Nunito',
              shadows: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.white70, fontFamily: 'Nunito'),
          ),
          const SizedBox(height: 5), // Added breathing room
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.trend,
          style: AppTypography.h4.copyWith(color: Colors.white, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: AppSpacing.md),
        PremiumGlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.focusIncreasing,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.coherenceImproved,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }
}