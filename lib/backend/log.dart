class Log {
  String id;
  int level;
  int startTime;
  int? endTime;

  Log({
    required this.id,
    required this.level,
    required this.startTime,
  });

  String getId() => id;

  int getLevel() => level;

  int getStartTime() => startTime;

  int? getEndTime() => endTime;

  set setEndTime(int time) => endTime = time;

  @override
  String toString() {
    return '$id\t$level\t$startTime\t$endTime';
  }
}
