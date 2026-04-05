import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlanProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const PlanProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  double get _progress => total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

  Color _barColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF1D9E75); // green
    if (progress >= 0.67) return const Color(0xFF1565C0); // blue
    if (progress >= 0.34) return const Color(0xFFF59E0B); // amber
    return const Color(0xFFE8593C);                        // red-ish
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    final percent = (progress * 100).round();
    final color = _barColor(progress);
    final isDone = total > 0 && completed >= total;

    Widget bar = LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Percentage label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDone ? 'Complete!' : '$percent% done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$completed / $total tasks',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress track
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    width: constraints.maxWidth,
                    color: Colors.grey.shade200,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOut,
                    height: 12,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (isDone) {
      bar = bar
          .animate(key: const ValueKey('bar-done'))
          .scaleXY(
            begin: 1.0,
            end: 1.02,
            duration: 250.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scaleXY(
            begin: 1.02,
            end: 1.0,
            duration: 250.ms,
            curve: Curves.easeIn,
          );
    }

    return bar;
  }
}
