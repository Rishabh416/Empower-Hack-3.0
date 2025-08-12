import 'package:flutter/material.dart';

class LiveLessonPage extends StatelessWidget {
  const LiveLessonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Lesson'),
      ),
      body: const Center(
        child: Text('Live Lesson Page'),
      ),
    );
  }
}