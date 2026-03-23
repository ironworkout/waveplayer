import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

class FileScanner extends ChangeNotifier {
  final OnAudioQuery _query = OnAudioQuery();
  bool isScanning = false;
  int songsFound = 0;

  List<Song> get allSongs {
    final box = Hive.box<Song>('songs');
    return box.values.where((s) => s.sourceStr == 'local').toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  Future<bool> requestPermission() async {
    // Android 13+ : READ_MEDIA_AUDIO ; Android ≤12 : READ_EXTERNAL_STORAGE
    final status = await Permission.audio.request();
    if (status.isGranted) return true;
    final status2 = await Permission.storage.request();
    return status2.isGranted;
  }

  Future<void> scanAll() async {
    if (!await requestPermission()) return;
    isScanning = true;
    notifyListeners();

    final songs = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final box = Hive.box<Song>('songs');
    int added = 0;

    for (final s in songs) {
      if (s.fileExtension?.toLowerCase() != 'mp3') continue;
      if ((s.duration ?? 0) < 30000) continue; // ignore < 30s
      final key = s.id.toString();
      if (!box.containsKey(key)) {
        final song = Song.fromLocal(
          id: key,
          title: s.title,
          artist: s.artist ?? 'Artiste inconnu',
          album: s.album ?? 'Album inconnu',
          filePath: s.data,
          durationMs: s.duration ?? 0,
        );
        await box.put(key, song);
        added++;
      }
    }

    songsFound = box.values.where((s) => s.sourceStr == 'local').length;
    isScanning = false;
    notifyListeners();
  }

  Future<List<int>?> getArtwork(Song song) async {
    return _query.queryArtwork(
      int.parse(song.id),
      ArtworkType.AUDIO,
      quality: 100,
      size: 512,
    );
  }
}
