import 'dart:math';
import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color accent;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    required this.accent,
    this.height = 40,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _rng = Random();
  final int _bars = 24;
  late List<double> _heights;

  @override
  void initState() {
    super.initState();
    _heights = List.generate(_bars, (_) => 3.0);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..addListener(_tick)..repeat();
  }

  void _tick() {
    if (!widget.isPlaying) {
      setState(() => _heights = _heights.map((_) => 3.0).toList());
      return;
    }
    setState(() {
      _heights = List.generate(_bars, (_) => 4 + _rng.nextDouble() * (widget.height - 8));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext ctx) {
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_bars, (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              height: _heights[i],
              decoration: BoxDecoration(
                color: widget.accent.withOpacity(0.55),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
