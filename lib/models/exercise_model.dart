/// Represents a single exercise inside a chapter (e.g. "Exercise 1.1").
///
/// The actual question/solution content is a PDF bundled inside the app
/// itself (assets/pdfs/<id>.pdf). Because it's a compiled-in asset, it can
/// only be added or changed by rebuilding the app — a regular user of the
/// installed app can never replace or edit it.
class ExerciseModel {
  final String id;
  final String title;

  const ExerciseModel({
    required this.id,
    required this.title,
  });

  /// Path of this exercise's PDF inside the app bundle. Drop a file with
  /// this exact name into assets/pdfs/ before building the app.
  String get pdfAssetPath => 'assets/pdfs/$id.pdf';

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}
