import 'dart:async';
import 'dart:math';

import 'package:edupulse/audioProcessing.dart';
import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iirjdart/butterworth.dart';

class LiveLessonPage extends StatefulWidget {
  const LiveLessonPage({Key? key}) : super(key: key);

  @override
  State<LiveLessonPage> createState() => _LiveLessonPageState();
}

class _LiveLessonPageState extends State<LiveLessonPage> {

  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  StreamSubscription<List<double>>? audioSubscription;


  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async => await Permission.microphone.request();

  List<double> highPassFilter(List<double> buffer, int sampleRate, double cutoffHz) {
    // Safety checks
    if (buffer.isEmpty || buffer.length < 2 || sampleRate <= 0 || cutoffHz <= 0) {
      print('Buffer check failed: length=${buffer.length}, sampleRate=${sampleRate}, cutoffHz=${cutoffHz}');
      return buffer;
    }
    if (buffer.any((v) => v.isNaN || v.isInfinite)) {
      print('Buffer contains NaN or infinite values. Skipping filter.');
      return buffer;
    }
    print('Filtering buffer: length=${buffer.length}, sampleRate=${sampleRate}, cutoffHz=${cutoffHz}');
    try {
      Butterworth butterworth = Butterworth();
      butterworth.highPass(4, sampleRate.toDouble(), cutoffHz.toDouble());
      List<double> filteredData = [];
      for (var v in buffer) {
        filteredData.add(butterworth.filter(v));
      }
      return filteredData;
    } catch (e, stack) {
      print('Error in highPassFilter: $e\n$stack');
      return buffer;
    }
  }

  /// Call-back on audio sample.
  AudioProcessing audioProcessing = AudioProcessing();
  void onAudio(List<double> buffer) async {
    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    if (sampleRate == null) {
      // Can't process without sampleRate
      return;
    }
    audio.addAll(buffer);
    recordingTime = audio.length / sampleRate!;
    setState(() => latestBuffer = buffer);
  }

  /// Call-back on error.
  void handleError(Object error) {
    setState(() => isRecording = false);
    print(error);
  }

  /// Start audio sampling.
  void start() async {
    if (!(await checkPermission())) {
      await requestPermission();
    }

    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = 44100;

    // Start listening to the audio stream.
    audioSubscription = AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stop() async {
    audioSubscription?.cancel();
    List<double> filteredaudio = highPassFilter(audio, sampleRate!, 5000);
    audioProcessing.processBuffer(filteredaudio);
    setState(() => isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Lesson'),
      ),
      body: Container(
        margin: EdgeInsets.all(25),
                    child: Column(children: [
                      Container(
                        child: Text(isRecording ? "Mic: ON" : "Mic: OFF",
                            style: TextStyle(fontSize: 25, color: Colors.blue)),
                        margin: EdgeInsets.only(top: 20),
                      ),
                      Text(''),
                      // Text('Max amp: ${latestBuffer?.reduce(max)}'),
                      // Text('Min amp: ${latestBuffer?.reduce(min)}'),
                      Text(
                          '${recordingTime?.toStringAsFixed(2)} seconds recorded.'),
                    ])),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: isRecording ? Colors.red : Colors.green,
                      child: isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
                      onPressed: isRecording ? stop : start,
                    ),
    );
  }
}