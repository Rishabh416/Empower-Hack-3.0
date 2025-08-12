import 'dart:async';
import 'dart:math';

import 'package:edupulse/audioProcessing.dart';
import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';


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
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Call-back on audio sample.
  
  AudioProcessing audioProcessing = AudioProcessing();
  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    recordingTime = audio.length / sampleRate!;
    print(latestBuffer?.length);
    audioProcessing.processBuffer(latestBuffer);
    
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
                      Text('Max amp: ${latestBuffer?.reduce(max)}'),
                      Text('Min amp: ${latestBuffer?.reduce(min)}'),
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