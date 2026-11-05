import 'package:flutter/foundation.dart';
import '../data/library_store.dart';
import '../l10n/ui_message.dart';

/// Defaults to English independently of the device language and persists overrides.
class AppSettings extends ChangeNotifier {
  AppSettings(this.store);
  final LibraryStore store;
  String languageCode = 'en';
  bool lightTheme = false;
  bool saving = false, _disposed = false;
  UiMessage? error;
  void clearError() {
    error = null;
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final data = await store.read('settings');
      if (_disposed) return;
      languageCode = data['language'] == 'ru' ? 'ru' : 'en';
      lightTheme = data['theme'] == 'light';
      notifyListeners();
    } catch (_) {
      /* A missing language preference falls back to English. */
    }
  }

  Future<void> setLanguage(String code) => _save(code, lightTheme);

  Future<void> setLightTheme(bool light) => _save(languageCode, light);

  Future<void> _save(String code, bool light) async {
    if (_disposed || saving || !['en', 'ru'].contains(code)) return;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await store.write('settings', {
        'language': code,
        'theme': light ? 'light' : 'dark',
      });
      if (!_disposed) {
        languageCode = code;
        lightTheme = light;
      }
    } catch (_) {
      error = const UiMessage(MessageId.settingsSaveFailed);
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
