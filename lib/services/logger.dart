import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();
  void log(String msg) => debugPrint('[WavePlayer] $msg');
}