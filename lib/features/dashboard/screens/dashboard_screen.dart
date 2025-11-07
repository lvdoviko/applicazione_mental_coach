import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'Week';
  final List<String> _periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: AppSpacing.xxl),
              _buildPeriodSelector(),
              const SizedBox(height: AppSpacing.xl),
              _buildWellnessMetrics(),
              const SizedBox(height: AppSpacing.xl),
              _buildHealthIntegration(),
              const SizedBox(height: AppSpacing.xl),
              _buildActivitySummary(),
              const SizedBox(height: AppSpacing.xl),
              _buildInsights(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Dashboard'),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Show data export options
          },
          icon: const Icon(Icons.download),
          tooltip: 'Export Data',
        ),
        IconButton(
          onPressed: () {
            // TODO: Show dashboard settings
          },
          icon: const Icon(Icons.tune),
          tooltip: 'Customize Dashboard',
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmGold.withOpacity(0.15),
            AppColors.warmTerracotta.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warmGold.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star_outline,
                  color: AppColors.warmGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ciao! Come stai oggi?',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Scopri i tuoi progressi quotidiani',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildQuickStat(
              icon: Icons.chat_bubble_outline,
              label: 'Conversazioni',
              value: '23',
              color: AppColors.warmTerracotta,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 1,
            child: _buildQuickStat(
              icon: Icons.sentiment_satisfied_outlined,
              label: 'Umore',
              value: '8.2',
              color: AppColors.warmGold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 1,
            child: _buildQuickStat(
              icon: Icons.trending_up,
              label: 'Progressi',
              value: '+15%',
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.h4.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periodo di Analisi',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warmGold.withOpacity(0.1),
                AppColors.warmTerracotta.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return Flexible(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warmTerracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      period,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Il Tuo Benessere',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildSimpleMetricsGrid(),
      ],
    );
  }

  Widget _buildSimpleMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildSimpleMetricCard(Icons.sentiment_satisfied_outlined, 'Umore', '8.2', 'Fantastico!', AppColors.warmGold),
        _buildSimpleMetricCard(Icons.spa_outlined, 'Stress', '3.1', 'Rilassato', AppColors.success),
        _buildSimpleMetricCard(Icons.bolt_outlined, 'Energia', '7.8', 'Pieno di energia', AppColors.warmTerracotta),
        _buildSimpleMetricCard(Icons.bedtime_outlined, 'Sonno', '85%', 'Riposato', AppColors.info),
      ],
    );
  }

  Widget _buildSimpleMetricCard(IconData icon, String title, String value, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            status,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIntegration() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.info.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                color: AppColors.accent,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Attività Fisica',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildHealthStat(
                  Icons.directions_walk,
                  'Passi',
                  '8,542',
                  'oggi',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 1,
                child: _buildHealthStat(
                  Icons.favorite,
                  'Cuore',
                  '72 bpm',
                  'media',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 1,
                child: _buildHealthStat(
                  Icons.fitness_center,
                  'Allenamenti',
                  '3',
                  'questa settimana',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              'Dati da Apple Health • Aggiornato 2 ore fa',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(IconData icon, String label, String value, String period) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              period,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ultime Attività',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._getRecentActivities().map(
          (activity) => _buildActivityItem(activity),
        ),
      ],
    );
  }

  Widget _buildActivityItem(DashboardActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activity.color.withOpacity(0.1),
            activity.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activity.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.time,
              style: AppTypography.caption.copyWith(
                color: activity.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmGold.withOpacity(0.1),
            AppColors.warmTerracotta.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Consigli del Giorno',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInsightItem(
            '🌟 Fantastico Lavoro!',
            'Il tuo umore è stato costantemente alto questa settimana. Continua così con la tua routine di benessere!',
          ),
          _buildInsightItem(
            '😴 Dormi Meglio',
            'I tuoi livelli di energia potrebbero migliorare con un sonno più regolare. Prova a impostare un orario fisso per andare a dormire.',
          ),
          _buildInsightItem(
            '🚶‍♀️ Muoviti di Più',
            'Una camminata leggera dopo gli allenamenti intensi può aiutarti a gestire meglio lo stress.',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: AppTypography.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  List<DashboardActivity> _getRecentActivities() {
    return [
      DashboardActivity(
        title: 'Sessione di Chat',
        subtitle: 'Abbiamo parlato di tecniche per gestire lo stress',
        time: '2h fa',
        icon: Icons.chat_bubble_outline,
        color: AppColors.warmTerracotta,
      ),
      DashboardActivity(
        title: 'Allenamento Completato',
        subtitle: 'Allenamento di forza • 45 minuti',
        time: '5h fa',
        icon: Icons.fitness_center,
        color: AppColors.success,
      ),
      DashboardActivity(
        title: 'Check-in Umore',
        subtitle: 'Ti senti pieno di energia e concentrato',
        time: '1g fa',
        icon: Icons.mood,
        color: AppColors.warmGold,
      ),
      DashboardActivity(
        title: 'Avatar Aggiornato',
        subtitle: 'Cambiata espressione in determinato',
        time: '2g fa',
        icon: Icons.face,
        color: AppColors.info,
      ),
    ];
  }


  Future<void> _refreshData() async {
    // TODO: Implement data refresh from API
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {});
    }
  }
}

class DashboardActivity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}