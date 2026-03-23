import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'models/playlist.dart';
import 'models/listening_stats.dart';
import 'services/audio_engine.dart';
import 'services/smart_shuffle.dart';
import 'services/file_scanner.dart';
import 'services/stats_service.dart';
import 'services/stream_service.dart';
import 'services/logger.dart';
import 'theme/app_theme.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.instance.log("Démarrage de WavePlayer...");
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(PlaylistAdapter());
    Hive.registerAdapter(ListeningStatsAdapter());
    await Hive.openBox<Song>('songs');
    await Hive.openBox<Playlist>('playlists');
    await Hive.openBox<ListeningStats>('stats');
    
    AppLogger.instance.log("Initialisation Audio Background...");
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.waveplayer.audio',
      androidNotificationChannelName: 'WavePlayer',
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
    AppLogger.instance.log("Audio prêt ✅");
  } catch (e) {
    AppLogger.instance.log("Erreur Init: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()..load()),
        ChangeNotifierProvider(create: (_) => AudioEngine()..init()),
        ChangeNotifierProvider(create: (_) => SmartShuffle()),
        ChangeNotifierProvider(create: (_) => FileScanner()),
        ChangeNotifierProvider(create: (_) => StatsService()),
        ChangeNotifierProvider(create: (_) => StreamService()),
      ],
      child: const WavePlayerApp(),
    ),
  );
}