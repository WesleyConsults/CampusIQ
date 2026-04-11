import 'package:isar/isar.dart';
part 'weekly_review_model.g.dart';

@collection
class WeeklyReviewModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String weekStartDate; // 'yyyy-MM-dd' of the Monday

  late String summaryText;
  late String wellText;
  late String watchText;
  late String focusText;
  late DateTime generatedAt;
}
