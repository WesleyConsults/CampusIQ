import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/review/domain/weekly_review_data.dart';
import 'package:campusiq/features/review/presentation/providers/review_provider.dart';

class WeeklyReviewSheet extends ConsumerStatefulWidget {
  /// If null, shows the current week. Pass a specific weekStart for history.
  final DateTime? weekStart;
  const WeeklyReviewSheet({super.key, this.weekStart});

  @override
  ConsumerState<WeeklyReviewSheet> createState() => _WeeklyReviewSheetState();
}

class _WeeklyReviewSheetState extends ConsumerState<WeeklyReviewSheet> {
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentWeek = widget.weekStart == null;
    final reviewAsync = isCurrentWeek
        ? ref.watch(currentWeekReviewProvider)
        : ref.watch(weekReviewProvider(widget.weekStart!));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md2)),
          ),
          child: reviewAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (data) {
              // Pre-fill note controller once
              if (_noteController.text.isEmpty && data.reflectionNote != null) {
                _noteController.text = data.reflectionNote!;
              }
              return _ReviewContent(
                data: data,
                scrollController: scrollController,
                noteController: _noteController,
                saving: _saving,
                readOnly: !isCurrentWeek,
                onSave: isCurrentWeek
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _saving = true);
                        await ref.read(saveReflectionNoteProvider(
                                _noteController.text.trim())
                            .future);
                        if (!mounted) return;
                        setState(() => _saving = false);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Reflection saved ✓'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                onClose: () => Navigator.of(context).pop(),
              );
            },
          ),
        );
      },
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
    required this.data,
    required this.scrollController,
    required this.noteController,
    required this.saving,
    required this.readOnly,
    required this.onSave,
    required this.onClose,
  });

  final WeeklyReviewData data;
  final ScrollController scrollController;
  final TextEditingController noteController;
  final bool saving;
  final bool readOnly;
  final VoidCallback? onSave;
  final VoidCallback onClose;

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _dateRange() {
    final fmt = DateFormat('d MMM');
    final fmtYear = DateFormat('d MMM yyyy');
    return '${fmt.format(data.weekStart)} – ${fmtYear.format(data.weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(AppRadii.xxxs),
            ),
          ),
        ),

        // ── Header ────────────────────────────────────────────────────────
        const Text(
          '📊 Week in Review',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          _dateRange(),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

        const SizedBox(height: AppSpacing.lg),

        // ── Stats row ─────────────────────────────────────────────────────
        Row(
          children: [
            _StatCard(
              label: 'Studied',
              value: _formatMinutes(data.totalMinutesStudied),
              icon: '📚',
            ),
            const SizedBox(width: AppSpacing.xs2),
            _StatCard(
              label: 'Best day',
              value: data.bestDay ?? '—',
              icon: '📅',
            ),
            const SizedBox(width: AppSpacing.xs2),
            _StatCard(
              label: 'Streak',
              value: '${data.currentStreak}d',
              icon: '🔥',
            ),
          ],
        ).animate().fadeIn(delay: 150.ms, duration: 350.ms).slideY(
              begin: 0.1,
              end: 0,
              delay: 150.ms,
            ),

        const SizedBox(height: AppSpacing.lg),

        // ── Highlights ────────────────────────────────────────────────────
        const Text(
          'Highlights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
        const SizedBox(height: AppSpacing.xs2),

        if (data.mostStudiedCourse == null && data.mostNeglectedCourse == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No sessions logged this week.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ).animate().fadeIn(delay: 280.ms, duration: 300.ms)
        else ...[
          if (data.mostStudiedCourse != null)
            _HighlightChip(
              emoji: '💪',
              label: 'Most studied',
              value: data.mostStudiedCourse!,
              color: AppTheme.success,
            ).animate().fadeIn(delay: 280.ms, duration: 300.ms),
          const SizedBox(height: AppSpacing.xs),
          if (data.mostNeglectedCourse != null)
            _HighlightChip(
              emoji: '⚠️',
              label: 'Needs attention',
              value: data.mostNeglectedCourse!,
              color: const Color(0xFFF59E0B),
            ).animate().fadeIn(delay: 340.ms, duration: 300.ms),
        ],

        const SizedBox(height: AppSpacing.xl),

        // ── Reflection ────────────────────────────────────────────────────
        const Text(
          'What will you improve next week?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
        const SizedBox(height: AppSpacing.xs2),

        TextField(
          controller: noteController,
          readOnly: readOnly,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: readOnly
                ? (noteController.text.isEmpty
                    ? 'No reflection saved for this week.'
                    : null)
                : 'Write your reflection here…',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
        ).animate().fadeIn(delay: 460.ms, duration: 300.ms),

        if (!readOnly) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.xs2)),
              ),
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save note',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
        ],

        const SizedBox(height: AppSpacing.md),

        // ── Close ─────────────────────────────────────────────────────────
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ).animate().fadeIn(delay: 550.ms, duration: 300.ms),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadii.xs2),
        border: Border.all(color: color.withAlpha(60), width: 0.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.xs2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
