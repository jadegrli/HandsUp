import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hands_up/widgets/home_page.dart';
import 'package:intl/intl.dart';

import '../bloc_database/db_bloc_repetition.dart';
import '../bloc_database/db_bloc_score.dart';
import '../bloc_measure/bloc_measure.dart';
import '../models/measure.dart';
import '../models/score.dart';
import '../score_calculation/angle_score_live.dart';
import '../score_calculation/p_score_live.dart';


class MeasurePage extends StatefulWidget {
  const MeasurePage(
      {Key? key,
        required this.nbRepetition,
        required this.duration,
        required this.patientID})
      : super(key: key);

  final int nbRepetition;
  final int duration;
  final int patientID;

  @override
  State<MeasurePage> createState() => _Measure();
}

String detectState(MeasureStates state) {
  if (state is StateReady) {
    return "StateReady";
  }
  if (state is StateLoading) {
    return "Loading";
  }
  if (state is StateRest) {
    return "Rest";
  }
  if (state is StateHandBack) {
    return "Hand Back";
  }
  if (state is StateHandUp) {
    return "Hand Up";
  }
  if (state is StateAllMeasuresFirstSide) {
    return "All measure";
  }
  if (state is StateError) {
    return "Error";
  }
  return "No State";
}

class _Measure extends State<MeasurePage> {

  final allRangesAcc = <List<double>>[];
  final allRangesGyro = <List<double>>[];
  double bbScore = 20;
  double elevationInjured = 0;
  double elevationHealthy = 0;

  final DataBaseBlocScore blocScore = DataBaseBlocScore();
  final DataBaseBlocRepetition blocRepetition = DataBaseBlocRepetition();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading:
          false, // pour bouton de retour mettre false pour l'enlever
          title: const Text("Measure")),
      body: Center(
        //TODO : remove after debug
        child: BlocListener<MeasureBloc, MeasureStates>(
          listener: (context, state) => print(detectState(state)),
          child: BlocBuilder<MeasureBloc, MeasureStates>(
            builder: (context, state) {
              if (state is StateReady) {
                return Center(
                  child: ElevatedButton(
                      onPressed: () {
                        context.read<MeasureBloc>().add(EventLaunchFirstSide(nbRepetition: widget.nbRepetition, movementDuration: widget.duration));
                      },
                      child: const Text("Launch")),
                );
              }

              if (state is StateLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StateRest) {
                return const Center(
                  child: Text("Rest"),
                );
              }

              if (state is StateHandBack) {
                return const Center(
                  child: Text("Hand back"),
                );
              }

              if (state is StateHandUp) {
                return const Center(
                  child: Text("Hand up"),
                );
              }

              if (state is StateAllMeasuresFirstSide) {
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const Text("All measures"),
                        ElevatedButton(
                            onPressed: () {
                              context.read<MeasureBloc>().add(EventEnd());
                            },
                            child: const Text("Cancel")),
                        ElevatedButton(
                            onPressed: () {
                              context
                                  .read<MeasureBloc>()
                                  .add(EventLaunchSecondSide(
                                  nbRepetition: widget.nbRepetition,
                                  movementDuration: widget.duration));
                            },
                            child: const Text("Continue measure")),
                        midResult(state.allMeasures),
                      ],
                    ),
                  ),
                );
              }

              if (state is StateAllMeasuresSecondSide) {
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const Text("All measures"),
                        finalResults(state.allMeasures),
                        ElevatedButton(
                            onPressed: () async {
                              context
                                  .read<MeasureBloc>()
                                  .add(EventEnd());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            },
                            child: const Text("Validate")),
                        ElevatedButton(
                            onPressed: () async {
                              final newScore = Score(
                                  creationDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                  elevationAngleInjured: elevationInjured,
                                  elevationAngleHealthy: elevationHealthy,
                                  bbScore: bbScore,
                                  patientId: widget.patientID,
                                  notes: "");
                              //TODO tester avec et sans le await
                              await blocScore.addScoreWithRepetition(
                                  newScore,
                                  List.from(allRangesAcc),
                                  List.from(allRangesGyro),
                                  elevationInjured,
                                  elevationHealthy);

                              context
                                  .read<MeasureBloc>()
                                  .add(EventEnd());

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            },
                            child: const Text("Cancel")),
                      ],
                    ),
                  ),
                );
              }

              if (state is StateError) {
                return const Center(
                  child: Text("Error"),
                );
              }

              return const Center(
                child: Text("NO STATE !"),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget midResult(List<Measure> measure) {
    final allResultsAcc = <List<double>>[];
    final allResultsGyro = <List<double>>[];
    final score = PScoreLive(allMeasures: measure);
    final String length = measure.length.toString();

    if (widget.nbRepetition * 2 == measure.length) {
      for (int i = 0; i < widget.nbRepetition * 2; i++) {
        allResultsAcc.add(score.getRanges(measure[i].accelValues));
        allResultsGyro.add(score.getRanges(measure[i].gyroValues));
      }
      return Column(
        children: [
          for (int i = 0; i < widget.nbRepetition * 2 - 1; i += 2)
            Column(
              children: [
                Text(allResultsAcc.toString()),
                Text(allResultsGyro.toString()),
                Text(
                  "Ranges for Repetition $i",
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w900),
                ),
                Text(
                    "Hand Back, Accelerometer, X Axis : ${allResultsAcc[i][0]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text(
                    "Hand Back, Accelerometer, Y Axis : ${allResultsAcc[i][1]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text(
                    "Hand Back, Accelerometer, Z Axis : ${allResultsAcc[i][2]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text("Hand Up, Gyroscope, X Axis : ${allResultsGyro[i + 1][0]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text("Hand Up, Gyroscope, Y Axis : ${allResultsGyro[i + 1][1]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text("Hand Up, Gyroscope, Z Axis : ${allResultsGyro[i + 1][2]}",
                    style: const TextStyle(fontSize: 20.0)),
              ],
            ),
        ],
      );
    }
    return Text(
        "Error while calculating middle score, length : $length, nbRepetition : ${widget.nbRepetition}");
  }

  bool _calculateScores(List<Measure> measures) {
    if (widget.nbRepetition * 4 == measures.length) {
      final mpScoreLive = PScoreLive(allMeasures: measures);
      for (int i = 0; i < widget.nbRepetition * 4; i++) {
        allRangesAcc.add(mpScoreLive.getRanges(measures[i].accelValues));
        allRangesGyro.add(mpScoreLive.getRanges(measures[i].gyroValues));
      }
      mpScoreLive.computeScore();
      bbScore = mpScoreLive.bbScore;
      final mAngleScoreLive = AngleScoreLive(allMeasures: measures);
      mAngleScoreLive.computeScore();
      elevationInjured = mAngleScoreLive.elevationInjured;
      elevationHealthy = mAngleScoreLive.elevationHealthy;
      return true;
    }
    return false;
  }


  Widget finalResults(List<Measure> measures) {
    if (_calculateScores(measures)) {
      //_calculateScores(measures);
      return Column(
        children: [
          Text("BBScore : $bbScore", style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Healthy : $elevationHealthy",
              style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Injured : $elevationInjured",
              style: const TextStyle(fontSize: 20.0)),
        ],
      );
    } else {
      return Column(
        children: const [
          Text("Error in score calculation!", style: TextStyle(fontSize: 20.0)),
        ],
      );
    }
  }
}
