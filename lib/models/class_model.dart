import 'package:flutter/material.dart';
import 'chapter_model.dart';

/// Represents a class level (Class 9, 10, 11, 12) shown as a home screen button.
class ClassModel {
  final String id;
  final String displayName; // e.g. "Class 9"
  final String shortLabel; // e.g. "9th"
  final String emoji;
  final List<Color> gradientColors;
  final List<ChapterModel> chapters;

  const ClassModel({
    required this.id,
    required this.displayName,
    required this.shortLabel,
    required this.emoji,
    required this.gradientColors,
    required this.chapters,
  });
}
