import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:applicazione_mental_coach/core/theme/app_theme.dart';
import 'package:applicazione_mental_coach/core/routing/app_router.dart';
import 'package:applicazione_mental_coach/core/config/app_config.dart';
import 'package:applicazione_mental_coach/l10n/app_localizations.dart';
import 'package:applicazione_mental_coach/features/chat/models/chat_message.dart';
import 'package:applicazione_mental_coach/features/chat/models/chat_session.dart';
import 'package:applicazione_mental_coach/features/user/models/user_model.dart';
import 'package:applicazione_mental_coach/core/providers/locale_provider.dart';
import 'package:applicazione_mental_coach/shared/widgets/living_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters for chat models
  Hive.registerAdapter(ChatSessionAdapter()); // TypeId: 11
  Hive.registerAdapter(UserModelAdapter()); // TypeId: 1
  // Note: ChatMessage uses JSON serialization, not Hive adapter
  
  // Set device orientation preferences
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: AIWellbeingCoachApp(),
    ),
  );
}

class AIWellbeingCoachApp extends ConsumerWidget {
  const AIWellbeingCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      themeMode: ThemeMode.dark, // Force Dark Mode for Neon Aesthetic
      
      // Localization
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      // Routing
      routerConfig: router,
      
      // Performance optimizations & Global Background
      builder: (context, child) {
        // 1. Text Scaler Optimization
        final mediaQueryData = MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(
            MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
          ),
        );

        return MediaQuery(
          data: mediaQueryData,
          child: Stack(
            children: [
              // 2. GLOBAL BACKGROUND (Fixed & Persistent)
              // Now has access to MediaQuery provided by MaterialApp
              const Positioned.fill(child: LivingBackground()),

              // 3. APP CONTENT (Navigator)
              Positioned.fill(child: child!),
            ],
          ),
        );
      },
    );
  }
}
