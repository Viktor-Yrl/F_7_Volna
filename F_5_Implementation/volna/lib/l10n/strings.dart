import 'package:flutter/widgets.dart';
import '../data/models.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}

// Only app-owned placeholders and catalog labels are translated, never user data.
extension TrackLabels on Track {
  String titleLabel(BuildContext context) => switch (id) {
    'radio:marusya' => context.l10n.marusyaTitle,
    'radio:europa-plus' => context.l10n.europaTitle,
    _ =>
      title.isEmpty || title == 'Без названия' ? context.l10n.untitled : title,
  };
  String artistLabel(BuildContext context) => switch (id) {
    'radio:marusya' => context.l10n.marusyaDescription,
    'radio:europa-plus' => context.l10n.europaDescription,
    'radio:bbc-world-service' => context.l10n.bbcDescription,
    'radio:comedy-uk' => context.l10n.comedyUkDescription,
    'radio:181-comedy-club' => context.l10n.comedyUsDescription,
    _ =>
      [
            '',
            'Unknown artist',
            'Неизвестный исполнитель',
            '<unknown>',
          ].contains(artist)
          ? context.l10n.unknownArtist
          : ['Downloaded file', 'Загруженный файл'].contains(artist)
          ? context.l10n.downloadedFile
          : artist,
  };
}
