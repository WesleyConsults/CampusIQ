import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';

class McqCard extends StatelessWidget {
  final int index;
  final McqQuestion question;
  final String? selectedOption;
  final bool revealed;
  final ValueChanged<String> onOptionTap;

  const McqCard({
    super.key,
    required this.index,
    required this.question,
    required this.selectedOption,
    required this.revealed,
    required this.onOptionTap,
  });

  Color _optionColor(String option) {
    if (!revealed) return Colors.transparent;
    final letter = option.substring(0, 1); // 'A', 'B', 'C', 'D'
    if (letter == question.answer) return Colors.green.shade50;
    if (letter == selectedOption) return Colors.red.shade50;
    return Colors.transparent;
  }

  Color _optionBorderColor(String option) {
    if (!revealed) return Colors.grey.shade300;
    final letter = option.substring(0, 1);
    if (letter == question.answer) return Colors.green.shade400;
    if (letter == selectedOption) return Colors.red.shade300;
    return Colors.grey.shade200;
  }

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
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade700,
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
            ...question.options.map((option) {
              final letter = option.substring(0, 1);
              final isSelected = selectedOption == letter;
              final isCorrect = revealed && letter == question.answer;
              return GestureDetector(
                onTap: revealed ? null : () => onOptionTap(letter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _optionColor(option),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _optionBorderColor(option)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (revealed && isCorrect)
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                      if (revealed && isSelected && !isCorrect)
                        Icon(Icons.cancel, size: 16, color: Colors.red.shade400),
                    ],
                  ),
                ),
              );
            }),
            if (revealed && question.explanation.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 15, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300)),
              ),
          ],
        ),
      ),
    );
  }
}
