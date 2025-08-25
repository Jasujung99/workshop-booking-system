import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/firebase_config.dart';
import 'presentation/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/services/performance_service.dart';
import 'core/services/network_optimization_service.dart';
import 'core/services/image_cache_manager.dart';
import 'core/services/accessibility_service.dart';
import 'l10n/app_localizations.dart';

import 'presentation/navigation/app_router.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();
    
    // Initialize performance services
    await PerformanceService.instance.initialize();
    await NetworkOptimizationService.instance.initialize();
    await ImageCacheManager.instance.initialize();
    await AccessibilityService.instance.initialize();
    
    // Initialize service locator
    await ServiceLocator.initialize();
    
    // Start performance monitoring in debug mode
    PerformanceService.instance.startPerformanceMonitoring();
    
    runApp(const WorkshopBookingApp());
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', exception: e, stackTrace: stackTrace);
    runApp(const ErrorApp());
  }
}

class WorkshopBookingApp extends StatelessWidget {
  const WorkshopBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ServiceLocator.getProviders(),
      child: MaterialApp(
        title: 'Workshop Booking System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppRouter(),
        debugShowCheckedModeBanner: false,
        
        // Localization support
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        
        // Navigation key for accessibility
        navigatorKey: NavigationService.navigatorKey,
        
        // Accessibility settings
        builder: (context, child) {
          final accessibilityService = AccessibilityService.instance;
          final mediaQuery = MediaQuery.of(context);
          
          // Apply accessibility enhancements
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaleFactor: accessibilityService.getTextScaleFactor(context),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Workshop Booking System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Setting up your experience...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Booking System - Error',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'Failed to Initialize App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Please check your Firebase configuration',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}