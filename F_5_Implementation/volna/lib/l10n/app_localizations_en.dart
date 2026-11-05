// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appearance => 'Appearance';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light — Mist Blue';

  @override
  String get folderCleanupFailed =>
      'Could not release unused folder access. Refresh the folders to retry.';

  @override
  String get playlists => 'Playlists';

  @override
  String get radio => 'Radio';

  @override
  String get top100 => 'Top 100';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get refreshLibrary => 'Refresh library';

  @override
  String get addFolder => 'Add folder';

  @override
  String get musicFolders => 'Music folders';

  @override
  String get noTracksAvailable => 'No available tracks';

  @override
  String get noListeningHistory => 'No listening history yet';

  @override
  String get removeFolder => 'Remove folder from library';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get playbackQueue => 'Playback queue';

  @override
  String get queue => 'Queue';

  @override
  String get stop => 'Stop';

  @override
  String get repeatOff => 'Repeat off';

  @override
  String get repeatAll => 'Repeat queue';

  @override
  String get repeatOne => 'Repeat track';

  @override
  String get noTrackSelected => 'No track selected';

  @override
  String get live => 'LIVE';

  @override
  String get liveRadio => 'Live radio';

  @override
  String get previousTrack => 'Previous track';

  @override
  String get nextTrack => 'Next track';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get replay => 'Play again';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get closeMessage => 'Dismiss message';

  @override
  String get mountainLake => 'Mountain lake';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get untitled => 'Untitled';

  @override
  String get marusyaTitle => 'Marusya FM';

  @override
  String get europaTitle => 'Europa Plus';

  @override
  String get marusyaDescription => 'Russia · Russian hits';

  @override
  String get europaDescription => 'Russia · Pop music';

  @override
  String get bbcDescription => 'UK · International news';

  @override
  String get comedyUkDescription => 'UK · British stand-up';

  @override
  String get comedyUsDescription => 'USA · Talk comedy';

  @override
  String get invalidAudioUrl =>
      'Enter a direct http:// or https:// URL without a username or password.';

  @override
  String get libraryLoadFailed =>
      'Could not load saved music. Try refreshing your folders.';

  @override
  String get libraryScanFailed =>
      'Could not refresh the library. Check access to your selected folders.';

  @override
  String get folderOpenFailed =>
      'Could not open this folder. Select an accessible music folder.';

  @override
  String get saveFailed => 'Could not save changes. Check available storage.';

  @override
  String get corruptBackup =>
      'A damaged settings file was preserved as a backup.';

  @override
  String get stationUnavailable =>
      'The station is temporarily unavailable. Check your internet connection or choose another station.';

  @override
  String get playbackFailed =>
      'Could not play this track. Check the file and music access.';

  @override
  String get sourceUnavailable =>
      'This track is unavailable. Choose another file or check folder access.';

  @override
  String get toggleFailed => 'Could not change playback.';

  @override
  String get stopFailed => 'Could not stop playback.';

  @override
  String get playerCommandFailed => 'Could not perform the player command.';

  @override
  String get radioRedirects =>
      'Too many radio redirects. The station is unavailable.';

  @override
  String get radioPageTooLarge =>
      'The station returned an unexpected large web page.';

  @override
  String get radioWebsite =>
      'The station returned a website instead of an audio stream.';

  @override
  String get settingsSaveFailed =>
      'Could not save settings. Your previous selection is unchanged.';

  @override
  String trackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks',
      one: '1 track',
      zero: '0 tracks',
    );
    return '$_temp0';
  }

  @override
  String logoLabel(String name) {
    return '$name logo';
  }

  @override
  String foldersUnavailable(String names) {
    return 'Folder access lost: $names. Select them again.';
  }

  @override
  String radioHttp(int status) {
    return 'Radio server returned HTTP $status. The station is temporarily unavailable.';
  }
}
