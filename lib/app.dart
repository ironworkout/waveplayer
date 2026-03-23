import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class WavePlayerApp extends StatelessWidget {
  const WavePlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (ctx, theme, _) => MaterialApp(
        title: 'WavePlayer',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark(theme.accentColor),
        theme: AppTheme.light(theme.accentColor),
        home: const HomeScreen(),
      ),
    );
  }
}
