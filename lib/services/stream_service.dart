import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';

class StreamResult {
  final String videoId, title, artist;
  final String? thumbnail;
  final int durationMs;
  StreamResult({required this.videoId, required this.title, required this.artist, this.thumbnail, required this.durationMs});
  Song toSong() => Song.fromStream(id: 'yt_$videoId', title: title, artist: artist, videoId: videoId, durationMs: durationMs, thumbnailUrl: thumbnail);
}

class StreamService extends ChangeNotifier {
  final _yt = YoutubeExplode();
  List<StreamResult> results = [];
  bool isLoading = false;
  String? error;
  final Map<String, double> downloads = {};

  Future<void> search(String q) async {
    if (q.trim().isEmpty) return;
    isLoading = true; error = null; results = []; notifyListeners();
    try {
      final s = await _yt.search.search(q);
      results = s.take(20).map((v) => StreamResult(
        videoId: v.id.value, title: v.title, artist: v.author,
        thumbnail: v.thumbnails.standardResUrl,
        durationMs: v.duration?.inMilliseconds ?? 0,
      )).toList();
    } catch (e) {
      error = 'Erreur : $e';
      debugPrint('[Stream] search error: $e');
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<String?> getAudioUrl(String id) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(id);
      return manifest.audioOnly.withHighestBitrate().url.toString();
    } catch (e) { debugPrint('[Stream] url error: $e'); return null; }
  }

  Future<String?> downloadVideo(StreamResult r) async {
    try {
      downloads[r.videoId] = 0.0; notifyListeners();
      // Android 13 compatible : pas besoin de MANAGE_EXTERNAL_STORAGE
      final extDir = await getExternalStorageDirectory();
      final base = extDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      final dir = Directory('$base/WavePlayer');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/${r.videoId}.mp3');
      if (file.existsSync()) {
        downloads.remove(r.videoId); notifyListeners();
        return file.path;
      }
      final manifest = await _yt.videos.streamsClient.getManifest(r.videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final total = streamInfo.size.totalBytes;
      final stream = _yt.videos.streamsClient.get(streamInfo);
      final sink = file.openWrite();
      int received = 0;
      await for (final data in stream) {
        sink.add(data);
        received += data.length;
        if (total > 0) { downloads[r.videoId] = received / total; notifyListeners(); }
      }
      await sink.flush(); await sink.close();
      downloads.remove(r.videoId); notifyListeners();
      debugPrint('[Stream] Telecharge : ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('[Stream] download error: $e');
      downloads.remove(r.videoId); notifyListeners();
      return null;
    }
  }

  Future<bool> isDownloaded(String videoId) async {
    final extDir = await getExternalStorageDirectory();
    final base = extDir?.path ?? (await getApplicationDocumentsDirectory()).path;
    return File('$base/WavePlayer/$videoId.mp3').existsSync();
  }

  @override
  void dispose() { _yt.close(); super.dispose(); }
}