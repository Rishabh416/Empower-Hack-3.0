import 'package:edupulse/audioController.dart';
import 'package:flutter/material.dart';
import 'package:edupulse/waveformpainter.dart';   // import your SpectrumPainter/WaveformPainter

class LiveLessonPage extends StatefulWidget {
  const LiveLessonPage({Key? key}) : super(key: key);

  @override
  State<LiveLessonPage> createState() => _LiveLessonPageState();
}

class _LiveLessonPageState extends State<LiveLessonPage> {
  final AudioController audioController = AudioController();

  @override
  void dispose() {
    audioController.audioSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Lesson'),
      ),
      body: Container(
        margin: const EdgeInsets.all(25),
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: audioController.recordingNotifier,
              builder: (context, isRecording, _) {
                return Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    isRecording ? "Mic: ON" : "Mic: OFF",
                    style: const TextStyle(fontSize: 25, color: Colors.blue),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<List<double>?>(
              valueListenable: audioController.bufferNotifier,
              builder: (context, latestBuffer, _) {
                return SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: SpectrumPainter(latestBuffer ?? [], color: Colors.green),
                    size: const Size(double.infinity, 100),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<double?>(
              valueListenable: audioController.recordingTimeNotifier,
              builder: (context, recordingTime, _) {
                return Text(
                  '${recordingTime?.toStringAsFixed(2) ?? 0} seconds recorded.',
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: audioController.recordingNotifier,
        builder: (context, isRecording, _) {
          return FloatingActionButton(
            backgroundColor: isRecording ? Colors.red : Colors.green,
            child: Icon(isRecording ? Icons.stop : Icons.mic),
            onPressed: isRecording ? audioController.stop : audioController.start,
          );
        },
      ),
    );
  }
}
