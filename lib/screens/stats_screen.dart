import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/stats_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final stats = ctx.watch<StatsService>();
    final accent = Theme.of(ctx).colorScheme.primary;
    final total = stats.totalListeningTime;
    final h = total.inHours, m = total.inMinutes % 60;
    final week = stats.weekActivity();
    final weekVals = week.values.toList();
    final maxW = weekVals.isEmpty ? 1 : weekVals.reduce((a,b)=>a>b?a:b);
    final days = ['L','M','M','J','V','S','D'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        SliverAppBar(pinned: true, backgroundColor: const Color(0xFF080810),
          title: RichText(text: TextSpan(style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
            children: [const TextSpan(text: 'Mes '), TextSpan(text: 'stats', style: TextStyle(color: accent))]))),

        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [

          // Total time
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Label('Temps total d\'écoute'),
            Text('${h}h ${m}m', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: accent, letterSpacing: -2, height: 1)),
            const Text('depuis le début', style: TextStyle(fontSize: 12, color: Color(0xFF6060A0))),
          ])),

          const SizedBox(height: 13),

          // Week heatmap
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Label('Activité (7 jours)'),
            Row(children: List.generate(7, (i) {
              final v = weekVals.length > i ? weekVals[i] : 0;
              final alpha = maxW == 0 ? 0.0 : 0.1 + (v / maxW) * 0.9;
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Column(children: [
                AspectRatio(aspectRatio: 1, child: Container(decoration: BoxDecoration(
                  color: accent.withOpacity(alpha), borderRadius: BorderRadius.circular(6)))),
                const SizedBox(height: 4),
                Text(days[i], style: const TextStyle(fontSize: 9, color: Color(0xFF6060A0), fontWeight: FontWeight.w800)),
              ])));
            })),
          ])),

          const SizedBox(height: 13),

          // Top songs
          ValueListenableBuilder(
            valueListenable: Hive.box<Song>('songs').listenable(),
            builder: (ctx, box, _) {
              final songs = box.values.toList();
              final top = stats.topSongs(songs, limit: 5);
              final maxP = top.isEmpty ? 1 : (top.first.playCount);
              return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('Top titres'),
                ...top.asMap().entries.map((e) {
                  final s = e.value; final i = e.key;
                  final pct = maxP == 0 ? 0.0 : s.playCount / maxP;
                  final rankColor = [Colors.amber, Colors.grey.shade400, const Color(0xFFCD7F32), const Color(0xFF6060A0), const Color(0xFF6060A0)][i];
                  return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                    Container(width: 26, height: 26, decoration: BoxDecoration(color: rankColor.withOpacity(.14), shape: BoxShape.circle),
                      child: Center(child: Text('${i+1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: rankColor)))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${s.playCount} écoutes', style: const TextStyle(fontSize: 11, color: Color(0xFF6060A0))),
                    ])),
                    SizedBox(width: 52, height: 3, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
                      value: pct.toDouble(), backgroundColor: const Color(0xFF2A2A45), color: accent))),
                  ]));
                }),
              ]));
            },
          ),

          const SizedBox(height: 13),

          // Smart shuffle stats
          ValueListenableBuilder(
            valueListenable: Hive.box<Song>('songs').listenable(),
            builder: (ctx, box, _) {
              final songs = box.values.toList();
              return _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Label('Smart Shuffle'),
                Row(children: [
                  _StatPill('${songs.where((s)=>s.isLiked).length}', '❤️ Aimées', accent),
                  const SizedBox(width: 10),
                  _StatPill('${songs.fold<int>(0,(a,s)=>a+s.playCount)}', '▶ Écoutes', const Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  _StatPill('${songs.fold<int>(0,(a,s)=>a+s.skipCount)}', '⏭ Skips', const Color(0xFFF87171)),
                ]),
              ]));
            },
          ),
        ]))),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override Widget build(BuildContext ctx) => Container(
    width: double.infinity, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF12121F), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1E1E32))),
    child: child,
  );
}

class _Label extends StatelessWidget {
  final String t;
  const _Label(this.t);
  @override Widget build(BuildContext ctx) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF6060A0))));
}

class _StatPill extends StatelessWidget {
  final String val, label; final Color color;
  const _StatPill(this.val, this.label, this.color);
  @override Widget build(BuildContext ctx) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: const Color(0xFF161625), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E1E32))),
    child: Column(children: [
      Text(val, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6060A0), fontWeight: FontWeight.w700)),
    ]),
  ));
}
