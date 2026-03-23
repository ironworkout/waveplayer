import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/stream_service.dart';
import '../services/audio_engine.dart';
import '../widgets/song_tile.dart';
import 'player_screen.dart';

class StreamTab extends StatefulWidget {
  const StreamTab({super.key});
  @override State<StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<StreamTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<StreamService>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF080810),
          title: const Text('Streaming', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161625),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E1E32)),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _search(context),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Artiste, titre, album…',
                        hintStyle: TextStyle(color: Color(0xFF6060A0), fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF6060A0), size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _search(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Go', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 14)),
                  ),
                ),
              ]),
            ),
          ),
        ),

        // ── Résultats ──
        if (svc.isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (svc.error != null)
          SliverFillRemaining(child: Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_outlined, size: 48, color: Color(0xFF6060A0)),
              const SizedBox(height: 12),
              Text(svc.error!, style: const TextStyle(color: Color(0xFF6060A0)), textAlign: TextAlign.center),
            ]),
          )))
        else if (svc.results.isEmpty)
          const SliverFillRemaining(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.music_note_outlined, size: 56, color: Color(0xFF2A2A45)),
            SizedBox(height: 12),
            Text('Recherche une musique\npour commencer', style: TextStyle(color: Color(0xFF6060A0), fontSize: 14), textAlign: TextAlign.center),
          ])))
        else
          SliverList(delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              final r = svc.results[i];
              return SongTile(
                song: r.toSong(),
                thumbnail: r.thumbnail,
                onTap: () => _playStream(context, i),
              );
            },
            childCount: svc.results.length,
          )),

        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ]),
    );
  }

  void _search(BuildContext ctx) {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(ctx).unfocus();
    ctx.read<StreamService>().search(q);
  }

  Future<void> _playStream(BuildContext ctx, int idx) async {
    final svc = ctx.read<StreamService>();
    final engine = ctx.read<AudioEngine>();
    final r = svc.results[idx];

    // Affiche le player immédiatement avec un état "chargement"
    final song = r.toSong();
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerScreen(queue: svc.results.map((x) => x.toSong()).toList())));

    // Récupère l'URL audio en arrière-plan
    final url = await svc.getAudioUrl(r.videoId);
    if (url != null) {
      await engine.playUrl(song, url);
    } else {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Impossible de lire ce titre')));
      }
    }
  }
}
