import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_engine.dart';
import '../services/smart_shuffle.dart';
import '../services/stats_service.dart';
import '../widgets/audio_visualizer.dart';

class PlayerScreen extends StatefulWidget {
  final List<Song> queue;
  const PlayerScreen({super.key, required this.queue});
  @override State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  Color _bgColor = const Color(0xFF0D2235);
  late AnimationController _coverAnim;
  bool _shuffle = true;
  bool _repeat = false;

  @override
  void initState() {
    super.initState();
    _coverAnim = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _extractColor();
  }

  Future<void> _extractColor() async {
    final song = context.read<AudioEngine>().currentSong;
    if (song?.thumbnailUrl == null) return;
    try {
      final p = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(song!.thumbnailUrl!),
      );
      if (mounted && p.dominantColor != null) {
        setState(() => _bgColor = p.dominantColor!.color.withOpacity(0.8));
      }
    } catch (_) {}
  }

  @override
  void dispose() { _coverAnim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    return Consumer<AudioEngine>(builder: (ctx, engine, _) {
      final song = engine.currentSong;
      final accent = Theme.of(ctx).colorScheme.primary;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [_bgColor, const Color(0xFF080810)], stops: const [0.0, 0.55],
          )),
          child: SafeArea(child: Column(children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32), onPressed: () => Navigator.pop(ctx)),
                Expanded(child: Text(
                  song?.isStream == true ? '🌐 Streaming' : '📁 Bibliothèque',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF6060A0)),
                )),
                IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
              ]),
            ),

            // ── Cover ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(children: [
                    _buildCover(song),
                    // Visualiseur en bas de la pochette
                    Positioned(bottom: 0, left: 0, right: 0,
                      child: AudioVisualizer(isPlaying: engine.isPlaying, accent: accent)),
                  ]),
                ),
              ),
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
              // ── Info + like ──
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(song?.title ?? '—', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song?.artist ?? 'Choisir une chanson', style: const TextStyle(fontSize: 14, color: Color(0xFF6060A0)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                IconButton(
                  icon: Icon(song?.isLiked == true ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: song?.isLiked == true ? accent : const Color(0xFF6060A0), size: 26),
                  onPressed: () { if (song != null) ctx.read<SmartShuffle>().onLike(song); },
                ),
              ]),

              // Crossfade indicator
              if (engine.isCrossfading) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.blur_on_rounded, size: 14, color: accent.withOpacity(.7)),
                    const SizedBox(width: 6),
                    Text('Crossfade en cours', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: accent.withOpacity(.7))),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // ── Progress bar ──
              StreamBuilder<Duration>(
                stream: engine.positionStream,
                builder: (ctx, snap) {
                  final pos = snap.data ?? Duration.zero;
                  final dur = Duration(milliseconds: song?.durationMs ?? 1);
                  final t = (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);
                  return Column(children: [
                    SliderTheme(
                      data: SliderTheme.of(ctx).copyWith(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                      child: Slider(value: t, onChanged: (v) => engine.seekTo(Duration(milliseconds: (v * dur.inMilliseconds).round()))),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_time(pos), _time(dur)],
                    )),
                  ]);
                },
              ),

              const SizedBox(height: 8),

              // ── Controls ──
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                // Shuffle
                IconButton(
                  icon: Icon(Icons.shuffle_rounded, size: 24,
                    color: _shuffle ? accent : const Color(0xFF6060A0)),
                  onPressed: () => setState(() => _shuffle = !_shuffle),
                ),
                // Prev
                IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 32), onPressed: _prev),
                // Play/Pause
                GestureDetector(
                  onTap: engine.togglePlay,
                  child: Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: accent.withOpacity(.35), blurRadius: 20, spreadRadius: 2)]),
                    child: Icon(engine.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 34),
                  ),
                ),
                // Next
                IconButton(icon: const Icon(Icons.skip_next_rounded, size: 32), onPressed: _next),
                // Repeat
                IconButton(
                  icon: Icon(Icons.repeat_rounded, size: 24,
                    color: _repeat ? accent : const Color(0xFF6060A0)),
                  onPressed: () => setState(() => _repeat = !_repeat),
                ),
              ]),
            ])),
          ])),
        ),
      );
    });
  }

  Widget _buildCover(Song? song) {
    if (song == null) return Container(color: const Color(0xFF161625), child: const Icon(Icons.music_note_rounded, size: 80, color: Color(0xFF2A2A45)));
    if (song.isStream && song.thumbnailUrl != null) {
      return CachedNetworkImage(imageUrl: song.thumbnailUrl!, fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _emojiCover());
    }
    return _emojiCover();
  }

  Widget _emojiCover() => Container(
    color: const Color(0xFF161625),
    child: const Center(child: Text('🎵', style: TextStyle(fontSize: 80))),
  );

  Widget _time(Duration d) => Text(
    '${d.inMinutes.toString().padLeft(2,'0')}:${(d.inSeconds%60).toString().padLeft(2,'0')}',
    style: const TextStyle(fontSize: 11, color: Color(0xFF6060A0), fontVariations: [FontVariation('wght', 600)]),
  );

  void _next() {
    final shuffle = context.read<SmartShuffle>();
    final engine = context.read<AudioEngine>();
    final next = _shuffle ? shuffle.pickNext(widget.queue) : _linearNext();
    if (next == null) return;
    engine.playLocal(next);
  }

  void _prev() {
    final engine = context.read<AudioEngine>();
    final cur = engine.currentSong;
    if (cur == null) return;
    final idx = widget.queue.indexWhere((s) => s.id == cur.id);
    if (idx <= 0) return;
    engine.playLocal(widget.queue[idx - 1]);
  }

  Song? _linearNext() {
    final cur = context.read<AudioEngine>().currentSong;
    if (cur == null) return widget.queue.firstOrNull;
    final idx = widget.queue.indexWhere((s) => s.id == cur.id);
    if (idx < 0 || idx >= widget.queue.length - 1) return widget.queue.firstOrNull;
    return widget.queue[idx + 1];
  }
}
