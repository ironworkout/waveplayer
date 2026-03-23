import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTile extends StatelessWidget {
  final Song song; final VoidCallback onTap; final String? thumbnail;
  const SongTile({super.key, required this.song, required this.onTap, this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text("🎵"))),
      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, maxLines: 1, style: const TextStyle(color: Colors.grey)),
      trailing: PopupMenuButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        itemBuilder: (ctx) => [
          const PopupMenuItem(child: Text("Ajouter à la playlist")),
          const PopupMenuItem(child: Text("Supprimer le fichier")),
        ],
      ),
    );
  }
}