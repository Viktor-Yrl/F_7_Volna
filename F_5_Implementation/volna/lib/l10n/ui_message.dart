import 'app_localizations.dart';

// Messages carry semantic IDs so errors can change language while visible.
enum MessageId {
  invalidAudioUrl,
  libraryLoadFailed,
  libraryScanFailed,
  folderOpenFailed,
  folderCleanupFailed,
  saveFailed,
  corruptBackup,
  stationUnavailable,
  playbackFailed,
  sourceUnavailable,
  toggleFailed,
  stopFailed,
  playerCommandFailed,
  radioRedirects,
  radioPageTooLarge,
  radioWebsite,
  settingsSaveFailed,
  foldersUnavailable,
  radioHttp,
}

class UiMessage {
  const UiMessage(this.id, {this.names = '', this.status = 0});
  final MessageId id;
  final int status;
  final String names;

  String localize(AppLocalizations strings) => switch (id) {
    MessageId.invalidAudioUrl => strings.invalidAudioUrl,
    MessageId.libraryLoadFailed => strings.libraryLoadFailed,
    MessageId.libraryScanFailed => strings.libraryScanFailed,
    MessageId.folderOpenFailed => strings.folderOpenFailed,
    MessageId.folderCleanupFailed => strings.folderCleanupFailed,
    MessageId.saveFailed => strings.saveFailed,
    MessageId.corruptBackup => strings.corruptBackup,
    MessageId.stationUnavailable => strings.stationUnavailable,
    MessageId.playbackFailed => strings.playbackFailed,
    MessageId.sourceUnavailable => strings.sourceUnavailable,
    MessageId.toggleFailed => strings.toggleFailed,
    MessageId.stopFailed => strings.stopFailed,
    MessageId.playerCommandFailed => strings.playerCommandFailed,
    MessageId.radioRedirects => strings.radioRedirects,
    MessageId.radioPageTooLarge => strings.radioPageTooLarge,
    MessageId.radioWebsite => strings.radioWebsite,
    MessageId.settingsSaveFailed => strings.settingsSaveFailed,
    MessageId.foldersUnavailable => strings.foldersUnavailable(names),
    MessageId.radioHttp => strings.radioHttp(status),
  };
}

// Preserve the FormatException contract used by URL validation.
class LocalizedException extends FormatException {
  const LocalizedException(this.localized) : super('localized');
  final UiMessage localized;
}
