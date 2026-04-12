import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/personal_slot_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/day_selector.dart';
import 'package:campusiq/features/timetable/presentation/widgets/dual_layer_grid.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_personal_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/slot_detail_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/personal_slot_detail_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_page_indicator.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  /// Page order: 0=Class Only, 1=Both, 2=Personal Only
  static const _modeForPage = [
    GridLayerMode.classOnly,
    GridLayerMode.both,
    GridLayerMode.personalOnly,
  ];

  @override
  void initState() {
    super.initState();
    // Start on "Both" (page 1)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timetablePageProvider.notifier).state = 1;
    });
  }

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

  Future<void> _openAddClassSheet({TimetableSlotModel? existing, int? prefillStart, int? prefillEnd}) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);
    final slotCount = await ref.read(slotCountProvider.future);
    final colorValue = TimetableConstants.colorForIndex(slotCount);

    if (!mounted) return;

    final result = await showModalBottomSheet<TimetableSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
    existing == null ? await repo?.addSlot(result) : await repo?.updateSlot(result);
  }

  void _showClassDetail(TimetableSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddClassSheet(existing: slot),
        onDelete: () => ref.read(timetableRepositoryProvider)?.deleteSlot(slot.id),
      ),
    );
  }

  // ── Personal slot actions ───────────────────────────────────────────────

  Future<void> _openAddPersonalSheet({PersonalSlotModel? existing, int? prefillStart, int? prefillEnd}) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);

    final result = await showModalBottomSheet<PersonalSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddPersonalSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null || !mounted) return;
    final repo = ref.read(personalSlotRepositoryProvider);
    existing == null ? await repo?.addSlot(result) : await repo?.updateSlot(result);
  }

  void _showPersonalDetail(PersonalSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => PersonalSlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddPersonalSheet(existing: slot),
        onDelete: () => ref.read(personalSlotRepositoryProvider)?.deleteSlot(slot.id),
      ),
    );
  }

  void _onFreeBlockTap(FreeBlock block) {
    // In Both/Class view → add class. In Personal view → add personal.
    final page = ref.read(timetablePageProvider);
    if (page == 2) {
      _openAddPersonalSheet(prefillStart: block.startMinutes, prefillEnd: block.endMinutes);
    } else {
      _openAddClassSheet(prefillStart: block.startMinutes, prefillEnd: block.endMinutes);
    }
  }

  void _onEmptyTap() {
    final page = ref.read(timetablePageProvider);
    page == 2 ? _openAddPersonalSheet() : _openAddClassSheet();
  }

  void _onFabTap() {
    final page = ref.read(timetablePageProvider);
    page == 2 ? _openAddPersonalSheet() : _openAddClassSheet();
  }

  @override
  Widget build(BuildContext context) {
    final classSlots    = ref.watch(activeDaySlotsProvider);
    final personalSlots = ref.watch(activeDayPersonalSlotsProvider);
    final freeBlocks    = ref.watch(activeDayFreeBlocksProvider);
    final activeDay     = ref.watch(activeDayProvider);
    final currentPage   = ref.watch(timetablePageProvider);

    final mode = _modeForPage[currentPage];
    final fabLabel = currentPage == 2 ? 'Add Block' : 'Add Class';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Timetable', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: 'Import from image',
            onPressed: () => context.push('/timetable/import'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onFabTap,
          ),
        ],
      ),
      body: Column(
        children: [
          const DaySelector(),

          // View mode indicator — tap to switch Class / Both / Personal
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TimetablePageIndicator(
              currentPage: currentPage,
              onPageSelected: (page) =>
                  ref.read(timetablePageProvider.notifier).state = page,
            ),
          ),

          // Day label + free block count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Text(
                  TimetableConstants.dayFullLabels[activeDay],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                if (freeBlocks.isNotEmpty && mode != GridLayerMode.personalOnly)
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

          // Grid — swipe left/right to change day, tap indicator to switch view
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: _onDaySwipe,
              child: () {
                final isEmpty =
                    (mode == GridLayerMode.classOnly && classSlots.isEmpty) ||
                    (mode == GridLayerMode.personalOnly && personalSlots.isEmpty) ||
                    (mode == GridLayerMode.both &&
                        classSlots.isEmpty &&
                        personalSlots.isEmpty);

                if (isEmpty) {
                  return _EmptyPage(mode: mode, onAdd: _onFabTap);
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DualLayerGrid(
                    classSlots: classSlots,
                    personalSlots: personalSlots,
                    freeBlocks: freeBlocks,
                    mode: mode,
                    onClassSlotTap: _showClassDetail,
                    onPersonalSlotTap: _showPersonalDetail,
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
        label: Text(fabLabel),
      ),
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final GridLayerMode mode;
  final VoidCallback onAdd;

  const _EmptyPage({required this.mode, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final message = switch (mode) {
      GridLayerMode.classOnly    => 'No classes today',
      GridLayerMode.personalOnly => 'No personal blocks today',
      GridLayerMode.both         => 'Nothing scheduled today',
    };
    final hint = switch (mode) {
      GridLayerMode.classOnly    => 'Tap + to add a class',
      GridLayerMode.personalOnly => 'Tap + to add a personal block',
      GridLayerMode.both         => 'Tap + to add a class or block',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add')),
        ],
      ),
    );
  }
}
