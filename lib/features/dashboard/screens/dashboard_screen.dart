import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/morning_briefing_card.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/readiness_battery.dart';
import 'package:applicazione_mental_coach/features/dashboard/widgets/daily_pulse.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Morning Briefing (Anticipatory UI)
              MorningBriefingCard(
                greeting: 'Buongiorno, Alex',
                insight: 'Il tuo recupero è all\'85%. Sei pronto per una sessione di focus?',
                actionLabel: 'Inizia Attivazione (3 min)',
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
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const ReadinessBattery(
                        percentage: 0.85,
                        label: 'Energia Mentale',
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        'Kaix',
        style: AppTypography.h3.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.sm),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biometria',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildBiometricItem(Icons.bedtime, 'Sonno', '7h 30m', AppColors.info),
              _buildDivider(),
              _buildBiometricItem(Icons.favorite, 'HRV', '55ms', AppColors.success),
              _buildDivider(),
              _buildBiometricItem(Icons.monitor_heart, 'RHR', '48bpm', AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }

  Widget _buildInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.background,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus in aumento',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'La tua coerenza è migliorata del 15% questa settimana.',
                      style: AppTypography.bodySmall,
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