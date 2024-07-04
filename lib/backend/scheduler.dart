import 'package:multi_level_feedback_queue_solver_gui/backend/queue.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/logger.dart';

class Scheduler {
  late Queue timeline;
  late Queue inputQueue;
  late Queue resultQueue;
  late Queue queueA;
  late Queue queueB;
  late Queue queueC;
  late List<int> quantums;
  late int finalMode;
  late Logger logger;

  Scheduler(Queue timeline, int quantumA, int quantumB, this.finalMode) {
    initializeTimeline(timeline);
    initializeQueues();
    quantums = [quantumA, quantumB];
    logger = Logger();
  }

  void run() {
    while (true) {
      while (!inputQueue.isEmpty() &&
          inputQueue.front().getArrivalTime() <= logger.getTime()) {
        inputQueue.front().setEndTime = logger.getTime();
        queueA.enqueue(inputQueue.dequeue());
      }

      if (!queueA.isEmpty()) {
        queueA.rr(quantums[0], logger);
      } else if (!queueB.isEmpty()) {
        queueB.rr(quantums[1], logger);
      } else if (!queueC.isEmpty()) {
        switch (finalMode) {
          case 0:
            queueC.fcfs(logger);
            break;
          case 1:
            queueC.sjf(logger);
            break;
          default:
            break;
        }
      } else {
        logger.incrementTime(1);
      }

      if (logger.getCount() == timeline.size()) break;
    }

    resultQueue.calculateResults();
  }

  void initializeTimeline(Queue timeline) {
    this.timeline = Queue.fromQueue(timeline, "TIMELINE");
    this.timeline.sort("AT");
  }

  void initializeQueues() {
    inputQueue = Queue.fromQueue(timeline, "input");
    resultQueue = Queue("result");
    queueA = Queue("queueA");
    queueB = Queue("queueB");
    queueC = Queue("queueC");

    inputQueue.setNextQueue = queueA;
    queueA.setNextQueue = queueB;
    queueB.setNextQueue = queueC;
    queueC.setNextQueue = resultQueue;

    queueA.setResultQueue = resultQueue;
    queueB.setResultQueue = resultQueue;
    queueC.setResultQueue = resultQueue;
  }
}
