import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';
import 'logger.dart';

class StreamResult {
  final String videoId, title, artist; final String? thumbnail; final int durationMs;
  StreamResult({required this.videoId, required this.title, required this.artist, this.thumbnail, required this.durationMs});
  Song toSong() => Song.fromStream(id: 'yt_$videoId', title: title, artist: artist, videoId: videoId, durationMs: durationMs, thumbnailUrl: thumbnail);
}

class StreamService extends ChangeNotifier {
  final _yt = YoutubeExplode();
  List<StreamResult> results = [];
  bool isLoading = false;
  Map<String, double> downloads = {};

  Future<void> search(String q) async {
    isLoading = true; notifyListeners();
    try {
      final search = await _yt.search.search(q);
      results = search.take(20).map((v) => StreamResult(videoId: v.id.value, title: v.title, artist: v.author, thumbnail: v.thumbnails.standardResUrl, durationMs: v.duration?.inMilliseconds ?? 0)).toList();
    } catch (e) { AppLogger.instance.log("Erreur Recherche: $e"); }
    isLoading = false; notifyListeners();
  }

  Future<String?> getAudioUrl(String id) async {
    final manifest = await _yt.videos.streamsClient.getManifest(id);
    return manifest.audioOnly.withHighestBitrate().url.toString();
  }

  Future<void> downloadVideo(StreamResult r) async {
    try {
      downloads[r.videoId] = 0.1; notifyListeners();
      AppLogger.instance.log("Téléchargement de : ${r.title}");
      
      final manifest = await _yt.videos.streamsClient.getManifest(r.videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(streamInfo);

      // Dossier spécial WavePlayer dans Téléchargements
      final dir = Directory('/storage/emulated/0/Download/WavePlayer');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final file = File("${dir.path}/${r.videoId}.mp3");
      final sink = file.openWrite();
      
      await for (final data in stream) { sink.add(data); }
      await sink.close();

      downloads.remove(r.videoId); notifyListeners();
      AppLogger.instance.log("✅ Fichier sauvegardé dans Downloads/WavePlayer");
    } catch (e) { 
      AppLogger.instance.log("Erreur Téléchargement: $e");
      downloads.remove(r.videoId); notifyListeners();
    }
  }
}