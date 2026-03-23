import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/song.dart';
import '../models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext ctx) {
    final box = Hive.box<Song>('songs');
    final songs = playlist.songIds
        .map((id) => box.get(id))
        .whereType<Song>()
        .take(4)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => _open(ctx, songs),
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E1E32)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 2×2 cover grid
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: SizedBox(
                width: double.infinity, height: 90,
                child: songs.isEmpty
                    ? Container(color: const Color(0xFF161625),
                        child: const Center(child: Icon(Icons.queue_music_rounded, color: Color(0xFF2A2A45), size: 32)))
                    : GridView.count(
                        crossAxisCount: 2, physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(4, (i) => Container(
                          color: const Color(0xFF161625),
                          child: Center(child: Text(
                            i < songs.length ? '🎵' : '',
                            style: const TextStyle(fontSize: 22))),
                        )),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(playlist.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${playlist.length} titres',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6060A0))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _open(BuildContext ctx, List<Song> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Playlist vide — ajoute des chansons !')));
      return;
    }
    // Navigation vers le player avec la playlist comme queue
    // (géré par LibraryTab)
  }
}
