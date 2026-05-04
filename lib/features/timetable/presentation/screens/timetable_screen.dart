import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/layout/shell_overlay_padding.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/day_selector.dart';
import 'package:campusiq/features/timetable/presentation/widgets/class_timetable_grid.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/slot_detail_sheet.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  void _onDaySwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 300) return; // ignore slow drags
    final day = ref.read(activeDayProvider);
    final maxDay = TimetableConstants.dayLabels.length - 1;
    if (velocity < 0) {
      // Swipe left → next day
      ref.read(activeDayProvider.notifier).state = (day + 1).clamp(0, maxDay);
    } else {
      // Swipe right → previous day
      ref.read(activeDayProvider.notifier).state = (day - 1).clamp(0, maxDay);
    }
  }

  // ── Class slot actions ──────────────────────────────────────────────────

  Future<void> _openAddClassSheet(
      {TimetableSlotModel? existing,
      int? prefillStart,
      int? prefillEnd}) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);
    final slotCount = await ref.read(slotCountProvider.future);
    final colorValue = TimetableConstants.colorForIndex(slotCount);

    if (!mounted) return;

    final result = await showModalBottomSheet<TimetableSlotModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        colorValue: existing?.colorValue ?? colorValue,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null || !mounted) return;
    final repo = ref.read(timetableRepositoryProvider);
    existing == null
        ? await repo?.addSlot(result)
        : await repo?.updateSlot(result);
  }

  void _showClassDetail(TimetableSlotModel slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddClassSheet(existing: slot),
        onDelete: () =>
            ref.read(timetableRepositoryProvider)?.deleteSlot(slot.id),
      ),
    );
  }

  void _onFreeBlockTap(FreeBlock block) {
    _openAddClassSheet(
        prefillStart: block.startMinutes, prefillEnd: block.endMinutes);
  }

  void _onEmptyTap() {
    _openAddClassSheet();
  }

  void _onFabTap() {
    _openAddClassSheet();
  }

  @override
  Widget build(BuildContext context) {
    final allSlotsAsync = ref.watch(allSlotsProvider);
    final classSlots = ref.watch(activeDaySlotsProvider);
    final freeBlocks = ref.watch(activeDayFreeBlocksProvider);
    final hasActiveSession = ref.watch(activeSessionProvider) != null;
    final activeDay = ref.watch(activeDayProvider);
    final todayIndex = DateTime.now().weekday - 1;
    final highlightedSlot = _resolveHighlightedSlot(
      classSlots,
      isToday: activeDay == todayIndex,
    );
    final hasLoadError = allSlotsAsync.hasError;
    final isLoading = allSlotsAsync.isLoading && !allSlotsAsync.hasValue;
    final bottomContentPadding = shellOverlayBottomPadding(
      context,
      hasActiveSession: hasActiveSession,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Table'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.scanText),
            tooltip: 'Import from image',
            onPressed: () => context.push('/timetable/import'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Add class',
            onPressed: _onFabTap,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onHorizontalDragEnd: _onDaySwipe,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DaySelector(),
                const SizedBox(height: AppSpacing.md),
                _TodaySummaryCard(
                  activeDay: activeDay,
                  classSlots: classSlots,
                  freeBlocks: freeBlocks,
                  highlightedSlot: highlightedSlot,
                  isToday: activeDay == todayIndex,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: CampusSectionHeader(
                        title: 'Daily timeline',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    CampusChip(
                      label: classSlots.isEmpty
                          ? 'Open day'
                          : '${classSlots.length} class${classSlots.length == 1 ? '' : 'es'}',
                      icon: LucideIcons.calendarDays,
                      backgroundColor: classSlots.isEmpty
                          ? AppColors.surfaceMuted
                          : AppColors.goldSoft,
                      foregroundColor: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Builder(
                  builder: (context) {
                    if (hasLoadError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl),
                        child: ErrorRetryWidget(
                          message:
                              'We could not load your timetable right now.',
                          onRetry: () => ref.invalidate(allSlotsProvider),
                        ),
                      );
                    }

                    if (isLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xxxl),
                        child: _LoadingState(),
                      );
                    }

                    if (classSlots.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl),
                        child: _EmptyPage(
                          activeDay: activeDay,
                          onAdd: _onFabTap,
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: bottomContentPadding),
                      child: ClassTimetableGrid(
                        classSlots: classSlots,
                        freeBlocks: freeBlocks,
                        onClassSlotTap: _showClassDetail,
                        onFreeBlockTap: _onFreeBlockTap,
                        onEmptyTap: _onEmptyTap,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TimetableSlotModel? _resolveHighlightedSlot(
  List<TimetableSlotModel> slots, {
  required bool isToday,
}) {
  if (slots.isEmpty) return null;

  if (!isToday) {
    return slots.first;
  }

  final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
  for (final slot in slots) {
    if (slot.endMinutes > nowMinutes) {
      return slot;
    }
  }

  return null;
}

class _TodaySummaryCard extends StatelessWidget {
  final int activeDay;
  final List<TimetableSlotModel> classSlots;
  final List<FreeBlock> freeBlocks;
  final TimetableSlotModel? highlightedSlot;
  final bool isToday;

  const _TodaySummaryCard({
    required this.activeDay,
    required this.classSlots,
    required this.freeBlocks,
    required this.highlightedSlot,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final heading = TimetableConstants.dayFullLabels[activeDay];
    final classSummary = classSlots.isEmpty
        ? 'No classes today'
        : '${classSlots.length} class${classSlots.length == 1 ? '' : 'es'} today';
    final highlightTitle = isToday ? 'Next class' : 'First class';
    final helperLine = classSlots.isEmpty
        ? 'Your day is open.'
        : highlightedSlot == null
            ? classSummary
            : '${highlightedSlot!.courseCode} · ${highlightedSlot!.startTimeLabel}${highlightedSlot!.venue.isEmpty ? '' : ' · ${highlightedSlot!.venue}'}';

    return CampusCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: AppTheme.primary,
                      ),
                ),
              ),
              if (isToday)
                const _CompactSummaryChip(
                  label: 'Today',
                  backgroundColor: AppColors.goldSoft,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxs),
          Text(
            classSummary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  height: 1.25,
                ),
          ),
          if (classSlots.isNotEmpty || highlightedSlot != null) ...[
            const SizedBox(height: AppSpacing.xxxs),
            Text(
              highlightedSlot == null
                  ? helperLine
                  : '$highlightTitle: $helperLine',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.25,
                  ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xxxs),
            Text(
              helperLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.25,
                  ),
            ),
          ],
          if (freeBlocks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _CompactSummaryChip(
              label:
                  '${freeBlocks.length} free block${freeBlocks.length == 1 ? '' : 's'}',
              icon: LucideIcons.clock3,
              backgroundColor: AppColors.surfaceMuted,
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactSummaryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;

  const _CompactSummaryChip({
    required this.label,
    this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppTheme.primary),
              const SizedBox(width: AppSpacing.xxs2),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final int activeDay;
  final VoidCallback onAdd;

  const _EmptyPage({required this.activeDay, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: const Icon(
                LucideIcons.calendarHeart,
                size: 30,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No classes on ${TimetableConstants.dayFullLabels[activeDay]}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your day is open. Add a class or use the free time to study.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(LucideIcons.plus, size: AppIconSizes.md),
              label: const Text('Add class'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Loading your timetable...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
