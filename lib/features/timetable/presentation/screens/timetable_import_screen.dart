import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_import_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/import_slot_review_tile.dart';

class TimetableImportScreen extends ConsumerWidget {
  const TimetableImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timetableImportNotifierProvider);
    final notifier = ref.read(timetableImportNotifierProvider.notifier);

    // Auto-navigate when done
    ref.listen(timetableImportNotifierProvider, (_, next) {
      if (next.step == ImportStep.done) {
        notifier.reset();
        context.go('/timetable');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'Import Timetable',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            context.pop();
          },
        ),
        actions: [
          if (state.step == ImportStep.reviewing)
            TextButton(
              onPressed: state.selectedIndexes.isNotEmpty
                  ? () => notifier.confirmImport()
                  : null,
              child: Text(
                'Import (${state.selectedIndexes.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: switch (state.step) {
        ImportStep.idle =>
          _IdleBody(onPick: (source) => notifier.pickAndParse(source)),
        ImportStep.picking => const _LoadingBody(message: 'Opening camera…'),
        ImportStep.parsing =>
          const _LoadingBody(message: 'Extracting timetable…'),
        ImportStep.reviewing => _ReviewBody(state: state, notifier: notifier),
        ImportStep.saving =>
          _ReviewBody(state: state, notifier: notifier, isSaving: true),
        ImportStep.done => const _LoadingBody(message: 'Saving…'),
        ImportStep.error => _ErrorBody(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: notifier.reset,
          ),
      },
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  final void Function(ImageSource) onPick;

  const _IdleBody({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Import from Image',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Take a photo or upload an image of your university timetable and we\'ll fill it in automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                onPressed: () => onPick(ImageSource.camera),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from Gallery'),
                onPressed: () => onPick(ImageSource.gallery),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  final String message;

  const _LoadingBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
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

// ── Review ────────────────────────────────────────────────────────────────────

class _ReviewBody extends StatelessWidget {
  final TimetableImportState state;
  final TimetableImportNotifier notifier;
  final bool isSaving;

  const _ReviewBody({
    required this.state,
    required this.notifier,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = state.selectedIndexes.length == state.slots.length;

    return Stack(
      children: [
        Column(
          children: [
            // Select all / deselect all bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.cardBg,
              child: Row(
                children: [
                  Text(
                    '${state.slots.length} slot${state.slots.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        allSelected ? notifier.deselectAll : notifier.selectAll,
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Slot list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.slots.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) => ImportSlotReviewTile(
                  index: i,
                  slot: state.slots[i],
                  isSelected: state.selectedIndexes.contains(i),
                ),
              ),
            ),

            // Bottom confirm bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.selectedIndexes.isNotEmpty
                        ? () => notifier.confirmImport()
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor:
                          AppTheme.textSecondary.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    child: Text(
                      state.selectedIndexes.isEmpty
                          ? 'Select slots to import'
                          : 'Import ${state.selectedIndexes.length} Slot${state.selectedIndexes.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Saving overlay
        if (isSaving)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Saving slots…'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppTheme.warning),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
