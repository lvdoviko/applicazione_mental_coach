import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/stat_card.dart';
import '../providers/health_data_providers.dart';
import '../widgets/health_metrics_card.dart';
import '../widgets/health_trends_card.dart';
import '../widgets/calibration_banner.dart';
import 'health_permissions_screen.dart';

/// Dashboard screen for health data overview and insights
class HealthDashboardScreen extends ConsumerStatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  ConsumerState<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends ConsumerState<HealthDashboardScreen> {
  String _selectedPeriod = '24h';
  final List<String> _periods = ['24h', '72h', '7d'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHealthData();
    });
  }

  void _refreshHealthData() {
    ref.read(healthDataProvider.notifier).syncHealthData();
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthDataProvider);
    final permissionsState = ref.watch(healthPermissionsProvider);
    final hasPermissions = ref.watch(hasHealthPermissionsProvider);
    final needsCalibration = ref.watch(needsCalibrationProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(syncStatus),
      body: RefreshIndicator(
        onRefresh: () async => _refreshHealthData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (needsCalibration) ...[
                CalibrationBanner(
                  onStartCalibration: _startCalibration,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (!hasPermissions) ...[
                _buildPermissionsPrompt(),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (permissionsState.error != null) ...[
                _buildErrorBanner(permissionsState.error!),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (hasPermissions && healthState.hasData) ...[
                _buildPeriodSelector(),
                const SizedBox(height: AppSpacing.lg),
                _buildHealthOverview(healthState),
                const SizedBox(height: AppSpacing.lg),
                _buildHealthMetrics(healthState),
                const SizedBox(height: AppSpacing.lg),
                _buildHealthTrends(healthState),
                const SizedBox(height: AppSpacing.lg),
                _buildHealthAlerts(healthState),
              ] else if (hasPermissions && !healthState.hasData) ...[
                _buildNoDataState(healthState),
              ],
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String syncStatus) {
    return AppBar(
      title: const Text('Salute & Benessere'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _refreshHealthData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Sincronizza',
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HealthPermissionsScreen(),
            ),
          ),
          icon: const Icon(Icons.settings),
          tooltip: 'Impostazioni',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.sync, size: 16, color: AppColors.grey500),
              const SizedBox(width: AppSpacing.sm),
              Text(
                syncStatus,
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const Spacer(),
              if (ref.watch(healthDataProvider).isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.warmTerracotta),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsPrompt() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warmYellow.withOpacity(0.1),
            AppColors.warmOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warmYellow.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety,
            size: 48,
            color: AppColors.warmYellow,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Configura i Permessi Sanitari',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Per fornirti consigli personalizzati di coaching mentale, abbiamo bisogno di accedere ai tuoi dati sanitari da Apple Health o Google Health.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthPermissionsScreen(
                  isInitialSetup: true,
                  onPermissionsGranted: () {
                    Navigator.pop(context);
                    _refreshHealthData();
                  },
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmYellow,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
            ),
            child: const Text('Configura Permessi'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Errore di Sincronizzazione',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  error,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshHealthData,
            icon: const Icon(Icons.refresh, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(HealthDataState healthState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const Icon(
            Icons.data_usage,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            healthState.isSyncing ? 'Sincronizzazione in corso...' : 'Nessun dato disponibile',
            style: AppTypography.h3.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            healthState.isSyncing 
                ? 'Stiamo raccogliendo i tuoi dati sanitari. Questo potrebbe richiedere alcuni minuti.'
                : 'Non sono stati trovati dati sanitari. Assicurati che il tuo dispositivo wearable sia connesso e che abbia registrato dei dati.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!healthState.isSyncing)
            ElevatedButton(
              onPressed: _refreshHealthData,
              child: const Text('Riprova Sincronizzazione'),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Text(
          'Periodo di Analisi',
          style: AppTypography.h4,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.warmTerracotta : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.grey600,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildHealthOverview(HealthDataState healthState) {
    final snapshot = healthState.latestSnapshot!;
    final riskLevel = healthState.riskLevel;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getRiskGradient(riskLevel),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(riskLevel),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Stato Generale',
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getRiskDescription(riskLevel),
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            snapshot.summaryText,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(HealthDataState healthState) {
    final snapshot = healthState.latestSnapshot!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metriche Principali',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: HealthMetricsCard(
                title: 'Sonno',
                value: '${snapshot.sleep.avgHours.toStringAsFixed(1)}h',
                subtitle: 'Efficienza: ${snapshot.sleep.efficiency.toStringAsFixed(0)}%',
                trend: snapshot.sleep.getQualityTrend(),
                color: AppColors.warmGold,
                icon: Icons.bedtime,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: HealthMetricsCard(
                title: 'HRV',
                value: '${snapshot.physio.hrvRmssd.toStringAsFixed(0)}ms',
                subtitle: '${snapshot.physio.hrvDeltaPct.toStringAsFixed(1)}% vs baseline',
                trend: snapshot.physio.hrvDeltaPct >= 0 ? 'improving' : 'declining',
                color: AppColors.warmTerracotta,
                icon: Icons.monitor_heart,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: HealthMetricsCard(
                title: 'Stress',
                value: '${snapshot.physio.getStressScore()}/10',
                subtitle: 'Livello attuale',
                trend: snapshot.physio.getStressScore() <= 3 ? 'improving' : 'stable',
                color: AppColors.warmYellow,
                icon: Icons.psychology,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: HealthMetricsCard(
                title: 'Recupero',
                value: '${((snapshot.physio.hrvDeltaPct + 100) / 2).clamp(0, 100).toStringAsFixed(0)}%',
                subtitle: 'Stato di recupero',
                trend: 'stable',
                color: AppColors.warmOrange,
                icon: Icons.spa,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthTrends(HealthDataState healthState) {
    if (healthState.recentSnapshots.length < 3) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tendenze',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.lg),
        HealthTrendsCard(
          snapshots: healthState.recentSnapshots,
        ),
      ],
    );
  }

  Widget _buildHealthAlerts(HealthDataState healthState) {
    final snapshot = healthState.latestSnapshot!;
    if (snapshot.flags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Tutto nella norma! I tuoi parametri sono stabili.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert e Raccomandazioni',
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...snapshot.flags.take(3).map((flag) => _buildAlertItem(flag)),
        if (snapshot.flags.length > 3)
          TextButton(
            onPressed: () => _showAllAlerts(snapshot.flags),
            child: Text('Visualizza tutti gli alert (${snapshot.flags.length})'),
          ),
      ],
    );
  }

  Widget _buildAlertItem(String flag) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFlagTitle(flag),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                Text(
                  _getFlagDescription(flag),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startCalibration() {
    ref.read(calibrationProvider.notifier).enableCalibration();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Modalità calibrazione attivata! Ricordati di inserire i tuoi self-report giornalieri.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showAllAlerts(List<String> flags) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                'Tutti gli Alert (${flags.length})',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: flags.length,
                  itemBuilder: (context, index) => _buildAlertItem(flags[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods

  List<Color> _getRiskGradient(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return [Colors.green[400]!, Colors.green[600]!];
      case 'moderate':
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 'high':
        return [Colors.red[400]!, Colors.red[600]!];
      default:
        return [AppColors.grey400, AppColors.grey600];
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return 'Ottimo Stato';
      case 'moderate':
        return 'Attenzione Necessaria';
      case 'high':
        return 'Intervento Raccomandato';
      default:
        return 'Stato Sconosciuto';
    }
  }

  String _getFlagTitle(String flag) {
    const titles = {
      'insufficient_sleep': 'Sonno Insufficiente',
      'poor_sleep_3days': 'Qualità del Sonno Compromessa',
      'hrv_significantly_low': 'HRV Molto Basso',
      'elevated_stress': 'Stress Elevato',
      'recovery_recommended': 'Recupero Necessario',
      'high_training_load': 'Carico di Allenamento Alto',
    };
    return titles[flag] ?? flag;
  }

  String _getFlagDescription(String flag) {
    const descriptions = {
      'insufficient_sleep': 'Hai dormito meno di 6 ore. Il sonno è fondamentale per il recupero.',
      'poor_sleep_3days': 'Qualità del sonno bassa per 3+ notti consecutive.',
      'hrv_significantly_low': 'La tua variabilità cardiaca indica stress o sovrallenamento.',
      'elevated_stress': 'I tuoi parametri indicano un livello di stress elevato.',
      'recovery_recommended': 'Il tuo corpo ha bisogno di riposo per recuperare.',
      'high_training_load': 'Il carico di allenamento è molto alto. Considera il riposo attivo.',
    };
    return descriptions[flag] ?? 'Controlla questo parametro con attenzione.';
  }
}