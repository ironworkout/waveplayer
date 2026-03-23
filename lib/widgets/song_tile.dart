import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';
import '../services/audio_engine.dart';
import '../services/smart_shuffle.dart';

class SongTile extends StatelessWidget {
  final Song song; final VoidCallback onTap; final String? thumbnail; final Widget? trailing;
  const SongTile({super.key, required this.song, required this.onTap, this.thumbnail, this.trailing});

  @override
  Widget build(BuildContext ctx) {
    final engine = ctx.watch<AudioEngine>();
    final accent = Theme.of(ctx).colorScheme.primary;
    final isPlaying = engine.currentSong?.id == song.id;

    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(children:[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 48, height: 48, child: Stack(children:[
              _buildThumb(thumbnail ?? song.thumbnailUrl, isPlaying),
              if (isPlaying) Container(color: accent.withOpacity(0.28)),
              if (isPlaying) Center(child: Icon(engine.isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded, color: accent, size: 20)),
            ])),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(song.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isPlaying ? accent : const Color(0xFFEEEEFF)), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(song.artist, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6060A0)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          trailing ?? GestureDetector(
            onTap: () => ctx.read<SmartShuffle>().onLike(song),
            behavior: HitTestBehavior.opaque,
            child: Padding(padding: const EdgeInsets.all(6), child: Icon(song.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: song.isLiked ? accent : const Color(0xFF6060A0), size: 18)),
          ),
        ]),
      ),
    );
  }

  Widget _buildThumb(String? url, bool isPlaying) {
    if (song.sourceStr == 'local') return QueryArtworkWidget(id: int.parse(song.id), type: ArtworkType.AUDIO, nullArtworkWidget: _defaultThumb(), artworkBorder: BorderRadius.zero);
    if (url != null) return CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, errorWidget: (_, __, ___) => _defaultThumb());
    return _defaultThumb();
  }
  Widget _defaultThumb() => Container(color: const Color(0xFF161625), child: const Center(child: Text('🎵', style: TextStyle(fontSize: 22))));
}