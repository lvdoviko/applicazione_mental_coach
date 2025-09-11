import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_spacing.dart';
import 'package:applicazione_mental_coach/design_system/components/avatar_customizer.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AvatarConfig _currentConfig = const AvatarConfig(
    style: AvatarStyle.modern,
    expression: AvatarExpression.neutral,
    primaryColor: AppColors.primary,
    secondaryColor: AppColors.secondary,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCustomizeTab(),
                _buildPresetsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Avatar Customization'),
      actions: [
        TextButton(
          onPressed: _saveAvatarConfig,
          child: const Text('Save'),
        ),
        IconButton(
          onPressed: _resetToDefaults,
          icon: const Icon(Icons.refresh),
          tooltip: 'Reset to defaults',
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkSurface 
            : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.grey700 
                : AppColors.grey200,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey500,
        labelStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: AppTypography.medium,
        ),
        tabs: const [
          Tab(text: 'Customize'),
          Tab(text: 'Presets'),
        ],
      ),
    );
  }

  Widget _buildCustomizeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AvatarCustomizer(
        initialConfig: _currentConfig,
        onConfigChanged: (config) {
          setState(() => _currentConfig = config);
        },
        showPreview: true,
      ),
    );
  }

  Widget _buildPresetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Preset',
            style: AppTypography.h3,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quick start with these professionally designed avatars',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.8,
            children: _getPresets().map(
              (preset) => _buildPresetCard(preset),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(AvatarPreset preset) {
    final isSelected = _isSameConfig(_currentConfig, preset.config);

    return GestureDetector(
      onTap: () => setState(() => _currentConfig = preset.config),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? AppColors.darkSurface 
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.grey700 
                    : AppColors.grey200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: AvatarPreview(
                config: preset.config,
                size: 80,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    preset.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: AppTypography.medium,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    preset.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AvatarPreset> _getPresets() {
    return [
      AvatarPreset(
        name: 'Classic Athlete',
        description: 'Traditional and focused',
        config: const AvatarConfig(
          style: AvatarStyle.classic,
          expression: AvatarExpression.determined,
          primaryColor: AppColors.primary,
          secondaryColor: AppColors.secondary,
          accessory: 'cap',
        ),
      ),
      AvatarPreset(
        name: 'Modern Competitor',
        description: 'Contemporary and confident',
        config: const AvatarConfig(
          style: AvatarStyle.modern,
          expression: AvatarExpression.focused,
          primaryColor: AppColors.secondary,
          secondaryColor: AppColors.accent,
          accessory: 'headband',
        ),
      ),
      AvatarPreset(
        name: 'Zen Warrior',
        description: 'Calm and centered',
        config: const AvatarConfig(
          style: AvatarStyle.minimal,
          expression: AvatarExpression.neutral,
          primaryColor: AppColors.accent,
          secondaryColor: AppColors.warning,
        ),
      ),
      AvatarPreset(
        name: 'Happy Champion',
        description: 'Optimistic and energetic',
        config: const AvatarConfig(
          style: AvatarStyle.sport,
          expression: AvatarExpression.happy,
          primaryColor: AppColors.warning,
          secondaryColor: Color(0xFF8B5CF6),
        ),
      ),
      AvatarPreset(
        name: 'Team Leader',
        description: 'Strong and inspiring',
        config: const AvatarConfig(
          style: AvatarStyle.modern,
          expression: AvatarExpression.determined,
          primaryColor: Color(0xFFEC4899),
          secondaryColor: AppColors.primary,
          accessory: 'glasses',
        ),
      ),
      AvatarPreset(
        name: 'Mindful Athlete',
        description: 'Thoughtful and balanced',
        config: const AvatarConfig(
          style: AvatarStyle.minimal,
          expression: AvatarExpression.focused,
          primaryColor: Color(0xFF10B981),
          secondaryColor: AppColors.secondary,
        ),
      ),
    ];
  }

  bool _isSameConfig(AvatarConfig config1, AvatarConfig config2) {
    return config1.style == config2.style &&
           config1.expression == config2.expression &&
           config1.primaryColor == config2.primaryColor &&
           config1.secondaryColor == config2.secondaryColor &&
           config1.accessory == config2.accessory;
  }

  void _saveAvatarConfig() async {
    // TODO: Save avatar config to persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar configuration saved!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Avatar'),
        content: const Text(
          'Are you sure you want to reset your avatar to the default configuration? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentConfig = const AvatarConfig(
                  style: AvatarStyle.modern,
                  expression: AvatarExpression.neutral,
                  primaryColor: AppColors.primary,
                  secondaryColor: AppColors.secondary,
                );
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class AvatarPreset {
  final String name;
  final String description;
  final AvatarConfig config;

  AvatarPreset({
    required this.name,
    required this.description,
    required this.config,
  });
}