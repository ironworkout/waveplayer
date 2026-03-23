import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';
import '../services/audio_engine.dart';
import '../services/smart_shuffle.dart';
import '../widgets/audio_visualizer.dart';

class PlayerScreen extends StatefulWidget {
  final List<Song> queue;
  const PlayerScreen({super.key, required this.queue});
  @override State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  Color _bgColor = const Color(0xFF0D2235);
  bool _shuffle = true;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  Future<void> _extractColor() async {
    final song = context.read<AudioEngine>().currentSong;
    if (song?.thumbnailUrl == null) return;
    try {
      final p = await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(song!.thumbnailUrl!));
      if (mounted && p.dominantColor != null) setState(() => _bgColor = p.dominantColor!.color.withOpacity(0.8));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext ctx) {
    return Consumer<AudioEngine>(builder: (ctx, engine, _) {
      final song = engine.currentSong;
      final accent = Theme.of(context).colorScheme.primary;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [_bgColor, const Color(0xFF080810)], stops: const [0.0, 0.55],
          )),
          child: SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32), onPressed: () => Navigator.pop(ctx)),
                Expanded(child: Text(song?.isStream == true ? '🌐 Streaming' : '📁 Bibliothèque', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6060A0)))),
                IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: AspectRatio(aspectRatio: 1, child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Stack(children: [
                Positioned.fill(child: _buildCover(song)),
                Positioned(bottom: 0, left: 0, right: 0, child: AudioVisualizer(isPlaying: engine.isPlaying, accent: accent)),
              ]))),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(song?.title ?? '—', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900), maxLines: 1),
                  Text(song?.artist ?? '...', style: const TextStyle(fontSize: 14, color: Color(0xFF6060A0))),
                ])),
                IconButton(icon: Icon(song?.isLiked == true ? Icons.favorite : Icons.favorite_border, color: song?.isLiked == true ? accent : const Color(0xFF6060A0)), onPressed: () => ctx.read<SmartShuffle>().onLike(song!)),
              ]),
              const SizedBox(height: 12),
              StreamBuilder<Duration>(
                stream: engine.positionStream,
                builder: (ctx, snap) {
                  final pos = snap.data ?? Duration.zero;
                  final dur = Duration(milliseconds: song?.durationMs ?? 1);
                  return Column(children: [
                    Slider(value: (pos.inMilliseconds / dur.inMilliseconds).clamp(0, 1), onChanged: (v) => engine.seekTo(Duration(milliseconds: (v * dur.inMilliseconds).round()))),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_fmt(pos)), Text(_fmt(dur))]),
                  ]);
                },
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                IconButton(icon: Icon(Icons.shuffle, color: _shuffle ? accent : const Color(0xFF6060A0)), onPressed: () => setState(() => _shuffle = !_shuffle)),
                IconButton(icon: const Icon(Icons.skip_previous, size: 32), onPressed: () => engine.playLocal(widget.queue.first)),
                GestureDetector(onTap: engine.togglePlay, child: CircleAvatar(radius: 34, backgroundColor: accent, child: Icon(engine.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black))),
                IconButton(icon: const Icon(Icons.skip_next, size: 32), onPressed: () => engine.playLocal(widget.queue.last)),
                IconButton(icon: const Icon(Icons.repeat, color: Color(0xFF6060A0)), onPressed: () {}),
              ]),
            ])),
          ])),
        ),
      );
    });
  }

  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildCover(Song? song) {
    if (song == null) return Container(color: Colors.black);
    if (song.sourceStr == 'local') return QueryArtworkWidget(id: int.parse(song.id), type: ArtworkType.AUDIO, artworkFit: BoxFit.cover, nullArtworkWidget: Container(color: Colors.black));
    return CachedNetworkImage(imageUrl: song.thumbnailUrl ?? '', fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.black));
  }
}