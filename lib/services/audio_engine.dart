import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class AudioEngine extends ChangeNotifier {
  // ── Deux players pour le crossfade ────────────
  final AudioPlayer _playerA = AudioPlayer();
  final AudioPlayer _playerB = AudioPlayer();
  bool _usingA = true;

  AudioPlayer get _active => _usingA ? _playerA : _playerB;
  AudioPlayer get _nextP  => _usingA ? _playerB : _playerA;

  // ── État public ────────────────────────────────
  Song? currentSong;
  bool isPlaying = false;
  bool isCrossfading = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  int crossfadeDurationMs = 5000;

  StreamSubscription? _posSub;
  StreamSubscription? _stateSub;

  // ── Init ───────────────────────────────────────
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _active.positionStream.listen(_onPosition);
    _active.playerStateStream.listen(_onState);
  }

  // ── Jouer un fichier local ─────────────────────
  Future<void> playLocal(Song song) async {
    currentSong = song;
    isCrossfading = false;

    final tag = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: Duration(milliseconds: song.durationMs),
    );

    await _active.setAudioSource(
      AudioSource.file(song.filePath, tag: tag),
    );
    await _active.setVolume(1.0);
    await _active.play();

    isPlaying = true;
    _listenPosition();
    notifyListeners();
  }

  // ── Jouer un stream audio (URL directe depuis youtube_explode) ──
  Future<void> playUrl(Song song, String audioUrl) async {
    currentSong = song;
    isCrossfading = false;

    final tag = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      artUri: song.thumbnailUrl != null ? Uri.parse(song.thumbnailUrl!) : null,
      duration: Duration(milliseconds: song.durationMs),
    );

    await _active.setAudioSource(
      AudioSource.uri(Uri.parse(audioUrl), tag: tag),
    );
    await _active.setVolume(1.0);
    await _active.play();

    isPlaying = true;
    _listenPosition();
    notifyListeners();
  }

  // ── Crossfade automatique ──────────────────────
  void _onPosition(Duration pos) {
    position = pos;
    if (currentSong == null) return;

    final remaining = (currentSong!.durationMs - pos.inMilliseconds);
    if (remaining <= crossfadeDurationMs && !isCrossfading && remaining > 0) {
      isCrossfading = true;
      notifyListeners();
    }
  }

  // ── Lance le fondu vers la prochaine source ────
  Future<void> crossfadeTo(Song next, String? audioUrl) async {
    // Prépare le next player à volume 0
    if (next.isStream && audioUrl != null) {
      await _nextP.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    } else {
      await _nextP.setAudioSource(AudioSource.file(next.filePath));
    }
    await _nextP.setVolume(0.0);
    await _nextP.play();

    const steps = 50;
    final stepMs = crossfadeDurationMs ~/ steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(Duration(milliseconds: stepMs));
      final t = i / steps;
      _active.setVolume((1.0 - t).clamp(0.0, 1.0));
      _nextP.setVolume(t.clamp(0.0, 1.0));
    }

    await _active.stop();
    _usingA = !_usingA;
    currentSong = next;
    isCrossfading = false;
    notifyListeners();
  }

  // ── Contrôles ─────────────────────────────────
  Future<void> pause() async {
    await _active.pause();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _active.play();
    isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (isPlaying) await pause(); else await resume();
  }

  Future<void> seekTo(Duration pos) async {
    await _active.seek(pos);
  }

  Future<void> next() async => _active.seek(_active.duration ?? Duration.zero);

  // ── Streams ────────────────────────────────────
  Stream<Duration> get positionStream => _active.positionStream;
  Stream<Duration?> get durationStream => _active.durationStream;
  Stream<PlayerState> get stateStream  => _active.playerStateStream;

  void _listenPosition() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _posSub  = _active.positionStream.listen(_onPosition);
    _stateSub = _active.playerStateStream.listen(_onState);
  }

  void _onState(PlayerState s) {
    isPlaying = s.playing;
    if (s.processingState == ProcessingState.completed) {
      isPlaying = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _playerA.dispose();
    _playerB.dispose();
    super.dispose();
  }
}
