import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/job.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/logger.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/queue.dart';
import 'package:multi_level_feedback_queue_solver_gui/backend/scheduler.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _atController = TextEditingController();
  final TextEditingController _btController = TextEditingController();
  final TextEditingController _quantum1Controller = TextEditingController();
  final TextEditingController _quantum2Controller = TextEditingController();
  int finalMode = 0;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _resultRows = <DataRow>[];
  final _ganttRows = <DataRow>[];

  void populateResults(Queue results) {
    clearResults();
    setState(() {
      _resultRows.clear();
      for (var job in results.queue) {
        _resultRows.add(DataRow(cells: [
          DataCell(Text(job.id)),
          DataCell(Text('${job.arrivalTime}')),
          DataCell(Text('${job.burstTime}')),
          DataCell(Text('${job.remainingTime}')),
          DataCell(Text('${job.level}')),
          DataCell(Text('${job.endTime}')),
          DataCell(Text('${job.turnAroundTime}')),
          DataCell(Text('${job.waitingTime}')),
        ]));
      }
    });
  }

  void populateGantt(Logger logger) {
    clearGantt();
    setState(() {
      for (var log in logger.logs) {
        _ganttRows.add(DataRow(
          cells: [
            DataCell(Text(log.id)),
            DataCell(Text('${log.level}')),
            DataCell(Text('${log.startTime}')),
            DataCell(Text('${log.endTime}')),
          ],
        ));
      }
    });
  }

  void clearResults() {
    setState(() {
      _resultRows.clear();
    });
  }

  void clearGantt() {
    setState(() {
      _ganttRows.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Queue timeline = Queue('timeline');

            var arrivalTimes = _atController.text.split(' ');
            var burstTimes = _btController.text.split(' ');
            if (arrivalTimes.length == burstTimes.length) {
              for (int i = 0; i < arrivalTimes.length; i++) {
                timeline.enqueue(Job(
                    id: String.fromCharCode(65 + i),
                    arrivalTime: int.parse(arrivalTimes[i]),
                    burstTime: int.parse(burstTimes[i])));
              }

              Scheduler scheduler = Scheduler(
                  timeline,
                  int.parse(_quantum1Controller.text),
                  int.parse(_quantum2Controller.text),
                  finalMode);
              scheduler.run();
              populateResults(scheduler.resultQueue);
              populateGantt(scheduler.logger);
            }
          }
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Run'),
      ),
      body: Row(
        children: [
          Container(
            width: max(MediaQuery.sizeOf(context).width / 4, 300),
            decoration: BoxDecoration(
              color: Theme.of(context).hoverColor,
            ),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Text('Settings',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _atController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        } else if (_atController.text.split(' ').length !=
                            _btController.text.split(' ').length) {
                          return 'Error in job inputs';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                          labelText: 'Arrival Times',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _btController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        } else if (_atController.text.split(' ').length !=
                            _btController.text.split(' ').length) {
                          return 'Error in job inputs';
                        } else {
                          return null;
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                          labelText: 'Burst Times',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantum1Controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: 'Quantum Time for Level 1',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantum2Controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                          labelText: 'Quantum Time for Level 2',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: finalMode,
                      items: const [
                        DropdownMenuItem(
                            value: 0, child: Text('First Come First Serve')),
                        DropdownMenuItem(
                            value: 1, child: Text('Shortest Job First')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          finalMode = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Algorithm for Level 3',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _atController.text = '0 5 7 10 8 15 18';
                        _btController.text = '3 6 5 7 12 3 7';
                        _quantum1Controller.text = '2';
                        _quantum2Controller.text = '2';
                      },
                      child: const Text('Debug: Populate Jobs'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        showAboutDialog(
                          context: context,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Members',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text('Betonio, Queenie Rose'),
                                  Text('Cabug, Vhon'),
                                  Text('Mediran, Marcox'),
                                  Text('Pelayo, Ashlee Nicole'),
                                  SizedBox(height: 32),
                                  Text('Project Description',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                    'An MLFQ Job Scheduling Algorithm solver made\nby BSCS 2-1\'s Group 2 in fullfilment of their\nfinal project in the subject, Design and Analysis\nof Algorithms.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('About this Project'),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    title: Text('Multi Level Feedback Queue Solver'),
                  ),
                  (_resultRows.isNotEmpty && _ganttRows.isNotEmpty)
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(64),
                            child: Column(
                              children: [
                                const Text('Results',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('ID')),
                                      DataColumn(label: Text('Arrival Time')),
                                      DataColumn(label: Text('Burst Time')),
                                      DataColumn(label: Text('Remaining Time')),
                                      DataColumn(label: Text('Level')),
                                      DataColumn(label: Text('End Time')),
                                      DataColumn(
                                          label: Text('Turn Around Time')),
                                      DataColumn(label: Text('Waiting Time')),
                                    ],
                                    rows: _resultRows,
                                  ),
                                ),
                                const SizedBox(height: 64),
                                const Text('Gantt Chart',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('ID')),
                                      DataColumn(label: Text('Level')),
                                      DataColumn(label: Text('Start')),
                                      DataColumn(label: Text('End')),
                                    ],
                                    rows: _ganttRows,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 48),
                                Text(
                                  'Populate jobs through the settings menu\nand run the algorithm.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
