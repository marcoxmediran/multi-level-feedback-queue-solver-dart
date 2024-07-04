import 'package:multi_level_feedback_queue_solver_gui/backend/job.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/logger.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/log.dart';

class Queue {
  String name;
  List<Job> queue;
  Queue? next;
  Queue? result;

  Queue.fromTimeline(List<Job> timeline, this.name)
      : queue = List<Job>.from(timeline);

  Queue.fromQueue(Queue input, this.name) : queue = List<Job>.from(input.queue);

  Queue(this.name) : queue = [];

  String getName() => name;

  void enqueue(Job job) {
    queue.add(job);
  }

  Job dequeue() {
    return queue.removeAt(0);
  }

  void offer() {
    Job toOffer = dequeue();
    toOffer.incrementLevel();
    next?.enqueue(toOffer);
  }

  void moveToResult() {
    result?.enqueue(dequeue());
  }

  void requeue() {
    enqueue(dequeue());
  }

  Job front() {
    return queue.first;
  }

  int size() {
    return queue.length;
  }

  bool isEmpty() {
    return queue.isEmpty;
  }

  set setNextQueue(Queue? nextQueue) => next = nextQueue;

  set setResultQueue(Queue? resultQueue) => result = resultQueue;

  void incrementAllEndTime(int time) {
    for (var job in queue) {
      job.incrementEndTime(time);
    }
  }

  void rr(int quantum, Logger logger) {
    var currentJob = front();
    var log = Log(
        id: currentJob.getId(),
        level: currentJob.getLevel(),
        startTime: logger.getTime());

    if (currentJob.getRemainingTime() <= quantum) {
      logger.incrementTime(currentJob.getRemainingTime());
      currentJob.setEndTime = logger.getTime();
      currentJob.setRemainingTime = 0;
      logger.incrementCount();
      moveToResult();
    } else {
      logger.incrementTime(quantum);
      currentJob.setEndTime = logger.getTime();
      currentJob.setRemainingTime = currentJob.getRemainingTime() - quantum;
      offer();
    }

    log.setEndTime = logger.getTime();
    logger.addLog(log);
  }

  void fcfs(Logger logger) {
    var currentJob = front();
    var log = Log(
        id: currentJob.getId(),
        level: currentJob.getLevel(),
        startTime: logger.getTime());
    logger.incrementTime(currentJob.getRemainingTime());

    logger.incrementCount();
    currentJob.setEndTime = logger.getTime();
    currentJob.setRemainingTime = 0;
    moveToResult();

    log.setEndTime = logger.getTime();
    logger.addLog(log);
  }

  void sjf(Logger logger) {
    sort('SJF');
    var currentJob = front();
    var log = Log(
        id: currentJob.getId(),
        level: currentJob.getLevel(),
        startTime: logger.getTime());
    logger.incrementTime(currentJob.getRemainingTime());

    logger.incrementCount();
    currentJob.setEndTime = logger.getTime();
    currentJob.setRemainingTime = 0;
    moveToResult();

    log.setEndTime = logger.getTime();
    logger.addLog(log);
  }

  void calculateResults() {
    for (var job in queue) {
      job.calculateTurnAroundTime();
      job.calculateWaitingTime();
    }
  }

  void sort(String mode) {
    switch (mode) {
      case 'AT':
        queue.sort((a, b) => a.getArrivalTime().compareTo(b.getArrivalTime()));
        break;
      case 'SJF':
        queue.sort(
            (a, b) => a.getRemainingTime().compareTo(b.getRemainingTime()));
        break;
      default:
        break;
    }
  }
}
