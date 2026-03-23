import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/file_scanner.dart';
import '../services/audio_engine.dart';
import '../widgets/mini_player.dart';
import 'library_tab.dart';
import 'stream_tab.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Scan auto au premier démarrage
    Future.microtask(() => context.read<FileScanner>().scanAll());
    Future.microtask(() => context.read<AudioEngine>().init());
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<AudioEngine>();
    return Scaffold(
      body: Stack(children: [
        IndexedStack(index: _tab, children: const [
          LibraryTab(),
          StreamTab(),
          StatsScreen(),
          SettingsScreen(),
        ]),
        // Mini player persistant en bas
        if (engine.currentSong != null)
          const Positioned(bottom: 0, left: 0, right: 0, child: MiniPlayer()),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_music_outlined), selectedIcon: Icon(Icons.library_music), label: 'Biblio'),
          NavigationDestination(icon: Icon(Icons.stream_outlined), selectedIcon: Icon(Icons.stream), label: 'Streaming'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Réglages'),
        ],
      ),
    );
  }
}
