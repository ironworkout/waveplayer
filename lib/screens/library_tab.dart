import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/song.dart';
import '../services/file_scanner.dart';
import '../services/audio_engine.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<FileScanner>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          title: const Text("Ma Musique", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [IconButton(icon: const Icon(Icons.sync), onPressed: () => scanner.scanAll())],
        ),
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Text("DERNIERS AJOUTS", style: TextStyle(fontSize: 12, color: Colors.grey)))),
        ValueListenableBuilder(
          valueListenable: Hive.box<Song>('songs').listenable(),
          builder: (context, Box<Song> box, _) {
            final songs = box.values.toList().reversed.take(5).toList();
            return SliverToBoxAdapter(
              child: SizedBox(height: 180, child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: songs.length,
                itemBuilder: (ctx, i) => _RecentCard(song: songs[i]),
              )),
            );
          }
        ),
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(16), child: Text("TOUS MES TITRES", style: TextStyle(fontSize: 12, color: Colors.grey)))),
        ValueListenableBuilder(
          valueListenable: Hive.box<Song>('songs').listenable(),
          builder: (context, Box<Song> box, _) {
            final songs = box.values.toList();
            return SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => SongTile(song: songs[i], onTap: () => ctx.read<AudioEngine>().playLocal(songs[i], newQueue: songs)),
              childCount: songs.length,
            ));
          },
        ),
      ]),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final Song song;
  const _RecentCard({required this.song});
  @override
  Widget build(BuildContext ctx) => Container(
    width: 140, margin: const EdgeInsets.only(left: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 120, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text("🎵", style: TextStyle(fontSize: 40)))),
      const SizedBox(height: 8),
      Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(song.artist, maxLines: 1, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]),
  );
}