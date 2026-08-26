import 'package:flutter/material.dart';

/// Large gradient button used on the Home screen for each class
/// (Class 9 / 10 / 11 / 12). Reusable so future class levels (e.g.
/// "Class 8" or "O-Level") can be added with zero new UI code.
class ClassButton extends StatelessWidget {
  final String emoji;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  /// Optional — shows a small download icon on the button. Tapping it
  /// downloads all PDFs for this class without opening the class.
  final VoidCallback? onDownloadTap;

  const ClassButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.gradientColors,
    required this.onTap,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.white.withValues(alpha: 0.25),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onDownloadTap != null)
                  IconButton(
                    tooltip: 'Download all PDFs',
                    icon: const Icon(
                      Icons.download_for_offline_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: onDownloadTap,
                  ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
