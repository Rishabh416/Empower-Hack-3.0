import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:fftea/fftea.dart';

class SpectrumPainter extends CustomPainter {
  final List<double> audio;
  final int chunkSize;
  final Color color;

  SpectrumPainter(this.audio,
      {this.chunkSize = 1024, this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    if (audio.isEmpty) return;

    // Prepare STFT
    final stft = STFT(chunkSize, Window.hanning(chunkSize));
    final spectrogram = <Float64List>[];

    // Run STFT
    stft.run(audio, (Float64x2List freq) {
      spectrogram.add(freq.discardConjugates().magnitudes());
    });

    if (spectrogram.isEmpty) return;

    // Use the last STFT chunk for visualization
    final lastChunk = spectrogram.last;
    double maxVal = lastChunk.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;

    final paint = Paint()..color = color;
    final barWidth = size.width / lastChunk.length;

    for (int i = 0; i < lastChunk.length; i++) {
      double normalized = lastChunk[i] / maxVal;
      double barHeight = normalized * size.height;
      canvas.drawRect(
        Rect.fromLTWH(i * barWidth, size.height - barHeight, barWidth, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpectrumPainter oldDelegate) {
    return oldDelegate.audio != audio || oldDelegate.color != color;
  }
}
