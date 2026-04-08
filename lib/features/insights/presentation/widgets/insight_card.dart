import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:campusiq/features/insights/domain/insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.index,
  });

  final Insight insight;
  final int index;

  Color get _stripColor {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFF59E0B); // amber
      case InsightType.positive:
        return const Color(0xFF10B981); // green
      case InsightType.neutral:
        return const Color(0xFF3B82F6); // blue
      case InsightType.tip:
        return const Color(0xFF8B5CF6); // purple
    }
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
        ),
        SlideEffect(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
          delay: Duration(milliseconds: 60 * index),
          duration: 350.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colour strip
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _stripColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Emoji icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Text(
                  insight.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        insight.message,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (insight.courseCode != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _stripColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _stripColor.withAlpha(80), width: 0.5),
                          ),
                          child: Text(
                            insight.courseCode!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _stripColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
