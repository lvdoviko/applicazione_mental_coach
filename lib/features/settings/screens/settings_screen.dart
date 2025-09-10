import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/core/config/app_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _healthDataEnabled = true;
  bool _analyticsEnabled = false; // Privacy-first default
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _obfuscateNotifications = true; // Privacy-first default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: _showAboutDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(
              'Privacy & Data',
              Icons.security,
              [
                _buildSwitchTile(
                  'Health Data Sync',
                  'Sync data from wearables and health apps',
                  _healthDataEnabled,
                  (value) => setState(() => _healthDataEnabled = value),
                  subtitle: 'Required for personalized insights',
                ),
                _buildSwitchTile(
                  'Analytics',
                  'Help improve the app with usage data',
                  _analyticsEnabled,
                  (value) => setState(() => _analyticsEnabled = value),
                  subtitle: 'Anonymous usage statistics only',
                ),
                _buildTile(
                  'Export Data',
                  'Download all your data (GDPR)',
                  Icons.download,
                  onTap: _exportData,
                ),
                _buildTile(
                  'Privacy Policy',
                  'Review our privacy practices',
                  Icons.policy,
                  onTap: () => _launchUrl('https://aiwellbeingcoach.com/privacy'),
                ),
              ],
            ),
            _buildSection(
              'Notifications',
              Icons.notifications,
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive wellness reminders and updates',
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildSwitchTile(
                  'Private Notifications',
                  'Hide message content in notifications',
                  _obfuscateNotifications,
                  (value) => setState(() => _obfuscateNotifications = value),
                  subtitle: 'Shows generic "New message" instead of content',
                ),
                _buildTile(
                  'Notification Schedule',
                  'Set quiet hours and frequency',
                  Icons.schedule,
                  onTap: _configureNotifications,
                ),
              ],
            ),
            _buildSection(
              'Appearance',
              Icons.palette,
              [
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme',
                  _darkModeEnabled,
                  (value) => setState(() => _darkModeEnabled = value),
                  subtitle: 'Follow system setting',
                ),
                _buildTile(
                  'Language',
                  _selectedLanguage,
                  Icons.language,
                  onTap: _showLanguageDialog,
                  trailing: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            _buildSection(
              'Support',
              Icons.help,
              [
                _buildTile(
                  'Help Center',
                  'FAQs and guides',
                  Icons.help_outline,
                  onTap: () => _launchUrl('https://aiwellbeingcoach.com/help'),
                ),
                _buildTile(
                  'Contact Support',
                  'Get help from our team',
                  Icons.support_agent,
                  onTap: _contactSupport,
                ),
                _buildTile(
                  'Emergency Resources',
                  'Crisis helplines and support',
                  Icons.emergency,
                  onTap: _showEmergencyResources,
                ),
              ],
            ),
            _buildSection(
              'Account',
              Icons.person,
              [
                _buildTile(
                  'Account Info',
                  'Manage your account details',
                  Icons.account_circle,
                  onTap: _showAccountInfo,
                ),
                _buildTile(
                  'Backup & Sync',
                  'Secure cloud backup',
                  Icons.cloud_sync,
                  onTap: _configureBackup,
                ),
                _buildDangerTile(
                  'Delete Account',
                  'Permanently delete your account and data',
                  Icons.delete_forever,
                  onTap: _deleteAccount,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.massive),
            _buildVersionInfo(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.warmTerracotta,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.warmTerracotta,
                  ),
                ),
              ],
            ),
          ),
          Container(
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
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey600),
      title: Text(
        title,
        style: AppTypography.bodyMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.grey600,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged, {
    String? subtitle,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTypography.bodyMedium,
      ),
      subtitle: Text(
        subtitle ?? description,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.grey600,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.warmTerracotta,
    );
  }

  Widget _buildDangerTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.error),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.error,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.grey600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.error),
      onTap: onTap,
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          AppConfig.appName,
          style: AppTypography.h4,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Version ${AppConfig.appVersion}',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Made with ❤️ for athletes',
          style: AppTypography.caption.copyWith(
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  void _exportData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your data export will be prepared and sent to your registered email within 24 hours. This includes all conversations, health data, and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export request submitted'),
                  backgroundColor: AppColors.success,
                ),
              );
              // TODO: Call data export API
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _configureNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Schedule'),
        content: const Text('Notification preferences will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Italiano'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.of(context).pop();
              },
              activeColor: AppColors.warmTerracotta,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _contactSupport() {
    // TODO: Implement support contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening support chat...'),
      ),
    );
  }

  void _showEmergencyResources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Emergency Resources'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If you\'re in immediate danger or having thoughts of self-harm, please contact:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            ...AppConfig.emergencyHotlines.map((number) => 
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => _launchUrl('tel:$number'),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.warmTerracotta,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAccountInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: const Text('Account management will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _configureBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Sync'),
        content: const Text('Cloud backup will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data, conversations, and settings will be permanently deleted. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion will be available in a future update'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.warmTerracotta, AppColors.warmGold],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.psychology,
          color: AppColors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'Your personal AI wellness coach supporting mental health for athletes and sports teams.',
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => _launchUrl('https://aiwellbeingcoach.com'),
          child: const Text('Visit our website'),
        ),
      ],
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
}