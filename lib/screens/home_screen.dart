import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/exercise_model.dart';
import '../services/data_service.dart';
import '../widgets/class_button.dart';
import 'chapter_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

/// Home screen: app title + four large gradient buttons for
/// Class 9 / 10 / 11 / 12, each with its own "download all PDFs" icon.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Formats milliseconds as a short WhatsApp-style remaining-time label.
  static String _formatRemaining(int ms) {
    final seconds = (ms / 1000).ceil();
    if (seconds <= 1) return '1 sec remaining';
    if (seconds < 60) return '$seconds sec remaining';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s remaining';
  }

  /// Downloads every exercise PDF for [classId] that isn't already
  /// cached, showing a live progress dialog with a percentage and a
  /// WhatsApp-style "X sec remaining" estimate.
  Future<void> _downloadAllPdfs(
    BuildContext context,
    String classId,
    String classDisplayName,
  ) async {
    // Small loading toast while we read the chapter/exercise list.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$classDisplayName ki list taiyar ho rahi hai...'),
        duration: const Duration(seconds: 1),
      ),
    );

    final classModel = await DataService.instance.loadClass(classId);
    final allExercises = <ExerciseModel>[
      for (final chapter in classModel.chapters) ...chapter.exercises,
    ];

    final dir = await getApplicationDocumentsDirectory();

    final toDownload = <ExerciseModel>[];
    for (final ex in allExercises) {
      final file = File('${dir.path}/${ex.cacheFileName}');
      if (!await file.exists()) {
        toDownload.add(ex);
      }
    }

    if (toDownload.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$classDisplayName ki saari PDFs pehle se download hain ✓',
            ),
          ),
        );
      }
      return;
    }

    int completed = 0;
    int failed = 0;
    final total = toDownload.length;
    final stopwatch = Stopwatch()..start();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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

            final elapsedMs = stopwatch.elapsedMilliseconds;
            final remainingCount = total - completed;
            String remainingLabel = 'Calculating...';
            if (completed > 0 && remainingCount > 0) {
              final avgPerFile = elapsedMs / completed;
              remainingLabel =
                  _formatRemaining((avgPerFile * remainingCount).round());
            } else if (remainingCount == 0) {
              remainingLabel = 'Almost done...';
            }

            return AlertDialog(
              title: Text('$classDisplayName ki PDFs download ho rahi hain'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text('$percent%  •  $completed / $total files'),
                  const SizedBox(height: 4),
                  Text(
                    remainingLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (failed > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '$failed file(s) fail ho gayi',
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

    stopwatch.stop();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failed == 0
                ? '$classDisplayName ki saari PDFs download ho gayin ✓'
                : '${total - failed} PDFs download hui, $failed fail hui',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classMeta = DataService.instance.classMetaList;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              actions: [
                IconButton(
                  tooltip: 'About',
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  // Math-themed header icon (now links to YouTube)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse('APNA_YOUTUBE_LINK_YAHAN_DAALEIN');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFFF5252)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Absolute Mathametic',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select your class to begin',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),
                  ...classMeta.map(
                    (meta) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClassButton(
                        emoji: meta.emoji,
                        label: meta.displayName,
                        gradientColors: meta.gradient,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChapterScreen(classId: meta.id),
                            ),
                          );
                        },
                        onDownloadTap: () => _downloadAllPdfs(
                          context,
                          meta.id,
                          meta.displayName,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
