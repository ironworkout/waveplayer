import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  static const _defaultAccent = Color(0xFF1DB954);

  Color accentColor = _defaultAccent;

  static const presetColors = [
    Color(0xFF1DB954), // Vert Spotify
    Color(0xFF3B82F6), // Bleu
    Color(0xFFF59E0B), // Ambre
    Color(0xFFF87171), // Corail
    Color(0xFF7C5CBF), // Violet
    Color(0xFF06B6D4), // Cyan
  ];

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt('accent_color');
    if (v != null) accentColor = Color(v);
    notifyListeners();
  }

  Future<void> setAccent(Color c) async {
    accentColor = c;
    final p = await SharedPreferences.getInstance();
    await p.setInt('accent_color', c.value);
    notifyListeners();
  }

  static ThemeData dark(Color accent) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF080810),
    colorScheme: ColorScheme.dark(
      primary: accent,
      secondary: accent,
      surface: const Color(0xFF12121F),
      background: const Color(0xFF080810),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0A0A16),
      indicatorColor: accent.withOpacity(0.18),
      iconTheme: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected)
              ? IconThemeData(color: accent)
              : const IconThemeData(color: Color(0xFF6060A0))),
      labelTextStyle: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected)
              ? TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent)
              : const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6060A0))),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      thumbColor: accent,
      inactiveTrackColor: const Color(0xFF2A2A45),
      overlayColor: accent.withOpacity(0.2),
      trackHeight: 4,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF6060A0)),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFEEEEFF)),
      bodyMedium: TextStyle(color: Color(0xFFEEEEFF)),
    ),
  );

  static ThemeData light(Color accent) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(primary: accent),
  );
}
