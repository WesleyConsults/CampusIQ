import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';

class ShortAnswerCard extends StatelessWidget {
  final int index;
  final ShortAnswerQuestion question;
  final bool revealed;
  final VoidCallback onReveal;

  const ShortAnswerCard({
    super.key,
    required this.index,
    required this.question,
    required this.revealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!revealed)
              OutlinedButton.icon(
                onPressed: onReveal,
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Show Answer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal.shade700,
                  side: BorderSide(color: Colors.teal.shade300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  question.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.teal.shade900,
                    height: 1.5,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 300))
                  .slideY(
                    begin: -0.1,
                    end: 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
          ],
        ),
      ),
    );
  }
}
