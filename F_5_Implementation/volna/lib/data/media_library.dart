import 'dart:io';

import 'package:flutter/services.dart';

import 'models.dart';

/// Android document-tree access and restoration of legacy track IDs.
class MediaLibrary {
  static const _channel = MethodChannel('music_player_full/library');
  bool get supported => Platform.isAndroid;
  Future<MusicFolder?> pickFolder() async {
    if (!supported) return null;
    final data = await _channel.invokeMapMethod<String, dynamic>('pickFolder');
    return data == null
        ? null
        : MusicFolder.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<Track>> scanFolder(String uri) async {
    final rows =
        await _channel.invokeListMethod<dynamic>('scanFolder', {'uri': uri}) ??
        [];
    return rows
        .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> requestNotifications() async {
    if (supported) await _channel.invokeMethod<bool>('requestNotifications');
  }

  Future<List<Track>> restoreLegacyTracks(List<String> ids) async {
    if (!supported || ids.isEmpty) return [];
    final rows =
        await _channel.invokeListMethod<dynamic>('restoreLegacyTracks', {
          'ids': ids,
        }) ??
        [];
    return rows
        .map((row) => Track.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }
}
