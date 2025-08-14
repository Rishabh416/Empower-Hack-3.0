import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edupulse/storageController.dart';
import 'dart:io';

class SupabaseController {
  SupabaseController();

  final storageController = StorageController();

  Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://fewidjdyezbgzuyfcgij.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZld2lkamR5ZXpiZ3p1eWZjZ2lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU0MzAsImV4cCI6MjA3MDc0MTQzMH0.Lh3dIQ1n5YIhjh_JrqwB4wSEVJRaZvjSNV7IEbH127o',
      );
    } 
    catch (e) {
      print('Supabase initialization error: $e');
    }
  }

  Future<List> getLessons() async {
    try {
      final lessons = await Supabase.instance.client
        .from('lessonsData')
        .select();
      final baseDir = Directory(await storageController.getDocumentsDirectory());

      final filteredLessons = lessons.where((lesson) {
        final lessonName = lesson['lessonName'] as String;
        final lessonDir = Directory('${baseDir.path}/$lessonName');
        return !lessonDir.existsSync(); // keep only if folder does NOT exist
      }).map((e) => e as Map<String, dynamic>).toList();

      return filteredLessons;
    }
    catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }
  
  void downloadLesson(storagePath) async {
    try {
      final signedUrl = await Supabase.instance.client
        .storage
        .from('lessons')
        .createSignedUrl(storagePath, 3600);
      print('signedUrl: $signedUrl');
      await storageController.downloadAndUnzip(signedUrl, storagePath);
    }
    catch (e) {
      print('Error downloading lesson: $e');
    }
  }

}
