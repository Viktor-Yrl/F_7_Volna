import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'ui/home_screen.dart';
import 'l10n/app_localizations.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key, required this.controller});
  final AppController controller;
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
        theme: ThemeData(
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
