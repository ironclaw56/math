import 'exercise_model.dart';

/// Represents a single chapter inside a class (e.g. "Chapter 1: Real Numbers").
class ChapterModel {
  final String id;
  final int chapterNumber;
  final String title;
  final List<ExerciseModel> exercises;
  final bool isBookmarked;

  const ChapterModel({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.exercises,
    this.isBookmarked = false,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterNumber': chapterNumber,
        'title': title,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isBookmarked': isBookmarked,
      };
}
