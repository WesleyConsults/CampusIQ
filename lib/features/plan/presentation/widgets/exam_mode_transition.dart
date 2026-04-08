import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Full-screen animated overlay shown when Exam Mode is activated.
/// Auto-dismisses after the animation completes (~1.8 s total).
class ExamModeTransition extends StatefulWidget {
  final String firstExamName;

  const ExamModeTransition({super.key, required this.firstExamName});

  @override
  State<ExamModeTransition> createState() => _ExamModeTransitionState();
}

class _ExamModeTransitionState extends State<ExamModeTransition> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after animation
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.deepOrange[700]!.withValues(alpha: 0.95),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 72))
                    .animate()
                    .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 20),
                const Text(
                  'EXAM MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'ACTIVATED',
                  style: TextStyle(
                    color: Colors.orange[100],
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 24),
                Text(
                  'Next: ${widget.firstExamName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms);
  }
}
