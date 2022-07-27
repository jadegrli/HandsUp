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
  bool isExcluded = false;

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
                          const SizedBox(height: 30,),
                          Text("B-B Score : ${snapshot.data!.first.bbScore}"),
                          Text("Elevation Angle Injured : ${snapshot.data!.first.elevationAngleInjured}"),
                          Text("Elevation Angle Healthy : ${snapshot.data!.first.elevationAngleHealthy}"),
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
