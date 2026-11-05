import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'ui/home_screen.dart';
import 'l10n/app_localizations.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key, required this.controller});
  final AppController controller;
  // Mist Blue uses tinted surfaces rather than a pure white background.
  ThemeData _mistBlue() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF28606A),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF28606A),
          onPrimary: const Color(0xFFDEE6EC),
          surface: const Color(0xFFDEE6EC),
          onSurface: const Color(0xFF24343D),
          onSurfaceVariant: const Color(0xFF4B606D),
          surfaceContainerLow: const Color(0xFFD5E0E7),
          surfaceContainer: const Color(0xFFCAD7E0),
          surfaceContainerHigh: const Color(0xFFC4D3DE),
          surfaceContainerHighest: const Color(0xFFBDCED9),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFCAD7E0),
        indicatorColor: Color(0xFFB4CED4),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB5EE52);
    return ListenableBuilder(
      listenable: controller.settings,
      builder: (context, _) => MaterialApp(
        title: 'Volna',
        locale: Locale(controller.settings.languageCode),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        themeMode: controller.settings.lightTheme
            ? ThemeMode.light
            : ThemeMode.dark,
        theme: _mistBlue(),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: accent,
            brightness: Brightness.dark,
            primary: accent,
            surface: const Color(0xFF232628),
          ),
          scaffoldBackgroundColor: const Color(0xFF232628),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF232628),
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
              color: Color(0xFFF5F6F3),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF202224),
            indicatorColor: Color(0xFF3E4B31),
          ),
          dividerColor: const Color(0xFF42484A),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: HomeScreen(app: controller),
      ),
    );
  }
}
