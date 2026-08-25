import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/exercise_model.dart';
import '../services/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

/// Displays the PDF for a single exercise.
///
/// The PDF is hosted online and downloaded the first time it's opened,
/// then cached to local device storage. Every later open reads straight
/// from the local cache — no internet needed after the first time.
class ExerciseContentScreen extends StatefulWidget {
  final String chapterTitle;
  final ExerciseModel exercise;

  const ExerciseContentScreen({
    super.key,
    required this.chapterTitle,
    required this.exercise,
  });

  @override
  State<ExerciseContentScreen> createState() => _ExerciseContentScreenState();
}

class _ExerciseContentScreenState extends State<ExerciseContentScreen> {
  late Future<File?> _pdfFileFuture;

  @override
  void initState() {
    super.initState();
    _pdfFileFuture = _getPdfFile();
  }

  Future<File?> _getPdfFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File('${dir.path}/${widget.exercise.cacheFileName}');

      // Already cached on this device — use it directly, no internet needed.
      if (await localFile.exists()) {
        return localFile;
      }

      // Not cached yet — download it now and save it for next time.
      final response = await http.get(Uri.parse(widget.exercise.pdfUrl));
      if (response.statusCode == 200) {
        await localFile.writeAsBytes(response.bodyBytes);
        return localFile;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        actions: [
          AnimatedBuilder(
            animation: AppState.instance,
            builder: (context, _) {
              final bookmarked =
                  AppState.instance.isBookmarked(widget.exercise.id);
              return IconButton(
                tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () =>
                    AppState.instance.toggleBookmark(widget.exercise.id),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<File?>(
        future: _pdfFileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator(message: 'Downloading PDF...');
          }
          if (snapshot.data != null) {
            return SfPdfViewer.file(snapshot.data!);
          }
          return EmptyState(
            icon: Icons.picture_as_pdf_outlined,
            title: 'PDF load nahi ho saki',
            subtitle: 'Internet connection check karein aur dobara try '
                'karein, ya is exercise ki PDF abhi upload nahi hui.',
          );
        },
      ),
    );
  }
}
