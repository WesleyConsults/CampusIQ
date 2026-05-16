import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

const _suggestedProgrammes = [
  'BSc Computer Science',
  'BSc Computer Engineering',
  'BSc Electrical Engineering',
  'BSc Civil Engineering',
  'BSc Mechanical Engineering',
  'BSc Mathematics',
  'BSc Statistics',
  'BSc Chemistry',
  'BSc Physics',
  'BSc Biology',
  'BA Economics',
  'BA Psychology',
  'BA Sociology',
  'BA Political Science',
  'BSc Business Administration',
  'BSc Accounting',
  'BSc Nursing',
  'BSc Pharmacy',
  'BSc Medicine',
  'LLB Law',
];

class OnboardingProgrammeScreen extends ConsumerStatefulWidget {
  const OnboardingProgrammeScreen({super.key});

  @override
  ConsumerState<OnboardingProgrammeScreen> createState() =>
      _OnboardingProgrammeScreenState();
}

class _OnboardingProgrammeScreenState
    extends ConsumerState<OnboardingProgrammeScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final current = ref.read(onboardingProvider).programme;
    _controller = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final query = _controller.text.toLowerCase().trim();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(currentStep: state.step),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        ref.read(onboardingProvider.notifier).goBack(),
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'What do you study?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding:
                    const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.xs),
                child: Text(
                  'This helps us personalise your experience.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                onChanged: (v) {
                  setState(() {});
                  ref.read(onboardingProvider.notifier).setProgramme(v);
                },
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. BSc Computer Engineering',
                  prefixIcon: const Icon(LucideIcons.bookOpen),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() {});
                            ref
                                .read(onboardingProvider.notifier)
                                .setProgramme('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.pill,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                onSubmitted: (_) =>
                    ref.read(onboardingProvider.notifier).goNext(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Popular programmes',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: _suggestedProgrammes
                          .where((p) =>
                              query.isEmpty || p.toLowerCase().contains(query))
                          .map((p) => ActionChip(
                                label: Text(p),
                                onPressed: () {
                                  _controller.text = p;
                                  ref
                                      .read(onboardingProvider.notifier)
                                      .setProgramme(p);
                                  ref
                                      .read(onboardingProvider.notifier)
                                      .goNext();
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () =>
                      ref.read(onboardingProvider.notifier).goNext(),
                  child: const Text('Continue',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
