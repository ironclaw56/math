import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/exercise_model.dart';
import '../services/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

/// Displays the PDF for a single exercise. The PDF is a bundled app
/// asset (assets/pdfs/<exerciseId>.pdf) — it renders lazily, only when
/// this screen opens, and only Usman (the developer) can add or change
/// it by rebuilding the app.
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
  late Future<bool> _pdfExistsFuture;

  @override
  void initState() {
    super.initState();
    _pdfExistsFuture = _checkPdfExists();
  }

  Future<bool> _checkPdfExists() async {
    try {
      await rootBundle.load(widget.exercise.pdfAssetPath);
      return true;
    } catch (_) {
      return false;
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
      body: FutureBuilder<bool>(
        future: _pdfExistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator(message: 'Loading PDF...');
          }
          if (snapshot.data == true) {
            return SfPdfViewer.asset(widget.exercise.pdfAssetPath);
          }
          return EmptyState(
            icon: Icons.picture_as_pdf_outlined,
            title: 'PDF abhi add nahi hui',
            subtitle: 'Is exercise ka PDF (${widget.exercise.pdfAssetPath}) '
                'assets mein add karke app rebuild karein.',
          );
        },
      ),
    );
  }
}
