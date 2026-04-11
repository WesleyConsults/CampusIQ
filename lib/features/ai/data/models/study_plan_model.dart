import 'package:isar/isar.dart';
import 'study_plan_slot_model.dart';
part 'study_plan_model.g.dart';

@collection
class StudyPlanModel {
  Id id = 1; // single row — always replace, never append

  late DateTime generatedAt;
  late String weekStartDate; // Monday of the week this was generated for, 'yyyy-MM-dd'

  final slots = IsarLinks<StudyPlanSlotModel>();
}
