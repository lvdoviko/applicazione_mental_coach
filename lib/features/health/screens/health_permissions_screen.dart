import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/components/ios_button.dart';
import '../providers/health_data_providers.dart';

/// Screen for managing health data permissions and GDPR consent
class HealthPermissionsScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onPermissionsGranted;

  const HealthPermissionsScreen({
    super.key,
    this.isInitialSetup = false,
    this.onPermissionsGranted,
  });

  @override
  ConsumerState<HealthPermissionsScreen> createState() => _HealthPermissionsScreenState();
}

class _HealthPermissionsScreenState extends ConsumerState<HealthPermissionsScreen> {
  bool _dataProcessingConsent = false;
  bool _healthDataConsent = false;
  final Map<String, bool> _individualPermissions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthPermissionsProvider.notifier).checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionsState = ref.watch(healthPermissionsProvider);
    final hasHealthPermissions = ref.watch(hasHealthPermissionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Configura Permessi' : 'Gestisci Permessi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: permissionsState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isInitialSetup) _buildWelcomeHeader(),
                  _buildGDPRConsentSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildHealthDataConsentSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildIndividualPermissionsSection(permissionsState),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPermissionsStatusSection(permissionsState),
                  const SizedBox(height: AppSpacing.xl),
                  _buildActionButtons(hasHealthPermissions),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warmTerracotta.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety,
            size: 48,
            color: AppColors.warmTerracotta,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Benvenuto nel tuo AI Mental Coach',
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Per offrirti consigli personalizzati e efficaci, abbiamo bisogno di accedere ad alcuni dei tuoi dati sanitari. Tutti i dati sono protetti e utilizzati solo per migliorare la tua esperienza.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGDPRConsentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: AppColors.warmGold),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Consenso al Trattamento Dati',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'In conformità al GDPR, richiediamo il tuo consenso esplicito per il trattamento dei tuoi dati personali per scopi di coaching AI.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              value: _dataProcessingConsent,
              onChanged: (value) {
                setState(() {
                  _dataProcessingConsent = value ?? false;
                });
              },
              title: Text(
                'Acconsento al trattamento dei miei dati personali',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Puoi revocare questo consenso in qualsiasi momento dalle impostazioni',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              activeColor: AppColors.warmTerracotta,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: () => _showPrivacyPolicy(),
                  child: Text(
                    'Leggi la Privacy Policy',
                    style: TextStyle(color: AppColors.warmTerracotta),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                TextButton(
                  onPressed: () => _showDataUsageInfo(),
                  child: Text(
                    'Come usiamo i dati',
                    style: TextStyle(color: AppColors.warmTerracotta),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDataConsentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.warmYellow),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Consenso Dati Sanitari',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'I dati sanitari sono particolarmente sensibili e richiedono un consenso separato. Utilizziamo questi dati solo per personalizzare i tuoi consigli di coaching.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              value: _healthDataConsent,
              onChanged: (value) {
                setState(() {
                  _healthDataConsent = value ?? false;
                });
              },
              title: Text(
                'Acconsento alla raccolta e uso dei miei dati sanitari',
                style: AppTypography.bodyMedium,
              ),
              subtitle: Text(
                'Include: frequenza cardiaca, sonno, attività fisica, variabilità cardiaca',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              activeColor: AppColors.warmYellow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualPermissionsSection(HealthPermissionsState permissionsState) {
    if (!_healthDataConsent) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(Icons.lock, color: AppColors.grey400),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Abilita il consenso per i dati sanitari per configurare i permessi specifici',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: AppColors.warmOrange),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Permessi Specifici',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Scegli quali tipi di dati sanitari vuoi condividere. Più dati condividi, più personalizzati saranno i tuoi consigli.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._buildPermissionsList(permissionsState),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPermissionsList(HealthPermissionsState permissionsState) {
    final permissionNames = {
      'heart_rate': {
        'name': 'Frequenza Cardiaca',
        'description': 'Frequenza cardiaca attuale e a riposo',
        'icon': Icons.favorite,
        'color': AppColors.warmYellow,
        'importance': 'Essenziale',
      },
      'hrv': {
        'name': 'Variabilità Cardiaca',
        'description': 'Indicatore di stress e recupero',
        'icon': Icons.monitor_heart,
        'color': AppColors.warmTerracotta,
        'importance': 'Molto importante',
      },
      'sleep': {
        'name': 'Dati del Sonno',
        'description': 'Durata, qualità e fasi del sonno',
        'icon': Icons.bedtime,
        'color': AppColors.warmGold,
        'importance': 'Essenziale',
      },
      'steps': {
        'name': 'Attività Fisica',
        'description': 'Passi, calorie e distanza',
        'icon': Icons.directions_walk,
        'color': AppColors.warmOrange,
        'importance': 'Importante',
      },
      'workouts': {
        'name': 'Allenamenti',
        'description': 'Sessioni di allenamento e intensità',
        'icon': Icons.fitness_center,
        'color': AppColors.warmTerracotta,
        'importance': 'Importante',
      },
      'blood_oxygen': {
        'name': 'Saturazione Ossigeno',
        'description': 'Livelli di SpO2 (se disponibile)',
        'icon': Icons.air,
        'color': AppColors.warmYellow,
        'importance': 'Opzionale',
      },
    };

    return permissionNames.entries.map((entry) {
      final key = entry.key;
      final info = entry.value;
      final isGranted = permissionsState.permissions[key] ?? false;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isGranted ? (info['color'] as Color) : AppColors.grey200,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isGranted 
              ? (info['color'] as Color).withOpacity(0.05)
              : Colors.white,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: (info['color'] as Color).withOpacity(0.1),
            child: Icon(
              info['icon'] as IconData,
              color: info['color'] as Color,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                info['name'] as String,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getImportanceColor(info['importance'] as String),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info['importance'] as String,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            info['description'] as String,
            style: AppTypography.caption.copyWith(
              color: AppColors.grey500,
            ),
          ),
          trailing: Switch(
            value: isGranted,
            onChanged: _healthDataConsent 
                ? (value) => _requestSpecificPermission(key, value)
                : null,
            activeColor: info['color'] as Color,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPermissionsStatusSection(HealthPermissionsState permissionsState) {
    final hasAllPermissions = permissionsState.hasAllPermissions;
    final missingPermissions = permissionsState.missingPermissions;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasAllPermissions ? Icons.check_circle : Icons.warning,
                  color: hasAllPermissions ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Stato Permessi',
                  style: AppTypography.h4,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (hasAllPermissions)
              Text(
                'Perfetto! Hai concesso tutti i permessi necessari. Il tuo AI Coach può ora fornirti consigli personalizzati basati sui tuoi dati sanitari.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.green[700],
                  height: 1.4,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alcuni permessi sono mancanti. Per un\'esperienza ottimale, ti consigliamo di abilitare tutti i permessi essenziali.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.orange[700],
                      height: 1.4,
                    ),
                  ),
                  if (missingPermissions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Permessi mancanti:',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...missingPermissions.map((permission) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: Text(
                        '• ${_getPermissionDisplayName(permission)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            if (permissionsState.lastChecked != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Ultimo controllo: ${_formatDateTime(permissionsState.lastChecked!)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool hasAllPermissions) {
    return Column(
      children: [
        IOSButton(
          text: widget.isInitialSetup 
              ? (hasAllPermissions ? 'Completa Configurazione' : 'Continua Senza Tutti i Permessi')
              : 'Salva Modifiche',
          style: IOSButtonStyle.primary,
          size: IOSButtonSize.large,
          width: double.infinity,
          onPressed: _canProceed() ? _handleProceed : null,
          isEnabled: _canProceed(),
        ),
        const SizedBox(height: AppSpacing.md),
        IOSButton(
          text: 'Aggiorna Stato Permessi',
          style: IOSButtonStyle.secondary,
          size: IOSButtonSize.large,
          width: double.infinity,
          onPressed: () => _refreshPermissions(),
        ),
        if (widget.isInitialSetup) ...[
          const SizedBox(height: AppSpacing.md),
          IOSButton(
            text: 'Configura in Seguito',
            style: IOSButtonStyle.tertiary,
            size: IOSButtonSize.medium,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ],
    );
  }

  // Helper methods

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'Essenziale':
        return Colors.red;
      case 'Molto importante':
        return Colors.orange;
      case 'Importante':
        return Colors.blue;
      case 'Opzionale':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getPermissionDisplayName(String permission) {
    const names = {
      'heart_rate': 'Frequenza Cardiaca',
      'hrv': 'Variabilità Cardiaca',
      'sleep': 'Dati del Sonno',
      'steps': 'Attività Fisica',
      'workouts': 'Allenamenti',
      'blood_oxygen': 'Saturazione Ossigeno',
    };
    return names[permission] ?? permission;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canProceed() {
    return _dataProcessingConsent && _healthDataConsent;
  }

  // Action handlers

  Future<void> _requestSpecificPermission(String permission, bool grant) async {
    if (grant) {
      final success = await ref.read(healthPermissionsProvider.notifier)
          .requestSpecificPermission(permission);
      
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossibile concedere il permesso per ${_getPermissionDisplayName(permission)}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  void _handleProceed() {
    // Save consents
    ref.read(healthPermissionsServiceProvider)
        .setDataProcessingConsent(_dataProcessingConsent);
    ref.read(healthPermissionsServiceProvider)
        .setHealthDataConsent(_healthDataConsent);
    
    // Update consent version
    ref.read(healthPermissionsServiceProvider).updateConsentVersion();
    
    if (widget.onPermissionsGranted != null) {
      widget.onPermissionsGranted!();
    } else {
      Navigator.pop(context);
    }
  }

  void _refreshPermissions() {
    ref.read(healthPermissionsProvider.notifier).checkPermissions();
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'La nostra Privacy Policy descrive come raccogliamo, utilizziamo e proteggiamo i tuoi dati personali...\n\n'
            '• Raccogliamo solo i dati necessari per il servizio di coaching\n'
            '• Tutti i dati sono crittografati e protetti\n'
            '• Non condividiamo i dati con terze parti\n'
            '• Puoi revocare il consenso in qualsiasi momento\n'
            '• I dati vengono conservati secondo la normativa GDPR',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Come Usiamo i Tuoi Dati'),
        content: const SingleChildScrollView(
          child: Text(
            'I tuoi dati sanitari vengono utilizzati esclusivamente per:\n\n'
            '• Personalizzare i consigli di coaching mentale\n'
            '• Identificare pattern e tendenze nella tua salute\n'
            '• Fornire alert preventivi per stress o sovrallenamento\n'
            '• Migliorare l\'efficacia delle tecniche di rilassamento\n\n'
            'Tutti i dati rimangono anonimi e sono processati localmente quando possibile.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}