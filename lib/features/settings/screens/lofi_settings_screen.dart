import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_animations.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';

/// **Lo-Fi Settings & Profile Screen**
/// 
/// **Functional Description:**
/// Clean settings interface with user profile, theme toggle, privacy controls,
/// and data management. Grouped sections with minimal visual hierarchy.
/// 
/// **Visual Specifications:**
/// - Background: #FBF9F8 (paper)
/// - Cards: #FFFFFF with subtle shadows
/// - Profile: Gradient avatar with user info
/// - Toggles: #7DAEA9 active states
/// - Groups: Clear section headers
/// - List tiles: Minimal icons and spacing
/// 
/// **Component Name:** LoFiSettingsScreen
/// 
/// **Accessibility:**
/// - Switch announcements and values
/// - Section headers for navigation
/// - Action button semantics
/// - Screen reader optimized
/// 
/// **Performance:**
/// - Stateless settings tiles
/// - Efficient list rendering
/// - Minimal state management
class LoFiSettingsScreen extends StatefulWidget {
  const LoFiSettingsScreen({super.key});

  @override
  State<LoFiSettingsScreen> createState() => _LoFiSettingsScreenState();
}

class _LoFiSettingsScreenState extends State<LoFiSettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _analyticsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildProfileSection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildAppearanceSection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildNotificationsSection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildPrivacySection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildDataSection(),
            const SizedBox(height: AppSpacing.sectionSpacing),
            _buildSupportSection(),
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        'Settings',
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildProfileSection() {
    return _buildSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.8),
                      AppColors.secondary.withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.surface,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Profile',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Manage your account details',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
      onTap: _openProfileEditor,
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Appearance',
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Use dark theme throughout the app',
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
            HapticFeedback.selectionClick();
          },
        ),
        _buildActionTile(
          icon: Icons.palette_outlined,
          title: 'Theme Color',
          subtitle: 'Customize accent colors',
          onTap: _openThemeSelector,
        ),
        _buildActionTile(
          icon: Icons.text_fields_outlined,
          title: 'Text Size',
          subtitle: 'Adjust font size and accessibility',
          onTap: _openFontSettings,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'Notifications & Sounds',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Get notified about new messages',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
            HapticFeedback.selectionClick();
          },
        ),
        _buildSwitchTile(
          icon: Icons.volume_up_outlined,
          title: 'Sound Effects',
          subtitle: 'Play sounds for interactions',
          value: _soundEffects,
          onChanged: (value) {
            setState(() {
              _soundEffects = value;
            });
            HapticFeedback.selectionClick();
          },
        ),
        _buildSwitchTile(
          icon: Icons.vibration_outlined,
          title: 'Haptic Feedback',
          subtitle: 'Feel vibrations for interactions',
          value: _hapticFeedback,
          onChanged: (value) {
            setState(() {
              _hapticFeedback = value;
            });
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy & Security',
      children: [
        _buildActionTile(
          icon: Icons.lock_outline,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: _openPrivacyPolicy,
        ),
        _buildActionTile(
          icon: Icons.security_outlined,
          title: 'Data Encryption',
          subtitle: 'View security details',
          onTap: _openSecurityInfo,
        ),
        _buildSwitchTile(
          icon: Icons.analytics_outlined,
          title: 'Anonymous Analytics',
          subtitle: 'Help improve the app (optional)',
          value: _analyticsEnabled,
          onChanged: (value) {
            setState(() {
              _analyticsEnabled = value;
            });
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Your Data',
      children: [
        _buildActionTile(
          icon: Icons.download_outlined,
          title: 'Export Data',
          subtitle: 'Download your conversation history',
          onTap: _exportUserData,
        ),
        _buildActionTile(
          icon: Icons.cloud_sync_outlined,
          title: 'Sync Settings',
          subtitle: 'Backup and sync across devices',
          onTap: _openSyncSettings,
        ),
        _buildActionTile(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          isDestructive: true,
          onTap: _confirmDeleteAccount,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support & Feedback',
      children: [
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Help Center',
          subtitle: 'Find answers and tutorials',
          onTap: _openHelpCenter,
        ),
        _buildActionTile(
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Report issues or suggest features',
          onTap: _sendFeedback,
        ),
        _buildActionTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'Version info and legal',
          onTap: _openAbout,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSectionCard(
          child: Column(
            children: children
                .expand((child) => [child, const SizedBox(height: AppSpacing.xs)])
                .take(children.length * 2 - 1)
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      shadowColor: AppColors.textPrimary.withOpacity(0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive 
              ? AppColors.error.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? AppColors.error 
              : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: isDestructive 
              ? AppColors.error 
              : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
        size: 20,
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: value ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  // Action handlers
  void _openProfileEditor() {
    // TODO: Navigate to profile editor
  }

  void _openThemeSelector() {
    // TODO: Show theme selection dialog
  }

  void _openFontSettings() {
    // TODO: Navigate to font settings
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy URL
  }

  void _openSecurityInfo() {
    // TODO: Show security information
  }

  void _exportUserData() {
    // TODO: Export user data
  }

  void _openSyncSettings() {
    // TODO: Navigate to sync settings
  }

  void _confirmDeleteAccount() {
    _showConfirmationDialog(
      title: 'Delete Account',
      message: 'This will permanently delete your account and all data. This action cannot be undone.',
      confirmText: 'Delete Account',
      onConfirm: _deleteAccount,
      isDestructive: true,
    );
  }

  void _deleteAccount() {
    // TODO: Implement account deletion
  }

  void _openHelpCenter() {
    // TODO: Navigate to help center
  }

  void _sendFeedback() {
    // TODO: Open feedback form
  }

  void _openAbout() {
    // TODO: Show about dialog
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
            ),
            child: Text(
              confirmText,
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}