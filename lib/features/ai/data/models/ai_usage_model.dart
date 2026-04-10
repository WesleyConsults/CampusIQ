import 'package:isar/isar.dart';
part 'ai_usage_model.g.dart';

@collection
class AiUsageModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('feature')])
  late String date; // 'yyyy-MM-dd' format

  late String feature; // 'chat' | 'whatif' | 'insight'
  late int count;
}
