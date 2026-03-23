import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/logger.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    final accent = Theme.of(ctx).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Réglages"), backgroundColor: Colors.black),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accent),
          onPressed: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LogsScreen())),
          child: const Text("Voir les Logs & Erreurs", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}