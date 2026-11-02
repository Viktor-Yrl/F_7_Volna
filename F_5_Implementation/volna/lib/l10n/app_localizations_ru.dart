// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get savedDeviceTracks => 'Сохранённые треки телефона';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get radio => 'Радио';

  @override
  String get top100 => 'Топ-100';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get refreshLibrary => 'Обновить медиатеку';

  @override
  String get addFolder => 'Добавить папку';

  @override
  String get musicFolders => 'Музыкальные папки';

  @override
  String get noTracksAvailable => 'Нет доступных треков';

  @override
  String get noListeningHistory => 'Пока нет прослушиваний';

  @override
  String get removeFavorite => 'Убрать из избранного';

  @override
  String get favorite => 'В избранное';

  @override
  String get removeFolder => 'Убрать папку из медиатеки';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get playbackQueue => 'Очередь воспроизведения';

  @override
  String get queue => 'Очередь';

  @override
  String get stop => 'Остановить';

  @override
  String get repeatOff => 'Повтор выключен';

  @override
  String get repeatAll => 'Повтор очереди';

  @override
  String get repeatOne => 'Повтор трека';

  @override
  String get noTrackSelected => 'Нет выбранного трека';

  @override
  String get live => 'ПРЯМОЙ ЭФИР';

  @override
  String get liveRadio => 'Прямой эфир';

  @override
  String get previousTrack => 'Предыдущий трек';

  @override
  String get nextTrack => 'Следующий трек';

  @override
  String get play => 'Воспроизвести';

  @override
  String get pause => 'Пауза';

  @override
  String get replay => 'Слушать снова';

  @override
  String get shuffle => 'Случайный порядок';

  @override
  String get closeMessage => 'Закрыть сообщение';

  @override
  String get mountainLake => 'Горное озеро';

  @override
  String get unknownArtist => 'Неизвестный исполнитель';

  @override
  String get untitled => 'Без названия';

  @override
  String get downloadedFile => 'Загруженный файл';

  @override
  String get marusyaTitle => 'Маруся FM';

  @override
  String get europaTitle => 'Европа Плюс';

  @override
  String get marusyaDescription => 'Россия · Русские хиты';

  @override
  String get europaDescription => 'Россия · Поп-музыка';

  @override
  String get bbcDescription => 'Великобритания · Международные новости';

  @override
  String get comedyUkDescription => 'Великобритания · Британский стендап';

  @override
  String get comedyUsDescription => 'США · Разговорный юмор';

  @override
  String get invalidAudioUrl =>
      'Введите прямую ссылку http:// или https:// без логина и пароля.';

  @override
  String get libraryLoadFailed =>
      'Не удалось прочитать сохранённую музыку. Обновите выбранные папки.';

  @override
  String get libraryScanFailed =>
      'Не удалось обновить медиатеку. Проверьте разрешение на музыку в настройках Android.';

  @override
  String get folderOpenFailed =>
      'Не удалось открыть папку. Выберите доступную папку с музыкой.';

  @override
  String get saveFailed =>
      'Не удалось сохранить изменения. Проверьте свободное место.';

  @override
  String get corruptBackup =>
      'Поврежденный файл настроек сохранен в резервную копию.';

  @override
  String get stationUnavailable =>
      'Станция временно недоступна. Проверьте интернет или выберите другую станцию.';

  @override
  String get playbackFailed =>
      'Не удалось воспроизвести запись. Проверьте файл или доступ к музыке.';

  @override
  String get sourceUnavailable =>
      'Запись недоступна. Выберите другой файл или проверьте доступ к папке.';

  @override
  String get toggleFailed => 'Не удалось изменить воспроизведение.';

  @override
  String get stopFailed => 'Не удалось остановить проигрыватель.';

  @override
  String get playerCommandFailed =>
      'Не удалось выполнить команду проигрывателя.';

  @override
  String get radioRedirects =>
      'Слишком много переходов радио. Станция недоступна.';

  @override
  String get radioPageTooLarge =>
      'Станция вернула слишком большую веб-страницу.';

  @override
  String get radioWebsite => 'Станция вернула сайт вместо аудиопотока.';

  @override
  String get settingsSaveFailed =>
      'Не удалось сохранить язык. Предыдущий выбор не изменён.';

  @override
  String trackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count трека',
      many: '$count треков',
      few: '$count трека',
      one: '$count трек',
      zero: '0 треков',
    );
    return '$_temp0';
  }

  @override
  String logoLabel(String name) {
    return 'Логотип $name';
  }

  @override
  String foldersUnavailable(String names) {
    return 'Нет доступа к папкам: $names. Выберите их заново.';
  }

  @override
  String radioHttp(int status) {
    return 'Сервер радио ответил HTTP $status. Станция временно недоступна.';
  }

  @override
  String get savedFiles => 'Сохранённые файлы';
}
