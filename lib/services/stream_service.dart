import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';
import '../services/audio_engine.dart';

class StreamResult {
  final String videoId;
  final String title;
  final String artist;
  final String? thumbnail;
  final int durationMs;

  StreamResult({
    required this.videoId,
    required this.title,
    required this.artist,
    this.thumbnail,
    required this.durationMs,
  });

  Song toSong() => Song.fromStream(
    id: 'yt_$videoId',
    title: title,
    artist: artist,
    videoId: videoId,
    durationMs: durationMs,
    thumbnailUrl: thumbnail,
  );
}

class StreamService extends ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();
  List<StreamResult> results = [];
  bool isLoading = false;
  String? error;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    isLoading = true;
    error = null;
    results = [];
    notifyListeners();

    try {
      final searchResults = await _yt.search.search(query);
      results = searchResults
          .take(25)
          .map((v) => StreamResult(
                videoId: v.id.value,
                title: v.title,
                artist: v.author,
                thumbnail: v.thumbnails.standardResUrl,
                durationMs: v.duration?.inMilliseconds ?? 0,
              ))
          .toList();
    } catch (e) {
      error = 'Erreur : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAudioUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioOnly = manifest.audioOnly;
      if (audioOnly.isEmpty) return null;
      return audioOnly.withHighestBitrate().url.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> playVideo(String videoId, AudioEngine engine) async {
    final url = await getAudioUrl(videoId);
    if (url == null) return;
    final r = results.firstWhere(
      (r) => r.videoId == videoId,
      orElse: () => StreamResult(videoId: videoId, title: '', artist: '', durationMs: 0),
    );
    await engine.playUrl(r.toSong(), url);
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }
}
