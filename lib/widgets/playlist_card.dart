import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/audio_engine.dart';
import '../screens/player_screen.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext ctx) {
    final box = Hive.box<Song>('songs');
    final songs = playlist.songIds.map((id) => box.get(id)).whereType<Song>().take(4).toList();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          final allSongs = playlist.songIds.map((id) => box.get(id)).whereType<Song>().toList();
          if (allSongs.isNotEmpty) {
            ctx.read<AudioEngine>().playLocal(allSongs.first, newQueue: allSongs);
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerScreen(queue: allSongs)));
          }
        },
        child: Container(
          width: 130,
          decoration: BoxDecoration(color: const Color(0xFF12121F), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF1E1E32))),
          child: Center(child: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}