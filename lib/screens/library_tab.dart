import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../models/playlist.dart';
import '../services/file_scanner.dart';
import '../services/audio_engine.dart';
import '../services/smart_shuffle.dart';
import '../widgets/song_tile.dart';
import '../widgets/playlist_card.dart';
import 'player_screen.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<FileScanner>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF080810),
          title: RichText(text: TextSpan(
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
            children: [
              const TextSpan(text: 'Wave', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Player', style: TextStyle(color: accent)),
            ],
          )),
          actions: [
            // Bouton scan
            scanner.isScanning
                ? Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: accent)))
                : TextButton.icon(
                    onPressed: () => scanner.scanAll(),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Scanner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
            const SizedBox(width: 12),
          ],
        ),

        // ── Playlists ──
        const SliverToBoxAdapter(child: _SectionTitle('Playlists')),
        SliverToBoxAdapter(child: _PlaylistsRow()),

        // ── Toutes les chansons ──
        const SliverToBoxAdapter(child: _SectionTitle('Mes MP3')),
        ValueListenableBuilder(
          valueListenable: Hive.box<Song>('songs').listenable(),
          builder: (ctx, box, _) {
            final songs = box.values.where((s) => s.sourceStr == 'local').toList()
              ..sort((a, b) => a.title.compareTo(b.title));
            if (songs.isEmpty) return const SliverToBoxAdapter(child: _EmptyState());
            return SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => SongTile(
                song: songs[i],
                onTap: () => _playSong(ctx, songs[i], songs),
              ),
              childCount: songs.length,
            ));
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ]),
    );
  }

  void _playSong(BuildContext ctx, Song song, List<Song> queue) {
    final engine = ctx.read<AudioEngine>();
    engine.playLocal(song);
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerScreen(queue: queue)));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF6060A0))),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override Widget build(BuildContext ctx) => const Padding(
    padding: EdgeInsets.all(40),
    child: Column(children: [
      Icon(Icons.music_off_outlined, size: 48, color: Color(0xFF6060A0)),
      SizedBox(height: 12),
      Text('Aucun MP3 trouvé', style: TextStyle(color: Color(0xFF6060A0), fontWeight: FontWeight.w700)),
      SizedBox(height: 4),
      Text('Appuie sur Scanner pour importer ta musique', style: TextStyle(color: Color(0xFF4040700), fontSize: 12), textAlign: TextAlign.center),
    ]),
  );
}

class _PlaylistsRow extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Playlist>('playlists').listenable(),
      builder: (ctx, box, _) {
        final pls = box.values.toList();
        return SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...pls.map((p) => PlaylistCard(playlist: p)),
              // Bouton + créer
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => _showNewPlaylistDialog(ctx),
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A2A45), width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add, color: Color(0xFF6060A0)),
                      SizedBox(height: 6),
                      Text('Nouvelle', style: TextStyle(fontSize: 12, color: Color(0xFF6060A0), fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewPlaylistDialog(BuildContext ctx) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF0F0F1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFF2A2A45), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Nouvelle playlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl, autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nom de la playlist…',
              filled: true, fillColor: const Color(0xFF161625),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                final box = Hive.box<Playlist>('playlists');
                final pl = Playlist()..id = DateTime.now().millisecondsSinceEpoch.toString()..name = ctrl.text.trim();
                box.put(pl.id, pl);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}
