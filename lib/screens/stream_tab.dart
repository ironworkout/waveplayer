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
  Widget build(BuildContext context) {
    final svc = context.watch<StreamService>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers:[
        SliverAppBar(
          pinned: true, backgroundColor: const Color(0xFF080810),
          title: const Text('Streaming', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Row(children:[
              Expanded(child: Container(
                decoration: BoxDecoration(color: const Color(0xFF161625), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E1E32))),
                child: TextField(controller: _ctrl, onSubmitted: (_) => _search(context), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), decoration: const InputDecoration(hintText: 'Rechercher sur YouTube...', hintStyle: TextStyle(color: Color(0xFF6060A0), fontSize: 14), prefixIcon: Icon(Icons.search, color: Color(0xFF6060A0), size: 20), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 14))),
              )),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _search(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)), child: const Text('Go', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 14)))),
            ])),
          ),
        ),
        if (svc.isLoading) const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (svc.results.isEmpty) const SliverFillRemaining(child: Center(child: Icon(Icons.cloud_outlined, size: 56, color: Color(0xFF2A2A45))))
        else SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
          final r = svc.results[i];
          final progress = svc.downloads[r.videoId];
          return SongTile(
            song: r.toSong(), thumbnail: r.thumbnail, onTap: () => _playStream(context, i),
            trailing: progress != null 
              ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: progress, color: accent, strokeWidth: 2))
              : IconButton(icon: const Icon(Icons.cloud_download_outlined, color: Color(0xFF6060A0)), onPressed: () => svc.downloadVideo(r, context)),
          );
        }, childCount: svc.results.length)),
        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ]),
    );
  }

  void _search(BuildContext ctx) { if (_ctrl.text.trim().isNotEmpty) { FocusScope.of(ctx).unfocus(); ctx.read<StreamService>().search(_ctrl.text.trim()); } }
  Future<void> _playStream(BuildContext ctx, int idx) async {
    final svc = ctx.read<StreamService>();
    final engine = ctx.read<AudioEngine>();
    final r = svc.results[idx];
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerScreen(queue: svc.results.map((x) => x.toSong()).toList())));
    final url = await svc.getAudioUrl(r.videoId);
    if (url != null) await engine.playUrl(r.toSong(), url);
  }
}