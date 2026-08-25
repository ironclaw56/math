/// Represents a single exercise inside a chapter (e.g. "Exercise 1.1").
///
/// The PDF is NOT bundled inside the app anymore. Instead it's hosted
/// online (in this project's GitHub repo, inside assets/pdfs/) and the
/// app downloads it the first time a user opens it, then caches it on
/// the device so every later open works fully offline.
class ExerciseModel {
  final String id;
  final String title;

  const ExerciseModel({
    required this.id,
    required this.title,
  });

  /// Where this exercise's PDF is hosted online. Drop a file with this
  /// exact name into assets/pdfs/ in the GitHub repo (no rebuild needed —
  /// just push the file).
  String get pdfUrl =>
      'https://raw.githubusercontent.com/ironclaw56/math/main/assets/pdfs/$id.pdf';

  /// The filename used to cache this PDF locally on the device.
  String get cacheFileName => '$id.pdf';

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
