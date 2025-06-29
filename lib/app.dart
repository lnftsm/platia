import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:platia/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'config/theme/app_theme.dart';
import 'config/routes/route_generator.dart';
import 'core/app_initializer.dart';
import 'providers/auth_provider.dart';

class PlatiaApp extends StatelessWidget {
  const PlatiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider - must be first
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Add more providers as you create them
        // ChangeNotifierProvider(create: (context) => UserProvider()),
        // ChangeNotifierProvider(create: (context) => ClassProvider()),
        // ChangeNotifierProvider(create: (context) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Platia',
        debugShowCheckedModeBanner: false,

        // Localization support
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'), // Turkish
          Locale('en', 'US'), // English
        ],
        locale: const Locale('tr', 'TR'), // Default to Turkish
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Initial route
        home: const AppInitializer(),

        // Route generation
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
