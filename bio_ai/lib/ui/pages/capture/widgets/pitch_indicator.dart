import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bio_ai/app/di/injectors.dart';

class PitchIndicator extends ConsumerWidget {
  const PitchIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pitchAsync = ref.watch(pitchProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: pitchAsync.when(
        data: (val) => Text(
          'Pitch: ${val.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
        loading: () => const SizedBox(
          width: 60,
          height: 14,
          child: LinearProgressIndicator(),
        ),
        error: (e, st) =>
            const Text('Pitch: —', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
