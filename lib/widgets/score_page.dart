import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hands_up/widgets/all_scores_without_patient.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/score.dart';
import 'all_scores_of_patient_page.dart';

class ScorePage extends StatefulWidget {
  final int id;
  final int patientId;
  const ScorePage({Key? key, required this.id, required this.patientId}) : super(key: key);

  @override
  State<ScorePage> createState() => _ScorePage();
}

class _ScorePage extends State<ScorePage> {

  final DataBaseBlocScore bloc = DataBaseBlocScore();
  final notesTextController = TextEditingController();
  late Score score;
  bool initOnce = true;

  @override
  void initState() {
    super.initState();
    bloc.getScoreFromId(widget.id);
  }

  @override
  void dispose() {
    super.dispose();
    notesTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Score profile"),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          StreamBuilder<List<Score>>(
              stream: bloc.data,
              builder: (context, snapshot) {
              bloc.getScoreFromId(widget.id);
              if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                if (initOnce) {
                  initOnce = false;
              notesTextController.text = snapshot.data!.first.notes;

                }
                score = snapshot.data!.first;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Color(0xff9abdda),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0.0, 0.75))
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 20,),
                                  Text(snapshot.data!.first.creationDate,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              IconButton(
                                      onPressed: () {
                                        showDialog(
                                          //if set to true allow to close popup by tapping out of the popup
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: const Center(
                                                  child: Text(
                                                      "Confirm suppression"),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10)),
                                                actions: [
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        TextButton(
                                                            child: const Text(
                                                              "DELETE SCORE",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            onPressed: () {
                                                              bloc.deleteScoreById(widget.id);
                                                              if (widget.patientId != 0) {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                            AllScoresOfPatientPage(patientID: widget.patientId,)));
                                                              } else {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                            const AllScoresWithoutPatientPage()));
                                                              }

                                                            }),
                                                        TextButton(
                                                            child: const Text(
                                                              "CANCEL",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                  context)
                                                                  .pop(true);
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                elevation: 24,
                                              ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete, size: 40,)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                      height: 25),
                                  Text(
                                    "${snapshot.data!.first.bbScore ~/ 1}%",
                                    style: const TextStyle(
                                        color: Colors
                                            .deepPurple,
                                        fontSize: 30,
                                        fontWeight:
                                        FontWeight
                                            .bold),
                                  ),
                                  const SizedBox(
                                      height: 40),
                                  const Text("B-B Score", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    padding:
                                    const EdgeInsets
                                        .all(20.0),
                                    margin: const EdgeInsets
                                        .all(10),
                                    decoration:
                                    const BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius
                                              .circular(
                                              20)),
                                      color:
                                      Color(0xff9abdda),
                                    ),
                                    child: Stack(
                                      alignment:
                                      Alignment.center,
                                      children: [
                                        Text(
                                          "${snapshot.data!.first.elevationAngleInjured ~/ 1}°",
                                          style: const TextStyle(
                                              color: Colors
                                                  .deepPurple,
                                              fontSize: 23,
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        PieChart(
                                          PieChartData(
                                            borderData:
                                            FlBorderData(
                                              show: false,
                                            ),
                                            sectionsSpace:
                                            0,
                                            centerSpaceRadius:
                                            30,
                                            sections: [
                                              PieChartSectionData(
                                                color: Colors
                                                    .deepPurple,
                                                value: (snapshot.data!.first.elevationAngleInjured *
                                                    100 ~/
                                                    180)
                                                    .toDouble(),
                                                title:
                                                "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                                radius: 10,
                                                titleStyle: const TextStyle(
                                                    fontSize:
                                                    20,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xffffffff)),
                                              ),
                                              PieChartSectionData(
                                                color: const Color(
                                                    0xff7699b7),
                                                value: (100 -
                                                    snapshot.data!.first.elevationAngleInjured *
                                                        100 ~/
                                                        180)
                                                    .toDouble(),
                                                title: "",
                                                /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
                                                radius: 10,
                                                titleStyle: const TextStyle(
                                                    fontSize:
                                                    20,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xffffffff)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                      "Elevation Angle", style: TextStyle(fontSize: 13)),
                                  const Text(
                                      "Injured shoulder", style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    padding:
                                    const EdgeInsets
                                        .all(20.0),
                                    margin: const EdgeInsets
                                        .all(10),
                                    decoration:
                                    const BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius
                                              .circular(
                                              20)),
                                      color:
                                      Color(0xff9abdda),
                                    ),
                                    child: Stack(
                                      alignment:
                                      Alignment.center,
                                      children: [
                                        Text(
                                          "${snapshot.data!.first.elevationAngleHealthy ~/ 1}°",
                                          style: const TextStyle(
                                              color: Colors
                                                  .deepPurple,
                                              fontSize: 23,
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        PieChart(
                                          PieChartData(
                                            borderData:
                                            FlBorderData(
                                              show: false,
                                            ),
                                            sectionsSpace:
                                            0,
                                            centerSpaceRadius:
                                            30,
                                            sections: [
                                              PieChartSectionData(
                                                color: Colors
                                                    .deepPurple,
                                                value: (snapshot.data!.first.elevationAngleHealthy *
                                                    100 ~/
                                                    180)
                                                    .toDouble(),
                                                title:
                                                "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                                radius: 10,
                                                titleStyle: const TextStyle(
                                                    fontSize:
                                                    20,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xffffffff)),
                                              ),
                                              PieChartSectionData(
                                                color: const Color(
                                                    0xff7699b7),
                                                value: (100 -
                                                    snapshot.data!.first.elevationAngleHealthy *
                                                        100 ~/
                                                        180)
                                                    .toDouble(),
                                                title: "",
                                                /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
                                                radius: 10,
                                                titleStyle: const TextStyle(
                                                    fontSize:
                                                    20,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Color(
                                                        0xffffffff)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                      "Elevation Angle", style: TextStyle(fontSize: 13)),
                                  const Text(
                                      "Healthy shoulder", style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 30,),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(), labelText: "Notes"),
                              maxLines: 6,
                              maxLength: 400,
                              controller: notesTextController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

              }
            return const Text("No Data");
    }

    ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () {
            final newScore = Score(id: widget.id, creationDate: score.creationDate, elevationAngleInjured: score.elevationAngleInjured, elevationAngleHealthy: score.elevationAngleHealthy, bbScore: score.bbScore, notes: notesTextController.text);
            bloc.updateScore(newScore);
            showDialog(
              //if set to true allow to close popup by tapping out of the popup
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                    title: const Center(
                      child: Text(
                          "Note updated!"),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            10)),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(
                              context)
                              .pop(true);
                            },
                          child: const Text(
                            "OK",
                            style: TextStyle(
                                color: Colors
                                    .green),
                          ),
                        ),
                      ),
                    ],
                    elevation: 24,
                  ),
            );
      }),
    );
  }
}
