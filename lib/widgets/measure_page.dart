import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hands_up/widgets/home_page.dart';
import 'package:hands_up/widgets/overall_patient_page.dart';
import 'package:intl/intl.dart';

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
    return "Ready";
  }
  if (state is StateLoading) {
    return "Loading";
  }
  if (state is StateRest) {
    return "Rest";
  }
  if (state is StateHandBack) {
    return "Hand back";
  }
  if (state is StateHandUp) {
    return "Hand up";
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
  double bbScore = 0;
  double elevationInjured = 0;
  double elevationHealthy = 0;
  bool exceptionCalculation = false;
  /*late Timer _timer;
  late int _start = widget.duration;*/

  final DataBaseBlocScore blocScore = DataBaseBlocScore();

  String previousState = "Ready";

 /* void startTimer() {
    _start = widget.duration;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
*/

  @override
  void initState() {
    super.initState();
    //hide the bottom system navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
    ]);
    //prevent screen to rotate
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    //_timer.cancel();
    //unhide the bottom system navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    //allows screen rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MeasureBloc, MeasureStates>(
          listener: (context, state) => print(detectState(state)),
          child: BlocBuilder<MeasureBloc, MeasureStates>(
            builder: (context, state) {
              if (state is StateReady) {
                return Center(
                  child: ElevatedButton(
                      onPressed: () {
                        context.read<MeasureBloc>().add(EventLaunchFirstSide(
                            nbRepetition: widget.nbRepetition,
                            movementDuration: widget.duration));
                      },
                      child: const Text("Launch")),
                );
              }

              if (state is StateLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StateRest) {
                return movement(context, "Rest");
                /*return const Center(
                  child: Text("Rest"),
                );*/
              }

              if (state is StateHandBack) {
                return movement(context, "Hand back");
                /*return const Center(
                  child: Text("Hand back"),
                );*/
              }

              if (state is StateHandUp) {
                return movement(context, "Hand up");
                /*return const Center(
                  child: Text("Hand up"),
                );*/
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
                              if (widget.patientID == 0) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage()));
                              } else {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OverallPatientPage(patientId: widget.patientID)));
                              }
                            },
                            child: const Text("Cancel")),
                        ElevatedButton(
                            onPressed: () {
                              context.read<MeasureBloc>().add(
                                  EventLaunchSecondSide(
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
                        if (!exceptionCalculation)
                          ElevatedButton(
                              onPressed: () async {
                                final newScore = widget.patientID == 0
                                    ? Score(
                                        creationDate: DateFormat("yyyy-MM-dd")
                                            .format(DateTime.now()),
                                        elevationAngleInjured: elevationInjured,
                                        elevationAngleHealthy: elevationHealthy,
                                        bbScore: bbScore,
                                        notes: "")
                                    : Score(
                                        creationDate: DateFormat("yyyy-MM-dd")
                                            .format(DateTime.now()),
                                        elevationAngleInjured: elevationInjured,
                                        elevationAngleHealthy: elevationHealthy,
                                        bbScore: bbScore,
                                        patientId: widget.patientID,
                                        notes: "");

                                await blocScore.addScoreWithRepetition(
                                    newScore,
                                    List.from(allRangesAcc),
                                    List.from(allRangesGyro),
                                    elevationInjured,
                                    elevationHealthy);

                                context.read<MeasureBloc>().add(EventEnd());

                                if (widget.patientID == 0) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()));
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OverallPatientPage(patientId: widget.patientID)));
                                }
                              },
                              child: const Text("Validate")),
                        ElevatedButton(
                            onPressed: () async {
                              context.read<MeasureBloc>().add(EventEnd());

                              if (widget.patientID == 0) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage()));
                              } else {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OverallPatientPage(patientId: widget.patientID)));
                              }
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
    );
  }

  Widget midResult2(List<Measure> measure) {
    final allResultsAcc = <List<double>>[];
    final allResultsGyro = <List<double>>[];
    final score = PScoreLive(allMeasures: measure);
    final String length = measure.length.toString();

    if (widget.nbRepetition * 2 == measure.length) {
      try {
        for (int i = 0; i < widget.nbRepetition * 2; i++) {
          allResultsAcc.add(score.getRanges(measure[i].accelValues));
          allResultsGyro.add(score.getRanges(measure[i].gyroValues));
        }
      } catch (exception) {
        exceptionCalculation = true;
        return Column(
          children: const [
            Center(
              child: Text(
                  "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again."),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text("Measure validation",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 20),
          ListView(
            children: [
              for (int i = 0; i < widget.nbRepetition * 2 - 1; i += 2)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Column(
                      children: [
                        //tab here
                        Text(
                          "Ranges for Repetition ${i ~/ 2 + 1}",
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
                        Text("Hand Back, Gyroscope, X Axis : ${allResultsGyro[i][0]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text("Hand Back, Gyroscope, Y Axis : ${allResultsGyro[i][1]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text("Hand Back, Gyroscope, Z Axis : ${allResultsGyro[i][2]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Up, Accelerometer, X Axis : ${allResultsAcc[i + 1][0]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Up, Accelerometer, Y Axis : ${allResultsAcc[i + 1][1]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Up, Accelerometer, Z Axis : ${allResultsAcc[i + 1][2]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text("Hand Up, Gyroscope, X Axis : ${allResultsGyro[i + 1][0]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text("Hand Up, Gyroscope, Y Axis : ${allResultsGyro[i + 1][1]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text("Hand Up, Gyroscope, Z Axis : ${allResultsGyro[i + 1][2]}",
                            style: const TextStyle(fontSize: 20.0)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      //background color of button
                      side: const BorderSide(width: 3, color: Colors.green),
                      //border width and color
                      elevation: 3,
                      //elevation of button
                      shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(
                          20) //content padding inside button
                      ),
                  onPressed: () {},
                  child: const Text("CONTINUE")),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      //background color of button
                      side: const BorderSide(width: 3, color: Colors.red),
                      //border width and color
                      elevation: 3,
                      //elevation of button
                      shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.all(
                          20) //content padding inside button
                      ),
                  onPressed: () {},
                  child: const Text("CANCEL")),
            ],
          ),
        ],
      );
    }
    return Text(
        "Error while calculating middle score, length : $length, nbRepetition : ${widget.nbRepetition}");
  }

  Widget midResult(List<Measure> measure) {
    final allResultsAcc = <List<double>>[];
    final allResultsGyro = <List<double>>[];
    final score = PScoreLive(allMeasures: measure);
    final String length = measure.length.toString();

    if (widget.nbRepetition * 2 == measure.length) {
      try {
        for (int i = 0; i < widget.nbRepetition * 2; i++) {
          allResultsAcc.add(score.getRanges(measure[i].accelValues));
          allResultsGyro.add(score.getRanges(measure[i].gyroValues));
        }
      } catch (exception) {
        exceptionCalculation = true;
        return Column(
          children: const [
            Center(
              child: Text(
                  "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again."),
            ),
          ],
        );
      }
      return Column(
        children: [
          for (int i = 0; i < widget.nbRepetition * 2 - 1; i += 2)
            Column(
              children: [
                Text(
                  "Ranges for Repetition ${i ~/ 2 + 1}",
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
                Text("Hand Back, Gyroscope, X Axis : ${allResultsGyro[i][0]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text("Hand Back, Gyroscope, Y Axis : ${allResultsGyro[i][1]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text("Hand Back, Gyroscope, Z Axis : ${allResultsGyro[i][2]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text(
                    "Hand Up, Accelerometer, X Axis : ${allResultsAcc[i + 1][0]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text(
                    "Hand Up, Accelerometer, Y Axis : ${allResultsAcc[i + 1][1]}",
                    style: const TextStyle(fontSize: 20.0)),
                Text(
                    "Hand Up, Accelerometer, Z Axis : ${allResultsAcc[i + 1][2]}",
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

  int _calculateScores(List<Measure> measures) {
    if (widget.nbRepetition * 4 == measures.length) {
      try {
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
        return 1;
      } catch (exception) {
        exceptionCalculation = true;
        return -1;
      }
    }
    return 0;
  }

  Widget finalResults(List<Measure> measures) {
    if (_calculateScores(measures) == 1) {
      return Column(
        children: [
          Text("BBScore : $bbScore", style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Healthy : $elevationHealthy",
              style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Injured : $elevationInjured",
              style: const TextStyle(fontSize: 20.0)),
        ],
      );
    } else if (_calculateScores(measures) == 0) {
      return Column(
        children: const [
          Text("Error in score calculation!", style: TextStyle(fontSize: 20.0)),
        ],
      );
    } else {
      return Column(
        children: const [
          Center(
            child: Text(
                "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again."),
          ),
        ],
      );
    }
  }

  Widget movement(BuildContext context, String text) {
    String imagePath = 'assets/images/rest.jpg';
    Color background = Colors.white;
    switch (text) {
      case "Rest":
        imagePath = 'assets/images/rest.jpg';
        background = Colors.deepOrangeAccent;
        break;
      case "Hand back":
        imagePath = 'assets/images/hand_back.jpg';
        background = Colors.lightGreenAccent;
        break;
      case "Hand up":
        imagePath = 'assets/images/hand_up.jpg';
        background = Colors.lightBlueAccent;
        break;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: background,
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Colors.black54,
              blurRadius: 15.0,
              offset: Offset(0.0, 0.75))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 30.0, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Image.asset(
                  imagePath,
                  height: MediaQuery.of(context).size.height / 1.5,
                  fit: BoxFit.fitHeight,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(/*"$_start"*/ "Counter",
                    style: TextStyle(
                        fontSize: 120.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.red, //background color of button
                  side: const BorderSide(
                      width: 3, color: Colors.red), //border width and color
                  elevation: 3, //elevation of button
                  shape: RoundedRectangleBorder(
                      //to set border radius to button
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.all(20) //content padding inside button
                  ),
              onPressed: () {
                context.read<MeasureBloc>().add(EventEnd());
                if (widget.patientID == 0) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const HomePage()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OverallPatientPage(patientId: widget.patientID)));
                }
              },
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
