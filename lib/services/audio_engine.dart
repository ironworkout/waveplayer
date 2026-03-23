import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';
import 'logger.dart';

class AudioEngine extends ChangeNotifier {
  final AudioPlayer _active = AudioPlayer();
  Song? currentSong;
  bool isPlaying = false;
  bool isCrossfading = false;
  Duration position = Duration.zero;

  Future<void> init() async {
    try {
      AppLogger.instance.log("Initialisation AudioEngine...");
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _active.positionStream.listen((p) { position = p; notifyListeners(); });
      _active.playerStateStream.listen(_onState);
      AppLogger.instance.log("AudioEngine prêt.");
    } catch (e) { AppLogger.instance.log("CRASH INIT AUDIO: $e"); }
  }

  Future<void> playLocal(Song song) async {
    try {
      AppLogger.instance.log("▶️ Lecture Locale: ${song.title}");
      AppLogger.instance.log("Chemin: ${song.filePath}");
      currentSong = song; notifyListeners();
      final tag = MediaItem(id: song.id, title: song.title, artist: song.artist);
      await _active.setAudioSource(AudioSource.file(song.filePath, tag: tag));
      await _active.play();
      AppLogger.instance.log("✅ Lecture réussie");
    } catch (e) { AppLogger.instance.log("❌ ERREUR AUDIO: $e"); }
  }

  Future<void> playUrl(Song song, String audioUrl) async {
    try {
      AppLogger.instance.log("▶️ Lecture Stream: ${song.title}");
      currentSong = song; notifyListeners();
      final tag = MediaItem(id: song.id, title: song.title, artist: song.artist, artUri: song.thumbnailUrl != null ? Uri.parse(song.thumbnailUrl!) : null);
      await _active.setAudioSource(AudioSource.uri(Uri.parse(audioUrl), tag: tag));
      await _active.play();
      AppLogger.instance.log("✅ Lecture Stream réussie");
    } catch (e) { AppLogger.instance.log("❌ ERREUR STREAM: $e"); }
  }

  void _onState(PlayerState s) {
    isPlaying = s.playing;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    try {
      if (_active.playing) await _active.pause(); else await _active.play();
    } catch (e) { AppLogger.instance.log("Erreur Play/Pause: $e"); }
  }
  Future<void> seekTo(Duration pos) async => await _active.seek(pos);
  Stream<Duration> get positionStream => _active.positionStream;
}