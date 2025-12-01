import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/core/config/app_config.dart';
import 'package:applicazione_mental_coach/design_system/components/glass_drawer.dart';
import 'package:applicazione_mental_coach/shared/widgets/premium_glass_card.dart';
import 'package:applicazione_mental_coach/core/providers/locale_provider.dart';

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
      extendBodyBehindAppBar: true,
      drawer: const GlassDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showAboutDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF1C2541), // Deep Blue
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 60,
            bottom: 40,
          ),
          child: Column(
            children: [
              _buildSection(
                'Privacy & Data',
                Icons.security,
                const Color(0xFF22D3EE), // Cyan Neon
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
                const Color(0xFFE879F9), // Purple/Pink Neon
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
                const Color(0xFFFACC15), // Yellow/Amber Neon
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
                    ref.watch(localeProvider).languageCode == 'it' ? 'Italiano' : 'English',
                    Icons.language,
                    onTap: _showLanguageDialog,
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                ],
              ),
              _buildSection(
                'Support',
                Icons.help,
                const Color(0xFF4ADE80), // Green Neon
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
                    iconColor: AppColors.error,
                  ),
                ],
              ),
              _buildSection(
                'Account',
                Icons.person,
                const Color(0xFF60A5FA), // Blue Neon
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
              const SizedBox(height: AppSpacing.xl),
              _buildVersionInfo(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PremiumGlassCard(
            padding: const EdgeInsets.all(0), // ListTiles have their own padding
            child: Column(
              children: children.map((child) {
                // Add separator if not last item
                if (child != children.last) {
                  return Column(
                    children: [
                      child,
                      Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.05),
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
                  );
                }
                return child;
              }).toList(),
            ),
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
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor ?? Colors.white54, size: 22),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          color: Colors.white38,
          fontSize: 13,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle ?? description,
        style: GoogleFonts.nunito(
          color: Colors.white38,
          fontSize: 13,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: AppColors.primary,
      inactiveThumbColor: Colors.white38,
      inactiveTrackColor: Colors.white10,
    );
  }

  Widget _buildDangerTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.error.withOpacity(0.8), size: 22),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          color: AppColors.error,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          color: AppColors.error.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.error.withOpacity(0.4), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          AppConfig.appName,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppConfig.appVersion}',
          style: GoogleFonts.nunito(
            color: Colors.white30,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ❤️ for athletes',
          style: GoogleFonts.nunito(
            color: Colors.white24,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _exportData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text('Export Data', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Your data export will be prepared and sent to your registered email within 24 hours. This includes all conversations, health data, and settings.',
          style: GoogleFonts.nunito(color: Colors.white70),
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
        backgroundColor: const Color(0xFF1C2541),
        title: Text('Notification Schedule', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Notification preferences will be available in a future update.',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
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
    final currentLocale = ref.read(localeProvider);
    final languages = [
      {'name': 'English', 'code': 'en'},
      {'name': 'Italiano', 'code': 'it'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2541),
        title: Text('Select Language', style: GoogleFonts.poppins(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            final isSelected = currentLocale.languageCode == language['code'];
            return RadioListTile<String>(
              title: Text(language['name']!, style: GoogleFonts.nunito(color: Colors.white)),
              value: language['code']!,
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                }
                Navigator.of(context).pop();
              },
              activeColor: AppColors.primary,
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
        backgroundColor: const Color(0xFF1C2541),
        title: Row(
          children: [
            const Icon(Icons.emergency, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text('Emergency Resources', style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you\'re in immediate danger or having thoughts of self-harm, please contact:',
              style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            ...AppConfig.emergencyHotlines.map((number) => 
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => _launchUrl('tel:$number'),
                  child: Text(
                    number,
                    style: GoogleFonts.nunito(
                      color: AppColors.primary,
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
        backgroundColor: const Color(0xFF1C2541),
        title: Text('Account Information', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Account management will be available in a future update.',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
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
        backgroundColor: const Color(0xFF1C2541),
        title: Text('Backup & Sync', style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          'Cloud backup will be available in a future update.',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
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
        backgroundColor: const Color(0xFF1C2541),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text('Delete Account', style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data, conversations, and settings will be permanently deleted. Are you sure you want to proceed?',
          style: GoogleFonts.nunito(color: Colors.white70),
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
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
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
        Text(
          'Your personal AI wellness coach supporting mental health for athletes and sports teams.',
          style: GoogleFonts.nunito(color: Colors.black87), // AboutDialog usually has light theme background by default in Flutter unless themed globally
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