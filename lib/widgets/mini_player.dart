import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_engine.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext ctx) {
    final engine = ctx.watch<AudioEngine>();
    if (engine.currentSong == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => PlayerScreen(queue: engine.queue))),
      child: Container(
        height: 60, margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF161625), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const SizedBox(width: 10),
          Expanded(child: Text(engine.currentSong!.title, maxLines: 1)),
          IconButton(icon: const Icon(Icons.skip_previous), onPressed: () => engine.playPrev()),
          IconButton(icon: Icon(engine.isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () => engine.togglePlay()),
          IconButton(icon: const Icon(Icons.skip_next), onPressed: () => engine.playNext()),
        ]),
      ),
    );
  }
}