class Job {
  String id;
  int arrivalTime;
  int burstTime;
  int remainingTime;
  int level;
  int endTime;
  int turnAroundTime;
  int waitingTime;
  int quantumTime;

  Job({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
  })  : remainingTime = burstTime,
        level = 0,
        endTime = arrivalTime,
        turnAroundTime = 0,
        waitingTime = 0,
        quantumTime = 0;

  Job.full({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    required this.remainingTime,
    required this.level,
    required this.endTime,
    required this.turnAroundTime,
    required this.waitingTime,
  }) : quantumTime = 0;

  String getId() => id;

  int getArrivalTime() => arrivalTime;

  int getRemainingTime() => remainingTime;

  set setRemainingTime(int time) => remainingTime = time;

  void incrementLevel() {
    level++;
  }

  int getLevel() => level;

  int getTurnAroundTime() => turnAroundTime;

  int getWaitingTime() => waitingTime;

  void decrementRemainingTime(int time) {
    remainingTime -= time;
  }

  bool isDone() => remainingTime == 0;

  set setEndTime(int time) => endTime = time;

  void incrementEndTime(int time) {
    endTime += time;
  }

  void calculateTurnAroundTime() {
    turnAroundTime = endTime - arrivalTime;
  }

  void calculateWaitingTime() {
    waitingTime = turnAroundTime - burstTime;
  }

  int getQuantumTime() => quantumTime;

  void incrementQuantumTime() {
    quantumTime++;
  }

  void resetQuantumTime() {
    quantumTime = 0;
  }

  Job copy() {
    return Job.full(
      id: id,
      arrivalTime: arrivalTime,
      burstTime: burstTime,
      remainingTime: remainingTime,
      level: level,
      endTime: endTime,
      turnAroundTime: turnAroundTime,
      waitingTime: waitingTime,
    );
  }

  @override
  String toString() {
    return '$id\t$arrivalTime\t$burstTime\t$remainingTime\t$level\t$endTime\t$turnAroundTime\t$waitingTime';
  }
}
