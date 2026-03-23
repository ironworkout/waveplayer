import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../services/audio_engine.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext ctx) {
    final engine = ctx.watch<AudioEngine>();
    final song = engine.currentSong;
    if (song == null) return const SizedBox.shrink();
    final accent = Theme.of(ctx).colorScheme.primary;

    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(
        builder: (_) => PlayerScreen(queue: engine.queue))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161625),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E1E32)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.4), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 42, height: 42,
                child: song.thumbnailUrl != null
                    ? CachedNetworkImage(imageUrl: song.thumbnailUrl!, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _thumb())
                    : _thumb()),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(song.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(song.artist, style: const TextStyle(fontSize: 11, color: Color(0xFF6060A0)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: song.isStream ? Colors.red.withOpacity(.12) : accent.withOpacity(.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(song.isStream ? 'YT' : 'MP3',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                  color: song.isStream ? Colors.redAccent : accent)),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, size: 22),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => engine.playPrev(),
            ),
            GestureDetector(
              onTap: engine.togglePlay,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: Icon(engine.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 20),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 22),
              padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => engine.playNext(),
            ),
          ]),
          const SizedBox(height: 8),
          StreamBuilder<Duration>(
            stream: engine.positionStream,
            builder: (ctx, snap) {
              final pos = snap.data?.inMilliseconds ?? 0;
              final tot = song.durationMs == 0 ? 1 : song.durationMs;
              return LinearProgressIndicator(
                value: (pos / tot).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF2A2A45),
                color: accent, minHeight: 2,
                borderRadius: BorderRadius.circular(1),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _thumb() => Container(color: const Color(0xFF0F0F1A), child: const Center(child: Text('🎵', style: TextStyle(fontSize: 18))));
}