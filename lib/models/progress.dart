import 'package:hive/hive.dart';

part 'progress.g.dart';

@HiveType(typeId: 1)
class UserProgress extends HiveObject {
  @HiveField(0)
  int stars;

  @HiveField(1)
  int completedWords;

  UserProgress({this.stars = 0, this.completedWords = 0});
}