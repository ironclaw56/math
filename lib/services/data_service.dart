import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/class_model.dart';
import '../models/chapter_model.dart';

/// Loads class/chapter/exercise data.
///
/// For now this reads bundled dummy JSON files from `assets/books/`.
/// Later this can be swapped for a remote API or local database call
/// without changing any screen code, since screens only depend on
/// [ClassModel]/[ChapterModel]/[ExerciseModel].
class DataService {
  DataService._();
  static final DataService instance = DataService._();

  // Static metadata (icon/emoji/colors) for each class button on Home.
  static const List<_ClassMeta> _classMeta = [
    _ClassMeta(
      id: 'class9',
      displayName: 'Class 9',
      emoji: '📘',
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    ),
    _ClassMeta(
      id: 'class10',
      displayName: 'Class 10',
      emoji: '📗',
      gradient: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
    ),
    _ClassMeta(
      id: 'class11',
      displayName: 'Class 11',
      emoji: '📙',
      gradient: [Color(0xFFEF6C00), Color(0xFFFFA726)],
    ),
    _ClassMeta(
      id: 'class12',
      displayName: 'Class 12',
      emoji: '📕',
      gradient: [Color(0xFFC62828), Color(0xFFEF5350)],
    ),
  ];

  final Map<String, ClassModel> _cache = {};

  /// Returns the four classes with metadata only (fast, for Home screen).
  List<_ClassMeta> get classMetaList => _classMeta;

  /// Loads (and caches) the full class data including chapters & exercises.
  Future<ClassModel> loadClass(String classId) async {
    if (_cache.containsKey(classId)) {
      return _cache[classId]!;
    }
    final meta = _classMeta.firstWhere((m) => m.id == classId);
    final jsonString = await rootBundle
        .loadString('assets/books/$classId/$classId.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final chapters = (jsonData['chapters'] as List<dynamic>)
        .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
        .toList();

    final classModel = ClassModel(
      id: meta.id,
      displayName: meta.displayName,
      shortLabel: jsonData['shortLabel'] as String? ?? meta.displayName,
      emoji: meta.emoji,
      gradientColors: meta.gradient,
      chapters: chapters,
    );

    _cache[classId] = classModel;
    return classModel;
  }
}

class _ClassMeta {
  final String id;
  final String displayName;
  final String emoji;
  final List<Color> gradient;

  const _ClassMeta({
    required this.id,
    required this.displayName,
    required this.emoji,
    required this.gradient,
  });
}
