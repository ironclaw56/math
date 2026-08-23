import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../widgets/exercise_card.dart';
import '../widgets/empty_state.dart';
import 'exercise_content_screen.dart';

/// Shows all exercises belonging to the selected chapter.
class ExerciseScreen extends StatelessWidget {
  final String classDisplayName;
  final ChapterModel chapter;

  const ExerciseScreen({
    super.key,
    required this.classDisplayName,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${chapter.chapterNumber}'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              chapter.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              '$classDisplayName · ${chapter.exercises.length} exercises',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: chapter.exercises.isEmpty
                ? const EmptyState(
                    icon: Icons.menu_book_rounded,
                    title: 'No exercises yet',
                    subtitle: 'Exercises will appear here soon',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: chapter.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = chapter.exercises[index];
                      return ExerciseCard(
                        exercise: exercise,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseContentScreen(
                                chapterTitle:
                                    'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                                exercise: exercise,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
