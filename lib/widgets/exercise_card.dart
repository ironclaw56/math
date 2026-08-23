import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

/// Clickable card representing a single exercise (e.g. "Exercise 1.1")
/// in the Exercise list screen.
class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReview = exercise.title.toLowerCase().contains('review');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                isReview
                    ? Icons.fact_check_rounded
                    : Icons.edit_note_rounded,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  exercise.title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
