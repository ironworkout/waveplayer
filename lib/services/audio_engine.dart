import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class AudioEngine extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;
  List<Song> queue = [];
  bool isPlaying = false;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) playNext();
      notifyListeners();
    });
  }

  Future<void> playLocal(Song song, {List<Song>? newQueue}) async {
    if (newQueue != null) queue = newQueue;
    currentSong = song;
    notifyListeners();
    await _player.setAudioSource(AudioSource.file(song.filePath, tag: MediaItem(id: song.id, title: song.title, artist: song.artist)));
    await _player.play();
  }

  Future<void> playUrl(Song song, String url) async {
    currentSong = song;
    notifyListeners();
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: MediaItem(id: song.id, title: song.title, artist: song.artist)));
    await _player.play();
  }

  void togglePlay() { if (_player.playing) _player.pause(); else _player.play(); }
  
  void playNext() {
    if (queue.isEmpty || currentSong == null) return;
    int idx = queue.indexWhere((s) => s.id == currentSong!.id);
    if (idx < queue.length - 1) playLocal(queue[idx + 1]);
  }

  void playPrev() {
    if (queue.isEmpty || currentSong == null) return;
    int idx = queue.indexWhere((s) => s.id == currentSong!.id);
    if (idx > 0) playLocal(queue[idx - 1]);
  }

  void seekTo(Duration p) => _player.seek(p);
  Stream<Duration> get positionStream => _player.positionStream;
}