import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';
import 'package:campusiq/features/ai/presentation/providers/exam_prep_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/question_type_selector.dart';
import 'package:campusiq/features/ai/presentation/widgets/mcq_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/short_answer_card.dart';
import 'package:campusiq/features/ai/presentation/widgets/flashcard_widget.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

class ExamPrepScreen extends ConsumerStatefulWidget {
  const ExamPrepScreen({super.key});

  @override
  ConsumerState<ExamPrepScreen> createState() => _ExamPrepScreenState();
}

class _ExamPrepScreenState extends ConsumerState<ExamPrepScreen> {
  late final TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examPrepProvider);
    final notifier = ref.read(examPrepProvider.notifier);
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Prep',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (state.questions.isNotEmpty)
            TextButton(
              onPressed: notifier.clearQuestions,
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Controls ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course picker
                  const Text(
                    'Select Course',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  coursesAsync.when(
                    loading: () => const Center(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )),
                    error: (e, _) => Text('Error loading courses: $e',
                        style: TextStyle(color: Colors.red.shade600)),
                    data: (courses) {
                      if (courses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No courses found. Add courses in the CWA tab first.',
                            style:
                                TextStyle(fontSize: 13, color: Colors.orange),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: courses.map((course) {
                          final isSelected =
                              state.selectedCourseId == course.id.toString();
                          return FilterChip(
                            label: Text(course.code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                )),
                            selected: isSelected,
                            onSelected: (_) => notifier.selectCourse(
                              course.id.toString(),
                              course.code,
                              course.name,
                            ),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Question type selector
                  const Text(
                    'Question Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  QuestionTypeSelector(
                    selected: state.questionType,
                    onChanged: notifier.setQuestionType,
                  ),

                  const SizedBox(height: 16),

                  // Topic field
                  const Text(
                    'Topic (optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _topicController,
                    onChanged: notifier.setTopic,
                    decoration: InputDecoration(
                      hintText: "e.g. Thevenin's Theorem, or leave blank",
                      hintStyle: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 16),

                  // Error
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                            color: Colors.red.shade600, fontSize: 13),
                      ),
                    ),

                  // Generate button
                  if (state.isAtLimit)
                    const PremiumGateWidget()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.isLoading ? null : notifier.generate,
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          state.questions.isEmpty
                              ? 'Generate 5 Questions'
                              : 'Generate 5 More',
                          style: const TextStyle(fontWeight: FontWeight.w600),
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

          // ── Questions ─────────────────────────────────────────────────────
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
                (context, i) => _buildQuestionCard(
                  context,
                  state,
                  notifier,
                  i,
                  state.questions[i],
                ),
                childCount: state.questions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
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
