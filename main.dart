import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'theme/app_theme.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── just_audio_background ──────────────────────
  // notificationColor retiré : pas supporté dans beta.11
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.waveplayer.audio',
    androidNotificationChannelName: 'WavePlayer',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  // ── Hive ──────────────────────────────────────
  await Hive.initFlutter();
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(ListeningStatsAdapter());

  await Hive.openBox<Song>('songs');
  await Hive.openBox<Playlist>('playlists');
  await Hive.openBox<ListeningStats>('stats');
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),
        ChangeNotifierProvider(create: (_) => AudioEngine()),
        ChangeNotifierProvider(create: (_) => SmartShuffle()),
        ChangeNotifierProvider(create: (_) => FileScanner()),
        ChangeNotifierProvider(create: (_) => StatsService()),
        ChangeNotifierProvider(create: (_) => StreamService()),
      ],
      child: const WavePlayerApp(),
    ),
  );
}
