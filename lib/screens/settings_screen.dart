import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../services/audio_engine.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _cfOn = true;
  double _cfDur = 5;
  bool _smart = true;
  bool _scanAuto = true;
  bool _cache = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _cfOn   = p.getBool('cf_on') ?? true;
      _cfDur  = (p.getInt('cf_dur') ?? 5).toDouble();
      _smart  = p.getBool('smart') ?? true;
      _scanAuto = p.getBool('scan_auto') ?? true;
      _cache  = p.getBool('cache') ?? true;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('cf_on', _cfOn);
    await p.setInt('cf_dur', _cfDur.round());
    await p.setBool('smart', _smart);
    await p.setBool('scan_auto', _scanAuto);
    await p.setBool('cache', _cache);
    // Applique au moteur audio
    if (mounted) context.read<AudioEngine>().crossfadeDurationMs = (_cfDur * 1000).round();
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = ctx.watch<AppTheme>();
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers: [
        SliverAppBar(pinned: true, backgroundColor: const Color(0xFF080810),
          title: RichText(text: TextSpan(style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
            children: [const TextSpan(text: 'Réglages '), TextSpan(text: '⚙', style: TextStyle(color: accent))]))),

        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [

          // ── Audio ──
          _Sec('Audio', [
            _Row('Crossfade automatique', 'Fondu enchaîné entre chansons',
              trailing: Switch(value: _cfOn, activeColor: accent, onChanged: (v) { setState(()=>_cfOn=v); _save(); })),
            _Row('Durée du fondu', '${_cfDur.round()} secondes',
              trailing: SizedBox(width: 130, child: Slider(value: _cfDur, min: 2, max: 12, divisions: 10, activeColor: accent,
                onChanged: (v) { setState(()=>_cfDur=v); _save(); }))),
            _Row('Smart Shuffle', 'Basé sur tes likes et écoutes',
              trailing: Switch(value: _smart, activeColor: accent, onChanged: (v) { setState(()=>_smart=v); _save(); })),
          ]),

          const SizedBox(height: 20),

          // ── Couleur accent ──
          _Sec('Couleur accent', [
            Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 10, children:
              AppTheme.presetColors.map((c) => GestureDetector(
                onTap: () => theme.setAccent(c),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  width: 36, height: 36,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c,
                    border: Border.all(color: c == accent ? Colors.white : Colors.transparent, width: 2.5)),
                ),
              )).toList(),
            )),
          ]),

          const SizedBox(height: 20),

          // ── Import & streaming ──
          _Sec('Import & Streaming', [
            _Row('Scan automatique', 'Détecter les nouveaux MP3',
              trailing: Switch(value: _scanAuto, activeColor: accent, onChanged: (v) { setState(()=>_scanAuto=v); _save(); })),
            _Row('Cache audio', 'Réécoute hors-ligne',
              trailing: Switch(value: _cache, activeColor: accent, onChanged: (v) { setState(()=>_cache=v); _save(); })),
            _Row('Qualité streaming', 'Audio le plus haute qualité', trailing: Text('Auto', style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13))),
            _Row('Dossiers surveillés', '/Music · /Downloads', trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6060A0))),
          ]),

          const SizedBox(height: 20),

          // ── À propos ──
          _Sec('À propos', [
            _Row('WavePlayer', '', trailing: const Text('v2.0', style: TextStyle(color: Color(0xFF6060A0), fontWeight: FontWeight.w700))),
            _Row('Basé sur', 'Musify (gokadzev) — GPL v3', trailing: const SizedBox()),
          ]),

        ]))),
      ]),
    );
  }
}

class _Sec extends StatelessWidget {
  final String title; final List<Widget> children;
  const _Sec(this.title, this.children);
  @override Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Color(0xFF6060A0)))),
    Container(decoration: BoxDecoration(color: const Color(0xFF12121F), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1E1E32))),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [
        e.value,
        if (e.key < children.length - 1) const Divider(height: 1, color: Color(0xFF1E1E32), indent: 18),
      ])).toList())),
  ]);
}

class _Row extends StatelessWidget {
  final String name, sub; final Widget trailing;
  const _Row(this.name, this.sub, {required this.trailing});
  @override Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF6060A0))),
      ])),
      const SizedBox(width: 12),
      trailing,
    ]),
  );
}
