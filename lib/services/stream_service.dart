import 'dart:io';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
      final s = await _yt.search.search(q);
      results = s.take(20).map((v) => StreamResult(videoId: v.id.value, title: v.title, artist: v.author, thumbnail: v.thumbnails.standardResUrl, durationMs: v.duration?.inMilliseconds ?? 0)).toList();
    } catch (e) { AppLogger.instance.log("Erreur recherche: $e"); }
    isLoading = false; notifyListeners();
  }

  Future<String?> getAudioUrl(String id) async {
    final manifest = await _yt.videos.streamsClient.getManifest(id);
    return manifest.audioOnly.withHighestBitrate().url.toString();
  }

  Future<void> downloadVideo(StreamResult r, BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Téléchargement de ${r.title}...")));
      downloads[r.videoId] = 0.1; notifyListeners();
      
      final manifest = await _yt.videos.streamsClient.getManifest(r.videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(streamInfo);

      final dir = Directory('/storage/emulated/0/Download/WavePlayer');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final file = File("${dir.path}/${r.videoId}.mp3");
      final sink = file.openWrite();
      await for (final data in stream) { sink.add(data); }
      await sink.close();

      downloads.remove(r.videoId); notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Terminé ! Disponible en Bibliothèque")));
      AppLogger.instance.log("Téléchargé: ${file.path}");
    } catch (e) { 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Erreur téléchargement")));
      downloads.remove(r.videoId); notifyListeners();
    }
  }
}