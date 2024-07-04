import 'package:multi_level_feedback_queue_solver_gui/backend/log.dart';

class Logger {
  int time;
  int count;
  List<Log> logs;

  Logger()
      : time = 0,
        count = 0,
        logs = [];

  void incrementTime(int t) {
    time += t;
  }

  void incrementCount() {
    count++;
  }

  int getTime() => time;

  int getCount() => count;

  void addLog(Log log) {
    logs.add(log);
  }

  void printLogs() {
    print("ID\tLevel\tStart\tEnd");
    for (var log in logs) {
      print(log);
    }
  }
}
