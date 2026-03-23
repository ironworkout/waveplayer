import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';
import '../services/audio_engine.dart';
import 'logger.dart';

class StreamResult {
  final String videoId; final String title; final String artist; final String? thumbnail; final int durationMs;
  StreamResult({required this.videoId, required this.title, required this.artist, this.thumbnail, required this.durationMs});
  Song toSong() => Song.fromStream(id: 'yt_$videoId', title: title, artist: artist, videoId: videoId, durationMs: durationMs, thumbnailUrl: thumbnail);
}

class StreamService extends ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();
  List<StreamResult> results =[];
  bool isLoading = false;
  String? error;
  Map<String, double> downloads = {};

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    isLoading = true; error = null; results =[]; notifyListeners();
    try {
      final searchResults = await _yt.search.search(query);
      results = searchResults.take(25).map((v) => StreamResult(videoId: v.id.value, title: v.title, artist: v.author, thumbnail: v.thumbnails.standardResUrl, durationMs: v.duration?.inMilliseconds ?? 0)).toList();
    } catch (e) { error = 'Erreur : $e'; } finally { isLoading = false; notifyListeners(); }
  }

  Future<String?> getAudioUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      return manifest.audioOnly.withHighestBitrate().url.toString();
    } catch (e) { AppLogger.instance.log("Erreur getAudioUrl: $e"); return null; }
  }

  Future<void> downloadVideo(StreamResult r) async {
    try {
      downloads[r.videoId] = 0.01; notifyListeners();
      AppLogger.instance.log("⬇️ Début téléchargement: ${r.title}");
      
      final manifest = await _yt.videos.streamsClient.getManifest(r.videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = _yt.videos.streamsClient.get(streamInfo);

      final dir = Directory('/storage/emulated/0/Download/WavePlayer');
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final safeTitle = r.title.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final file = File('${dir.path}/$safeTitle.mp3');
      final fileStream = file.openWrite();

      int downloaded = 0;
      final total = streamInfo.size.totalBytes;

      await for (final data in stream) {
        downloaded += data.length;
        downloads[r.videoId] = downloaded / total;
        notifyListeners();
        fileStream.add(data);
      }
      await fileStream.flush(); await fileStream.close();
      downloads.remove(r.videoId); notifyListeners();
      AppLogger.instance.log("✅ MP3 Sauvegardé: ${file.path}");
    } catch (e) {
      downloads.remove(r.videoId); notifyListeners();
      AppLogger.instance.log("❌ Erreur téléchargement: $e");
    }
  }

  @override
  void dispose() { _yt.close(); super.dispose(); }
}