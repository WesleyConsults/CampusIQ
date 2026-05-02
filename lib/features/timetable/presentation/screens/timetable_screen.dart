import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
    final classSlots = ref.watch(activeDaySlotsProvider);
    final freeBlocks = ref.watch(activeDayFreeBlocksProvider);
    final activeDay = ref.watch(activeDayProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Go to Today',
          icon: const Icon(Icons.home_outlined, semanticLabel: 'Go to Today'),
          onPressed: () => context.go('/plan'),
        ),
        title:
            const Text('Table', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          const StreakActionButton(),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: 'Import from image',
            onPressed: () => context.push('/timetable/import'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add class',
            onPressed: _onFabTap,
          ),
        ],
      ),
      body: Column(
        children: [
          const DaySelector(),

          // Day label + free block count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  TimetableConstants.dayFullLabels[activeDay],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                if (freeBlocks.isNotEmpty)
                  Text(
                    '${freeBlocks.length} free block${freeBlocks.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.success.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Grid — swipe left/right to change day
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: _onDaySwipe,
              child: () {
                if (classSlots.isEmpty) {
                  return _EmptyPage(onAdd: _onFabTap);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClassTimetableGrid(
                    classSlots: classSlots,
                    freeBlocks: freeBlocks,
                    onClassSlotTap: _showClassDetail,
                    onFreeBlockTap: _onFreeBlockTap,
                    onEmptyTap: _onEmptyTap,
                  ),
                );
              }(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabTap,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPage({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text('No classes today',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Tap + to add a class',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add')),
        ],
      ),
    );
  }
}
