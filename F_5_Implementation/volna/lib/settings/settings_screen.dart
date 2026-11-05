import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../ui/track_tile.dart';
import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});
  final AppSettings settings;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    builder: (context, _) => _content(context),
  );

  Widget _content(BuildContext context) => SafeArea(
    child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            context.l10n.appearance,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        RadioGroup<bool>(
          groupValue: settings.lightTheme,
          onChanged: (value) {
            if (value != null && !settings.saving) {
              settings.setLightTheme(value);
            }
          },
          child: Column(
            children: [
              RadioListTile<bool>(
                title: Text(context.l10n.darkTheme),
                value: false,
                enabled: !settings.saving,
              ),
              RadioListTile<bool>(
                title: Text(context.l10n.lightTheme),
                value: true,
                enabled: !settings.saving,
              ),
            ],
          ),
        ),
        if (settings.saving) const LinearProgressIndicator(),
        if (settings.error != null)
          ErrorBanner(message: settings.error!, onDismiss: settings.clearError),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            context.l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        RadioGroup<String>(
          groupValue: settings.languageCode,
          onChanged: (code) {
            if (code != null && !settings.saving) {
              settings.setLanguage(code);
            }
          },
          child: Column(
            children: [
              for (final option in const {
                'en': 'English',
                'ru': 'Русский',
              }.entries)
                RadioListTile<String>(
                  title: Text(option.value),
                  value: option.key,
                  enabled: !settings.saving,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
