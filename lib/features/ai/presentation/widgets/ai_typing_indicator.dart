import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiTypingIndicator extends StatelessWidget {
  const AiTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedDot(delay: 0),
              SizedBox(width: 4),
              _AnimatedDot(delay: 100),
              SizedBox(width: 4),
              _AnimatedDot(delay: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final int delay;

  const _AnimatedDot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scaleXY(
          end: 1.2,
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          end: 1.0,
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
