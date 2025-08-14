import 'package:edupulse/lessonView.dart';
import 'package:edupulse/supabaseController.dart';
import 'package:edupulse/storageController.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final SupabaseController supabase = SupabaseController();
  final StorageController storageController = StorageController();

  List lessons = [];
  List<String> localFolders = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final lessonsData = await supabase.getLessons();
    final foldersData = await storageController.getAllFolders();
    setState(() {
      lessons = lessonsData;
      localFolders = foldersData;
    });
  }

  void openLessonView(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonView(folderName: folderName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: ListView(
        children: [
          if (localFolders.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Downloaded Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ...localFolders.map((folder) => ListTile(
                title: Text(folder),
                trailing: IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () => openLessonView(folder),
                )
              )),
          if (lessons.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Available Downloads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ...lessons.map((lesson) => ListTile(
                title: Text(lesson['lessonName']),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    supabase.downloadLesson(lesson['storagePath']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading lesson...')),
                    );
                  },
                ),
              )),
        ],
      ),
    );
  }
}
