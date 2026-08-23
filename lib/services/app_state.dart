import 'package:flutter/material.dart';

/// Simple in-memory app state (dark mode toggle + bookmarked exercise ids).
///
/// This is intentionally lightweight (ChangeNotifier, no external state
/// management package) so it's easy to swap for Provider/Riverpod/Bloc
/// later without touching screen logic much. For persistence across
/// app restarts, wire this up to shared_preferences when ready.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  final Set<String> _bookmarkedExerciseIds = {};
  Set<String> get bookmarkedExerciseIds => _bookmarkedExerciseIds;

  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  bool isBookmarked(String exerciseId) =>
      _bookmarkedExerciseIds.contains(exerciseId);

  void toggleBookmark(String exerciseId) {
    if (_bookmarkedExerciseIds.contains(exerciseId)) {
      _bookmarkedExerciseIds.remove(exerciseId);
    } else {
      _bookmarkedExerciseIds.add(exerciseId);
    }
    notifyListeners();
  }
}
