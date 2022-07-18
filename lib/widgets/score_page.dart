import 'package:flutter/material.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/score.dart';
import 'all_repetitions_of_score_page.dart';

class ScorePage extends StatefulWidget {
  final Score score;
  const ScorePage({Key? key, required this.score}) : super(key: key);

  @override
  State<ScorePage> createState() => _ScorePage();
}

class _ScorePage extends State<ScorePage> {

  final DataBaseBlocScore bloc = DataBaseBlocScore();

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
            Text("ID : ${widget.score.id}"),
            Text(
                "ElevationAngleInjured : ${widget.score.elevationAngleInjured}"),
            Text(
                "ElevationAngleHealthy : ${widget.score.elevationAngleHealthy}"),
            Text("BBScore : ${widget.score.bbScore}"),
            Text("creationDate : ${widget.score.creationDate}"),
            Text("Patient_id : ${widget.score.patientId}"),
            Text("Notes : ${widget.score.notes}"),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AllRepetitionsOfScorePage(scoreId: widget.score.id!)),
                  );
                },
                child: const Text("See repetitions")),
            ElevatedButton(
                onPressed: () {
                  bloc.deleteScoreById(widget.score.id!);
                  Navigator.of(context).pop(true);
                },
                child: const Text("Delete score")),
          ],
        ),
      ),
    );
  }
}
