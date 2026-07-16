import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/content/content_models.dart';
import '../../models/content/final_exam_models.dart';

class ContentLoadException implements Exception {
  const ContentLoadException(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => 'ContentLoadException: $message';
}

class CefrContentRepository {
  CefrContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  static const catalogPath = 'assets/content/catalog.json';

  Future<List<CourseLevel>> loadLevels() async {
    try {
      final catalog = await _readMap(catalogPath);
      final files = (catalog['levelFiles'] as List<dynamic>).cast<String>();
      return Future.wait(files.map(loadLevel));
    } catch (error) {
      if (error is ContentLoadException) rethrow;
      throw ContentLoadException('CEFR catalog-ka lama akhrin karin.', error);
    }
  }

  Future<CourseLevel> loadLevel(String path) async {
    try {
      return CourseLevel.fromJson(await _readMap(path));
    } catch (error) {
      throw ContentLoadException('Level file-ka $path ma saxna.', error);
    }
  }

  Future<CourseUnit> loadUnit(String path) async {
    try {
      return CourseUnit.fromJson(await _readMap(path));
    } catch (error) {
      throw ContentLoadException('Unit file-ka $path ma saxna.', error);
    }
  }

  Future<List<PracticeExercise>> loadExam(String path) async {
    try {
      final data = await _readMap(path);
      return (data['questions'] as List<dynamic>)
          .map(
            (item) => PracticeExercise.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      throw ContentLoadException('Exam file-ka $path ma saxna.', error);
    }
  }

  Future<FinalExamContent> loadFinalExam(String path) async {
    try {
      return FinalExamContent.fromJson(await _readMap(path));
    } catch (error) {
      throw ContentLoadException('Final exam file-ka $path ma saxna.', error);
    }
  }

  Future<Map<String, dynamic>> _readMap(String path) async {
    final source = await _bundle.loadString(path);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw ContentLoadException('$path waa inuu noqdaa JSON object.');
    }
    return decoded;
  }
}
