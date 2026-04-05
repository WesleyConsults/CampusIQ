import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/day_selector.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_grid.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/slot_detail_sheet.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref, {
    TimetableSlotModel? existing,
    int? prefillStart,
    int? prefillEnd,
  }) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);
    final slotCount = await ref.read(slotCountProvider.future);
    final colorValue = TimetableConstants.colorForIndex(slotCount);

    if (!context.mounted) return;

    final result = await showModalBottomSheet<TimetableSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        colorValue: existing?.colorValue ?? colorValue,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null) return;
    final repo = ref.read(timetableRepositoryProvider);
    if (repo == null) return;

    existing == null ? await repo.addSlot(result) : await repo.updateSlot(result);
  }

  void _openDetailSheet(BuildContext context, WidgetRef ref, TimetableSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddSheet(context, ref, existing: slot),
        onDelete: () {
          final repo = ref.read(timetableRepositoryProvider);
          repo?.deleteSlot(slot.id);
        },
      ),
    );
  }

  void _onFreeBlockTap(BuildContext context, WidgetRef ref, FreeBlock block) {
    _openAddSheet(
      context,
      ref,
      prefillStart: block.startMinutes,
      prefillEnd: block.endMinutes,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(activeDaySlotsProvider);
    final freeBlocks = ref.watch(activeDayFreeBlocksProvider);
    final activeDay = ref.watch(activeDayProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Timetable', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add class',
            onPressed: () => _openAddSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const DaySelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  TimetableConstants.dayFullLabels[activeDay],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
          Expanded(
            child: slots.isEmpty
                ? _EmptyDay(onAdd: () => _openAddSheet(context, ref))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TimetableGrid(
                      slots: slots,
                      freeBlocks: freeBlocks,
                      onSlotTap: (s) => _openDetailSheet(context, ref, s),
                      onSlotLongPress: (s) => _openDetailSheet(context, ref, s),
                      onFreeBlockTap: (b) => _onFreeBlockTap(context, ref, b),
                      onEmptyCellTap: () => _openAddSheet(context, ref),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text('No classes today', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Tap + to add a class slot', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Class'),
          ),
        ],
      ),
    );
  }
}
