import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';
import 'logger.dart';

class AudioEngine extends ChangeNotifier {
  late AudioPlayer _player;
  bool _isPlayerReady = false;
  Song? currentSong;
  bool isPlaying = false;
  Duration position = Duration.zero;

  Future<void> init() async {
    try {
      _player = AudioPlayer();
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _player.positionStream.listen((p) { position = p; notifyListeners(); });
      _player.playerStateStream.listen((s) { isPlaying = s.playing; notifyListeners(); });
      _isPlayerReady = true;
      AppLogger.instance.log("Moteur Audio initialisé.");
    } catch (e) { AppLogger.instance.log("Crash Moteur Audio: $e"); }
  }

  Future<void> playLocal(Song song) async {
    if (!_isPlayerReady) return;
    try {
      AppLogger.instance.log("Lecture : ${song.title}");
      currentSong = song;
      final tag = MediaItem(id: song.id, title: song.title, artist: song.artist);
      await _player.setAudioSource(AudioSource.file(song.filePath, tag: tag));
      await _player.play();
    } catch (e) { AppLogger.instance.log("Erreur Play: $e"); }
  }

  Future<void> playUrl(Song song, String url) async {
    if (!_isPlayerReady) return;
    try {
      AppLogger.instance.log("Stream : ${song.title}");
      currentSong = song;
      final tag = MediaItem(id: song.id, title: song.title, artist: song.artist, artUri: Uri.tryParse(song.thumbnailUrl ?? ""));
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: tag));
      await _player.play();
    } catch (e) { AppLogger.instance.log("Erreur Stream: $e"); }
  }

  Future<void> togglePlay() async {
    if (!_isPlayerReady) return;
    if (_player.playing) await _player.pause(); else await _player.play();
  }

  Future<void> seekTo(Duration pos) async => _isPlayerReady ? await _player.seek(pos) : null;
  Stream<Duration> get positionStream => _player.positionStream;
}