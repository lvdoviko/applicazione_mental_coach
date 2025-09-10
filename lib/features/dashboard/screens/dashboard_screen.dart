import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/components/stat_card.dart';

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
            AppColors.warmTerracotta.withOpacity(0.1),
            AppColors.warmGold.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warmTerracotta.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warmTerracotta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.warmTerracotta,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getTimeOfDayGreeting()}!',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Here\'s your wellness overview',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.grey600,
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
              label: 'Sessions',
              value: '23',
              color: AppColors.warmGold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 1,
            child: _buildQuickStat(
              icon: Icons.favorite_border,
              label: 'Mood Score',
              value: '8.2',
              color: AppColors.warmYellow,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 1,
            child: _buildQuickStat(
              icon: Icons.trending_up,
              label: 'Progress',
              value: '+15%',
              color: AppColors.warmOrange,
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
      constraints: const BoxConstraints(minHeight: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.h4.copyWith(
                color: color,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.caption,
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
          'Analytics Period',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
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
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warmTerracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.white : AppColors.grey600,
                        fontWeight: isSelected ? AppTypography.medium : AppTypography.regular,
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
          'Wellness Metrics',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: [
            StatCard(
              title: 'Mood Score',
              value: '8.2/10',
              subtitle: 'Above average',
              icon: Icons.mood,
              trend: StatTrend.up,
              trendValue: '+0.5',
              variant: StatCardVariant.success,
              sparklineData: [7.5, 7.8, 8.0, 7.9, 8.2, 8.1, 8.2],
            ),
            StatCard(
              title: 'Stress Level',
              value: '3.1/10',
              subtitle: 'Low stress',
              icon: Icons.spa,
              trend: StatTrend.down,
              trendValue: '-1.2',
              variant: StatCardVariant.primary,
              sparklineData: [4.5, 4.2, 3.8, 3.5, 3.3, 3.2, 3.1],
            ),
            StatCard(
              title: 'Energy',
              value: '7.8/10',
              subtitle: 'Good energy',
              icon: Icons.battery_charging_full,
              trend: StatTrend.up,
              trendValue: '+0.3',
              variant: StatCardVariant.warning,
              sparklineData: [7.2, 7.4, 7.6, 7.5, 7.7, 7.9, 7.8],
            ),
            StatCard(
              title: 'Sleep Quality',
              value: '85%',
              subtitle: 'Good sleep',
              icon: Icons.bedtime,
              trend: StatTrend.up,
              trendValue: '+5%',
              variant: StatCardVariant.info,
              sparklineData: [78, 80, 82, 83, 84, 86, 85],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthIntegration() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warmYellow.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.warmYellow,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Health Integration',
                style: AppTypography.h4.copyWith(
                  color: AppColors.textPrimary,
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
                  'Steps',
                  '8,542',
                  'today',
                  Icons.directions_walk,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 1,
                child: _buildHealthStat(
                  'Heart Rate',
                  '72 bpm',
                  'avg',
                  Icons.favorite,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 1,
                child: _buildHealthStat(
                  'Workouts',
                  '3',
                  'this week',
                  Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Data synced from Apple Health • Last update: 2 hours ago',
              style: AppTypography.caption.copyWith(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(String label, String value, String period, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.warmYellow,
            size: 18,
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.warmYellow,
                fontWeight: AppTypography.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              period,
              style: AppTypography.caption.copyWith(
                color: AppColors.grey500,
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
          'Recent Activity',
          style: AppTypography.h4,
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
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkSurface 
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.grey700 
              : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
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
                    fontWeight: AppTypography.medium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activity.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: AppTypography.caption,
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
            AppColors.warmOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warmOrange,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Insights & Recommendations',
                style: AppTypography.h4,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInsightItem(
            '🌟 Great progress this week!',
            'Your mood scores have been consistently above average. Keep up the excellent work with your wellness routine.',
          ),
          _buildInsightItem(
            '💤 Consider improving sleep',
            'Your energy levels could benefit from better sleep consistency. Try setting a regular bedtime.',
          ),
          _buildInsightItem(
            '🏃‍♀️ Active recovery recommended',
            'Based on your workout intensity, some light active recovery could help with stress management.',
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
        title: 'Chat Session',
        subtitle: 'Discussed stress management techniques',
        time: '2h ago',
        icon: Icons.chat_bubble_outline,
        color: AppColors.warmTerracotta,
      ),
      DashboardActivity(
        title: 'Workout Completed',
        subtitle: 'Strength training • 45 minutes',
        time: '5h ago',
        icon: Icons.fitness_center,
        color: AppColors.warmYellow,
      ),
      DashboardActivity(
        title: 'Mood Check-in',
        subtitle: 'Feeling energized and focused',
        time: '1d ago',
        icon: Icons.mood,
        color: AppColors.warmOrange,
      ),
      DashboardActivity(
        title: 'Avatar Updated',
        subtitle: 'Changed expression to determined',
        time: '2d ago',
        icon: Icons.face,
        color: AppColors.warmGold,
      ),
    ];
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
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