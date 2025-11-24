import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_colors.dart';
import 'package:applicazione_mental_coach/design_system/tokens/app_typography.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    // Force dark mode
    const isDarkMode = true;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Chat',
                route: AppRoute.chat,
                isSelected: currentLocation == AppRoute.chat.path,
              ),
              _buildNavItem(
                context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                route: AppRoute.dashboard,
                isSelected: currentLocation == AppRoute.dashboard.path,
              ),
              _buildNavItem(
                context,
                icon: Icons.face_outlined,
                activeIcon: Icons.face,
                label: 'Avatar',
                route: AppRoute.avatar,
                isSelected: currentLocation == AppRoute.avatar.path,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                route: AppRoute.settings,
                isSelected: currentLocation == AppRoute.settings.path,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required AppRoute route,
    required bool isSelected,
  }) {
    // Force dark mode colors
    const primaryColor = AppColors.secondary;
    const inactiveColor = AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => route.go(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? primaryColor : inactiveColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? primaryColor : inactiveColor,
                    fontWeight: isSelected 
                        ? AppTypography.medium 
                        : AppTypography.regular,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}