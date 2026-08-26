import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/chapter_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClassModel>(
      future: _classFuture,
      builder: (context, snapshot) {
        final classTitle = snapshot.data?.displayName ?? '';
        return Scaffold(
          appBar: AppBar(
            title: Text(classTitle.isEmpty ? 'Chapters' : classTitle),
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
