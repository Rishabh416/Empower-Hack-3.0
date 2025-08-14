import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iirjdart/butterworth.dart';
import 'package:edupulse/audioProcessing.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class AudioController {
  AudioController();

  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  StreamSubscription<List<double>>? audioSubscription;

  List<double> waveform = [];

  // Use ValueNotifier to notify UI of changes
  ValueNotifier<List<double>?> bufferNotifier = ValueNotifier(null);
  ValueNotifier<bool> recordingNotifier = ValueNotifier(false);
  ValueNotifier<double?> recordingTimeNotifier = ValueNotifier(null);

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async => await Permission.microphone.request();

  List<double> highPassFilter(List<double> buffer, int sampleRate, double cutoffHz) {
    if (buffer.isEmpty || buffer.length < 2 || sampleRate <= 0 || cutoffHz <= 0) {
      print('Buffer check failed: length=${buffer.length}, sampleRate=${sampleRate}, cutoffHz=${cutoffHz}');
      return buffer;
    }
    if (buffer.any((v) => v.isNaN || v.isInfinite)) {
      print('Buffer contains NaN or infinite values. Skipping filter.');
      return buffer;
    }
    try {
      Butterworth butterworth = Butterworth();
      butterworth.highPass(4, sampleRate.toDouble(), cutoffHz.toDouble());
      List<double> filteredData = buffer.map((v) => butterworth.filter(v)).toList();
      return filteredData;
    } catch (e, stack) {
      print('Error in highPassFilter: $e\n$stack');
      return buffer;
    }
  }

  /// Call-back on audio sample.
  AudioProcessing audioProcessing = AudioProcessing();

  void onAudio(List<double> buffer) async {
    sampleRate ??= await AudioStreamer().actualSampleRate;
    if (sampleRate == null) return;

    audio.addAll(buffer);
    recordingTime = audio.length / sampleRate!;
    waveform = buffer;

    // Notify UI
    latestBuffer = buffer;
    bufferNotifier.value = buffer;
    recordingTimeNotifier.value = recordingTime;
  }

  /// Call-back on error.
  void handleError(Object error) {
    isRecording = false;
    recordingNotifier.value = false;
    print(error);
  }

  Timer? _timer;

  /// Start audio sampling.
  Future<void> start() async {
    if (!(await checkPermission())) {
      await requestPermission();
    }

    AudioStreamer().sampleRate = 44100;

    audioSubscription = AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    isRecording = true;
    recordingNotifier.value = true;

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Your function to run every 30 seconds
      List<double> filteredaudio = highPassFilter(audio, sampleRate!, 5000);
      audioProcessing.processBuffer(filteredaudio);
      audio = [];
    });
  }

  /// Stop audio sampling.

  Future<void> stop() async {
    await audioSubscription?.cancel();
    _timer?.cancel();

    isRecording = false;
    recordingNotifier.value = false;
  }

}
