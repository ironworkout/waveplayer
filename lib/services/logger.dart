import 'package:flutter/material.dart';
class AppLogger extends ChangeNotifier {
  static final AppLogger instance = AppLogger._();
  AppLogger._();
  List<String> logs =[];
  void log(String msg) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    logs.insert(0, '[$time] $msg');
    notifyListeners();
    debugPrint(msg);
  }
}
class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs & Erreurs')),
      body: ListenableBuilder(
        listenable: AppLogger.instance,
        builder: (ctx, _) => ListView.builder(
          itemCount: AppLogger.instance.logs.length,
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLogger.instance.logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.greenAccent)),
          ),
        ),
      ),
    );
  }
}