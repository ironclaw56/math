import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/class_model.dart';
import '../models/chapter_model.dart';
import '../models/exercise_model.dart';
import '../services/data_service.dart';
import '../services/app_state.dart';
import '../widgets/chapter_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/empty_state.dart';
import 'exercise_screen.dart';

/// Shows all chapters for the selected class as Material cards.
class ChapterScreen extends StatefulWidget {
  final String classId;

  const ChapterScreen({super.key, required this.classId});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Future<ClassModel> _classFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _classFuture = DataService.instance.loadClass(widget.classId);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChapterModel> _filterChapters(List<ChapterModel> chapters) {
    if (_query.isEmpty) return chapters;
    return chapters
        .where((c) =>
            c.title.toLowerCase().contains(_query) ||
            'chapter ${c.chapterNumber}'.contains(_query))
        .toList();
  }

  /// Downloads every exercise PDF for this class that isn't already
  /// cached on the device, showing a live progress dialog.
  Future<void> _downloadAllPdfs(ClassModel classModel) async {
    final allExercises = <ExerciseModel>[
      for (final chapter in classModel.chapters) ...chapter.exercises,
    ];

    final dir = await getApplicationDocumentsDirectory();

    // Figure out how many are already cached vs still need downloading.
    final toDownload = <ExerciseModel>[];
    for (final ex in allExercises) {
      final file = File('${dir.path}/${ex.cacheFileName}');
      if (!await file.exists()) {
        toDownload.add(ex);
      }
    }

    if (toDownload.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Is class ki saari PDFs pehle se download hain ✓'),
          ),
        );
      }
      return;
    }

    int completed = 0;
    int failed = 0;
    final total = toDownload.length;

    if (!mounted) return;

    // Progress dialog — updates live as each PDF finishes.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Kick off the download loop once, on first build.
            if (completed == 0 && failed == 0) {
              () async {
                for (final ex in toDownload) {
                  try {
                    final response = await http.get(Uri.parse(ex.pdfUrl));
                    if (response.statusCode == 200) {
                      final file = File('${dir.path}/${ex.cacheFileName}');
                      await file.writeAsBytes(response.bodyBytes);
                    } else {
                      failed++;
                    }
                  } catch (_) {
                    failed++;
                  }
                  completed++;
                  if (dialogContext.mounted) {
                    setDialogState(() {});
                  }
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }();
            }

            final progress = total == 0 ? 0.0 : completed / total;
            final percent = (progress * 100).round();

            return AlertDialog(
              title: const Text('PDFs download ho rahi hain'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text('$percent% complete  •  $completed / $total files'),
                  if (failed > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '$failed file(s) fail ho gayi (internet check karein)',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failed == 0
                ? 'Saari PDFs download ho gayin ✓'
                : '${total - failed} PDFs download hui, $failed fail hui',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel>(
      future: _classFuture,
      builder: (context, snapshot) {
        final classTitle = snapshot.data?.displayName ?? '';
        final classModel = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(classTitle.isEmpty ? 'Chapters' : classTitle),
            actions: [
              if (classModel != null)
                IconButton(
                  tooltip: 'Download all PDFs',
                  icon: const Icon(Icons.download_for_offline_outlined),
                  onPressed: () => _downloadAllPdfs(classModel),
                ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingIndicator(message: 'Loading chapters...');
              }
              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load chapters',
                  subtitle: '${snapshot.error}',
                );
              }
              final classModel = snapshot.data!;
              final chapters = _filterChapters(classModel.chapters);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search chapters...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: chapters.isEmpty
                        ? const EmptyState(
                            title: 'No chapters found',
                            subtitle: 'Try a different search term',
                          )
                        : AnimatedBuilder(
                            animation: AppState.instance,
                            builder: (context, _) {
                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                    top: 8, bottom: 24),
                                itemCount: chapters.length,
                                itemBuilder: (context, index) {
                                  final chapter = chapters[index];
                                  final bookmarkKey =
                                      '${widget.classId}-${chapter.id}';
                                  return ChapterCard(
                                    chapter: chapter,
                                    isBookmarked: AppState.instance
                                        .isBookmarked(bookmarkKey),
                                    onBookmarkTap: () => AppState.instance
                                        .toggleBookmark(bookmarkKey),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ExerciseScreen(
                                            classDisplayName:
                                                classModel.displayName,
                                            chapter: chapter,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
