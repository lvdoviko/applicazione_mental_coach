import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:applicazione_mental_coach/features/onboarding/screens/onboarding_screen.dart';
import 'package:applicazione_mental_coach/features/chat/screens/chat_screen_backend.dart';
import 'package:applicazione_mental_coach/features/dashboard/screens/dashboard_screen.dart';
import 'package:applicazione_mental_coach/features/avatar/screens/avatar_screen.dart';
import 'package:applicazione_mental_coach/features/settings/screens/settings_screen.dart';
import 'package:applicazione_mental_coach/features/avatar/screens/coach_selection_screen.dart';

enum AppRoute {
  onboarding('/onboarding'),
  chat('/chat'),
  dashboard('/dashboard'),
  avatar('/avatar'),
  settings('/settings'),
  root('/');

  const AppRoute(this.path);
  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.onboarding.path,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding Flow
      GoRoute(
        path: AppRoute.onboarding.path,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Chat Screen (Primary & Root)
      GoRoute(
        path: AppRoute.chat.path,
        name: 'chat',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatScreenBackend(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: const Offset(0.05, 0.0), end: Offset.zero) // Subtle slide
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      
      // Dashboard
      GoRoute(
        path: AppRoute.dashboard.path,
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: const Offset(0.05, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      
      // Avatar Selection (Directly to Cards)
      GoRoute(
        path: AppRoute.avatar.path,
        name: 'avatar',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CoachSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: const Offset(0.05, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      
      // Settings
      GoRoute(
        path: AppRoute.settings.path,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // iOS Scale Back Effect for Settings
            const curve = Curves.easeInOutCubic;
            var slideTween = Tween(begin: const Offset(0.0, 0.1), end: Offset.zero) // Slide up slightly
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      
      // Root redirect
      GoRoute(
        path: AppRoute.root.path,
        redirect: (context, state) => AppRoute.chat.path,
      ),
    ],
    
    // Redirect logic for authenticated/unauthenticated users
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == AppRoute.onboarding.path;
      
      // For now, skip onboarding redirect logic
      // TODO: Implement proper authentication state check
      if (isOnboarding) {
        return null; // Stay on onboarding
      }
      
      // TODO: Check if user completed onboarding
      // final hasCompletedOnboarding = ref.read(userStateProvider).hasCompletedOnboarding;
      // if (!hasCompletedOnboarding) {
      //   return AppRoute.onboarding.path;
      // }
      
      return null; // No redirect needed
    },
    
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you\'re looking for doesn\'t exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoute.chat.path),
              child: const Text('Go to Chat'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helpers
extension AppRouteExtension on AppRoute {
  void go(BuildContext context) => context.go(path);
  void push(BuildContext context) => context.push(path);
}