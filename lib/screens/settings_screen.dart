import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext ctx) {
    final theme = ctx.watch<AppTheme>();
    final accent = theme.accentColor;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(slivers:[
        SliverAppBar(pinned: true, backgroundColor: const Color(0xFF080810), title: const Text('Réglages', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(children:[
          ElevatedButton.icon(
            onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LogsScreen())),
            icon: const Icon(Icons.bug_report, color: Colors.black),
            label: const Text('Voir les Logs & Erreurs', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: accent, minimumSize: const Size.fromHeight(50)),
          ),
          const SizedBox(height: 20),
          const Text("Réglages désactivés pour le debug", style: TextStyle(color: Colors.grey)),
        ]))),
      ]),
    );
  }
}