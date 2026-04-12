import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';
import 'package:campusiq/features/ai/presentation/providers/exam_prep_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/question_type_selector.dart';
import 'package:campusiq/features/ai/presentation/widgets/mcq_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/short_answer_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/flashcard_widget.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';

// Scoped exam prep provider — one per courseCode, separate from the global examPrepProvider
final hubExamPrepProvider =
    StateNotifierProvider.family<ExamPrepNotifier, ExamPrepState, String>(
  (ref, courseCode) => ExamPrepNotifier(ref),
);

class HubFlashcardsTab extends ConsumerStatefulWidget {
  final CourseModel course;

  const HubFlashcardsTab({super.key, required this.course});

  @override
  ConsumerState<HubFlashcardsTab> createState() =>
      _HubFlashcardsTabState();
}

class _HubFlashcardsTabState extends ConsumerState<HubFlashcardsTab> {
  late final TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    // Pre-select this course immediately
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(hubExamPrepProvider(widget.course.code).notifier)
          .selectCourse(
            widget.course.id.toString(),
            widget.course.code,
            widget.course.name,
          );
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hubExamPrepProvider(widget.course.code));
    final notifier =
        ref.read(hubExamPrepProvider(widget.course.code).notifier);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed course chip
                Row(
                  children: [
                    const Text('Course:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        '${widget.course.code} — ${widget.course.name}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text('Question Type',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                QuestionTypeSelector(
                  selected: state.questionType,
                  onChanged: notifier.setQuestionType,
                ),

                const SizedBox(height: 16),

                const Text('Topic (optional)',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _topicController,
                  onChanged: notifier.setTopic,
                  decoration: InputDecoration(
                    hintText:
                        "e.g. Integration, or leave blank for general questions",
                    hintStyle: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 16),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                          color: Colors.red.shade600, fontSize: 13),
                    ),
                  ),

                if (state.isAtLimit)
                  const PremiumGateWidget()
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          state.isLoading ? null : notifier.generate,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        state.questions.isEmpty
                            ? 'Generate 5 Questions'
                            : 'Generate 5 More',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        if (state.isLoading && state.questions.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) =>
                  _buildCard(context, state, notifier, i, state.questions[i]),
              childCount: state.questions.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    ExamPrepState state,
    ExamPrepNotifier notifier,
    int index,
    ExamQuestion question,
  ) {
    return switch (question) {
      McqQuestion q => McqCard(
          index: index,
          question: q,
          selectedOption: state.selectedAnswer[index],
          revealed: state.revealed[index] ?? false,
          onOptionTap: (opt) => notifier.selectMcqOption(index, opt),
        ),
      ShortAnswerQuestion q => ShortAnswerCard(
          index: index,
          question: q,
          revealed: state.revealed[index] ?? false,
          onReveal: () => notifier.revealAnswer(index),
        ),
      FlashCard q => FlashCardWidget(
          index: index,
          card: q,
        ),
    };
  }
}
