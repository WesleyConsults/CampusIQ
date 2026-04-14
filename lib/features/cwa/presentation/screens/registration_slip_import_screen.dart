import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/domain/registration_course_import.dart';
import 'package:campusiq/features/cwa/presentation/providers/registration_slip_import_provider.dart';

class RegistrationSlipImportScreen extends ConsumerWidget {
  const RegistrationSlipImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationSlipImportNotifierProvider);
    final notifier =
        ref.read(registrationSlipImportNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Scan Registration Slip'),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: switch (state.step) {
        SlipImportStep.idle => _IdleView(notifier: notifier),
        SlipImportStep.picking || SlipImportStep.parsing => _LoadingView(
            state.step == SlipImportStep.parsing
                ? 'AI is reading your slip…'
                : 'Opening file…',
          ),
        SlipImportStep.reviewing => _ReviewView(state: state, notifier: notifier),
        SlipImportStep.saving => const _LoadingView('Saving courses…'),
        SlipImportStep.done => _DoneView(
            count: state.selectedIndexes.length,
            onFinish: () {
              notifier.reset();
              Navigator.of(context).pop();
            },
          ),
        SlipImportStep.error => _ErrorView(
            message: state.errorMessage ?? 'Unknown error.',
            onRetry: notifier.reset,
          ),
      },
    );
  }
}

// ─── Idle ─────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final RegistrationSlipImportNotifier notifier;
  const _IdleView({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Import your courses',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your course registration slip and the AI will extract your courses automatically.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          _OptionTile(
            icon: Icons.camera_alt_outlined,
            label: 'Take a photo',
            subtitle: 'Use your camera to capture the slip',
            onTap: notifier.pickFromCamera,
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.photo_library_outlined,
            label: 'Upload image from gallery',
            subtitle: 'Pick a JPG or PNG from your photos',
            onTap: notifier.pickFromGallery,
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Choose a PDF',
            subtitle: 'Upload a PDF registration slip',
            onTap: notifier.pickFromGalleryOrFile,
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Credit hours are read from the slip.\nYou can adjust them before saving.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Review ───────────────────────────────────────────────────────────────────

class _ReviewView extends StatelessWidget {
  final SlipImportState state;
  final RegistrationSlipImportNotifier notifier;

  const _ReviewView({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIndexes.length;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.courses.length} courses found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: selected == state.courses.length
                    ? notifier.deselectAll
                    : notifier.selectAll,
                child: Text(
                  selected == state.courses.length
                      ? 'Deselect all'
                      : 'Select all',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Adjust credit hours if needed, then tap Import.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 8),

        // Course list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: state.courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final course = state.courses[i];
              final isSelected = state.selectedIndexes.contains(i);

              return _ReviewCourseCard(
                course: course,
                isSelected: isSelected,
                onToggle: () => notifier.toggleCourse(i),
                onCreditChanged: (v) => notifier.setCreditHours(i, v),
              );
            },
          ),
        ),

        // Confirm button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    selected == 0 ? null : notifier.confirmImport,
                icon: const Icon(Icons.check),
                label: Text(
                  selected == 0
                      ? 'Select at least one course'
                      : 'Import $selected course${selected == 1 ? '' : 's'}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCourseCard extends StatelessWidget {
  final RegistrationCourseImport course;
  final bool isSelected;
  final VoidCallback onToggle;
  final ValueChanged<double> onCreditChanged;

  const _ReviewCourseCard({
    required this.course,
    required this.isSelected,
    required this.onToggle,
    required this.onCreditChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white : AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseCode.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.courseName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Credit hours',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          _CreditStepper(
                            value: course.creditHours,
                            onChanged: onCreditChanged,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditStepper extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _CreditStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: value > 1 ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${value.toInt()}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppTheme.primary,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onTap: value < 6 ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppTheme.primary : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final int count;
  final VoidCallback onFinish;

  const _DoneView({required this.count, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              '$count course${count == 1 ? '' : 's'} added to CWA',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can update expected scores and credit hours from the CWA screen.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: AppTheme.warning),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
