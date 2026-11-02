import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../l10n/ui_message.dart';

/// Serializes JSON writes and preserves corrupt files for later recovery.
class LibraryStore {
  LibraryStore({Future<Directory>? directory})
    : _directory = directory ?? getApplicationSupportDirectory();
  final Future<Directory> _directory;
  Future<void> _writes = Future.value();
  UiMessage? warning;

  Future<Directory> get directory async {
    final root = await _directory;
    await root.create(recursive: true);
    return root;
  }

  Future<Map<String, dynamic>> read(String name) async {
    final file = File(p.join((await directory).path, '$name.json'));
    if (!await file.exists()) return {};
    try {
      return (jsonDecode(await file.readAsString()) as Map)
          .cast<String, dynamic>();
    } catch (_) {
      // Preserve the damaged source instead of silently overwriting user data.
      await file.copy(
        '${file.path}.corrupt-${DateTime.now().millisecondsSinceEpoch}',
      );
      warning = const UiMessage(MessageId.corruptBackup);
      return {};
    }
  }

  Future<void> write(String name, Map<String, dynamic> data) {
    final snapshot = jsonEncode(data);
    final operation = _writes.then((_) async {
      final file = File(p.join((await directory).path, '$name.json'));
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(snapshot, flush: true);
      await temp.rename(file.path);
    });
    // A failed write must not block subsequent snapshots in the queue.
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> flush() => _writes;
}
