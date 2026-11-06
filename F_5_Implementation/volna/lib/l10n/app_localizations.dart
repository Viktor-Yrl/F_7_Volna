import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light — Mist Blue'**
  String get lightTheme;

  /// No description provided for @folderCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not release unused folder access. Refresh the folders to retry.'**
  String get folderCleanupFailed;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @radio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radio;

  /// No description provided for @top100.
  ///
  /// In en, this message translates to:
  /// **'Top 100'**
  String get top100;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @refreshLibrary.
  ///
  /// In en, this message translates to:
  /// **'Refresh library'**
  String get refreshLibrary;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @musicFolders.
  ///
  /// In en, this message translates to:
  /// **'Music folders'**
  String get musicFolders;

  /// No description provided for @noTracksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No available tracks'**
  String get noTracksAvailable;

  /// No description provided for @noListeningHistory.
  ///
  /// In en, this message translates to:
  /// **'No listening history yet'**
  String get noListeningHistory;

  /// No description provided for @removeFolder.
  ///
  /// In en, this message translates to:
  /// **'Remove folder from library'**
  String get removeFolder;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @playbackQueue.
  ///
  /// In en, this message translates to:
  /// **'Playback queue'**
  String get playbackQueue;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @repeatOff.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get repeatOff;

  /// No description provided for @repeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat queue'**
  String get repeatAll;

  /// No description provided for @repeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat track'**
  String get repeatOne;

  /// No description provided for @noTrackSelected.
  ///
  /// In en, this message translates to:
  /// **'No track selected'**
  String get noTrackSelected;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @liveRadio.
  ///
  /// In en, this message translates to:
  /// **'Live radio'**
  String get liveRadio;

  /// No description provided for @previousTrack.
  ///
  /// In en, this message translates to:
  /// **'Previous track'**
  String get previousTrack;

  /// No description provided for @nextTrack.
  ///
  /// In en, this message translates to:
  /// **'Next track'**
  String get nextTrack;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get replay;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @closeMessage.
  ///
  /// In en, this message translates to:
  /// **'Dismiss message'**
  String get closeMessage;

  /// No description provided for @mountainLake.
  ///
  /// In en, this message translates to:
  /// **'Mountain lake'**
  String get mountainLake;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @marusyaTitle.
  ///
  /// In en, this message translates to:
  /// **'Marusya FM'**
  String get marusyaTitle;

  /// No description provided for @europaTitle.
  ///
  /// In en, this message translates to:
  /// **'Europa Plus'**
  String get europaTitle;

  /// No description provided for @marusyaDescription.
  ///
  /// In en, this message translates to:
  /// **'Russia · Russian hits'**
  String get marusyaDescription;

  /// No description provided for @europaDescription.
  ///
  /// In en, this message translates to:
  /// **'Russia · Pop music'**
  String get europaDescription;

  /// No description provided for @bbcDescription.
  ///
  /// In en, this message translates to:
  /// **'UK · International news'**
  String get bbcDescription;

  /// No description provided for @comedyUkDescription.
  ///
  /// In en, this message translates to:
  /// **'UK · British stand-up'**
  String get comedyUkDescription;

  /// No description provided for @comedyUsDescription.
  ///
  /// In en, this message translates to:
  /// **'USA · Talk comedy'**
  String get comedyUsDescription;

  /// No description provided for @capitalDescription.
  ///
  /// In en, this message translates to:
  /// **'UK · Current pop hits'**
  String get capitalDescription;

  /// No description provided for @heartDescription.
  ///
  /// In en, this message translates to:
  /// **'UK · Popular hits'**
  String get heartDescription;

  /// No description provided for @lbcDescription.
  ///
  /// In en, this message translates to:
  /// **'UK · News and talk'**
  String get lbcDescription;

  /// No description provided for @wburDescription.
  ///
  /// In en, this message translates to:
  /// **'USA · News and NPR programs'**
  String get wburDescription;

  /// No description provided for @retroTitle.
  ///
  /// In en, this message translates to:
  /// **'Retro FM'**
  String get retroTitle;

  /// No description provided for @shansonTitle.
  ///
  /// In en, this message translates to:
  /// **'Radio Shanson'**
  String get shansonTitle;

  /// No description provided for @humorTitle.
  ///
  /// In en, this message translates to:
  /// **'Humor FM'**
  String get humorTitle;

  /// No description provided for @retroDescription.
  ///
  /// In en, this message translates to:
  /// **'Russia · Classic hits'**
  String get retroDescription;

  /// No description provided for @shansonDescription.
  ///
  /// In en, this message translates to:
  /// **'Russia · Russian chanson'**
  String get shansonDescription;

  /// No description provided for @humorDescription.
  ///
  /// In en, this message translates to:
  /// **'Russia · Comedy and music'**
  String get humorDescription;

  /// No description provided for @invalidAudioUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a direct http:// or https:// URL without a username or password.'**
  String get invalidAudioUrl;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved music. Try refreshing your folders.'**
  String get libraryLoadFailed;

  /// No description provided for @libraryScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh the library. Check access to your selected folders.'**
  String get libraryScanFailed;

  /// No description provided for @folderOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this folder. Select an accessible music folder.'**
  String get folderOpenFailed;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Check available storage.'**
  String get saveFailed;

  /// No description provided for @corruptBackup.
  ///
  /// In en, this message translates to:
  /// **'A damaged settings file was preserved as a backup.'**
  String get corruptBackup;

  /// No description provided for @stationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The station is temporarily unavailable. Check your internet connection or choose another station.'**
  String get stationUnavailable;

  /// No description provided for @playbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play this track. Check the file and music access.'**
  String get playbackFailed;

  /// No description provided for @sourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This track is unavailable. Choose another file or check folder access.'**
  String get sourceUnavailable;

  /// No description provided for @toggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change playback.'**
  String get toggleFailed;

  /// No description provided for @stopFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not stop playback.'**
  String get stopFailed;

  /// No description provided for @playerCommandFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not perform the player command.'**
  String get playerCommandFailed;

  /// No description provided for @radioRedirects.
  ///
  /// In en, this message translates to:
  /// **'Too many radio redirects. The station is unavailable.'**
  String get radioRedirects;

  /// No description provided for @radioPageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The station returned an unexpected large web page.'**
  String get radioPageTooLarge;

  /// No description provided for @radioWebsite.
  ///
  /// In en, this message translates to:
  /// **'The station returned a website instead of an audio stream.'**
  String get radioWebsite;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings. Your previous selection is unchanged.'**
  String get settingsSaveFailed;

  /// No description provided for @trackCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 tracks} one{1 track} other{{count} tracks}}'**
  String trackCount(int count);

  /// No description provided for @logoLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} logo'**
  String logoLabel(String name);

  /// No description provided for @foldersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Folder access lost: {names}. Select them again.'**
  String foldersUnavailable(String names);

  /// No description provided for @radioHttp.
  ///
  /// In en, this message translates to:
  /// **'Radio server returned HTTP {status}. The station is temporarily unavailable.'**
  String radioHttp(int status);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
