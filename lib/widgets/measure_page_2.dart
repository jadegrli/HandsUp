import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hands_up/bloc_measure/bloc_measure_2.dart';
import 'package:hands_up/widgets/home_page.dart';
import 'package:hands_up/widgets/overall_patient_page.dart';
import 'package:intl/intl.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/measure.dart';
import '../models/score.dart';
import '../score_calculation/angle_score_live.dart';
import '../score_calculation/p_score_live.dart';

class MeasurePage2 extends StatefulWidget {
  const MeasurePage2(
      {Key? key,
      required this.nbRepetition,
      required this.duration,
      required this.patientID})
      : super(key: key);

  final int nbRepetition;
  final int duration;
  final int patientID;

  @override
  State<MeasurePage2> createState() => _Measure2();
}

class _Measure2 extends State<MeasurePage2> {
  final allRangesAcc = <List<double>>[];
  final allRangesGyro = <List<double>>[];
  double bbScore = 0;
  double elevationInjured = 0;
  double elevationHealthy = 0;
  bool exceptionCalculation = false;

  final DataBaseBlocScore blocScore = DataBaseBlocScore();
  final MeasureBloc2 measureBloc = MeasureBloc2();

  late Timer _timer;
  late int _start;

  bool timerLaunched = false;
  String lastState = "Ready";


  void stopTimer() {
    _timer.cancel();
    timerLaunched = false;
  }

  final player = AudioPlayer();

  playSoundTransition() async
  {
    await player.play(AssetSource('sounds/bip_sound.mp3'));
  }

  final player2 = AudioPlayer();

  playSoundMeasurePages() async
  {
    await player2.play(AssetSource('sounds/validation_sound.mp3'));
  }


  void startTimer() {
    timerLaunched = true;
    _start = widget.duration;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            _timer.cancel();
            timerLaunched = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _start = widget.duration;

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
    _timer.cancel();
    player.dispose();
    player2.dispose();
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
    //measureBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<MeasureStates>(
          stream: measureBloc.measurePhase,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              if (snapshot.data is StateReady) {
                lastState = "Ready";
                return Center(
                  child: ElevatedButton(
                      onPressed: () {
                        measureBloc.launchSide(
                            widget.nbRepetition, widget.duration, true);
                      },
                      child: const Text("Launch")),
                );
              }

              if (snapshot.data is StateLoading) {
                lastState = "Loading";
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data is StateRest) {
                if (lastState != "Rest") {
                  playSoundTransition();
                  if (timerLaunched) stopTimer();
                  startTimer();
                }
                lastState = "Rest";
                return movement(context, "Rest");
              }

              if (snapshot.data is StateHandBack) {
                if (lastState != "Hand back") {
                  playSoundTransition();
                  if (timerLaunched) stopTimer();
                  startTimer();
                }
                lastState = "Hand back";
                return movement(context, "Hand back");
              }

              if (snapshot.data is StateHandUp) {
                if (lastState != "Hand up") {
                  playSoundTransition();
                  if (timerLaunched) stopTimer();
                  startTimer();
                }
                lastState = "Hand up";
                return movement(context, "Hand up");
              }

              if (snapshot.data is StateAllMeasuresLoadingOfCancel) {
                lastState = "Cancelling";
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                      CircularProgressIndicator(),
                      Text("Canceling measure"),
                    ],
                    ),
                );
              }

              if (snapshot.data is StateAllMeasuresCanceled) {
                lastState = "Canceled";
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("The measure is canceled"),
                      ElevatedButton(
                          onPressed: () {
                            measureBloc.endMeasure();
                            if (widget.patientID == 0) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OverallPatientPage(
                                          patientId: widget.patientID)));
                            }
                          },
                          child: const Text("Go back!"))
                    ],
                  ),
                );
              }

              if (snapshot.data is StateAllMeasuresFirstSide) {
                lastState = "Mid result";
                playSoundMeasurePages();
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const Text("All measures"),
                        ElevatedButton(
                            onPressed: () {
                              measureBloc.endMeasure();
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
                                        builder: (context) =>
                                            OverallPatientPage(
                                                patientId: widget.patientID)));
                              }
                            },
                            child: const Text("Cancel")),
                        ElevatedButton(
                            onPressed: () {
                              measureBloc.launchSide(
                                  widget.nbRepetition, widget.duration, false);
                            },
                            child: const Text("Continue measure")),
                        midResult(snapshot.data!.allMeasures),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.data is StateAllMeasuresSecondSide) {
                lastState = "Final result";
                playSoundMeasurePages();
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        const Text("All measures"),
                        finalResults(snapshot.data!.allMeasures),
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

                                measureBloc.endMeasure();

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
                                          builder: (context) =>
                                              OverallPatientPage(
                                                  patientId:
                                                      widget.patientID)));
                                }
                              },
                              child: const Text("Validate")),
                        ElevatedButton(
                            onPressed: () async {
                              measureBloc.endMeasure();
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
                                        builder: (context) =>
                                            OverallPatientPage(
                                                patientId: widget.patientID)));
                              }
                            },
                            child: const Text("Cancel")),
                      ],
                    ),
                  ),
                );
              }
            }
            return const Center(
              child: Text("NO STATE !"),
            );
          }),
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
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
                        Text(
                            "Hand Back, Gyroscope, X Axis : ${allResultsGyro[i][0]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Back, Gyroscope, Y Axis : ${allResultsGyro[i][1]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Back, Gyroscope, Z Axis : ${allResultsGyro[i][2]}",
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
                        Text(
                            "Hand Up, Gyroscope, X Axis : ${allResultsGyro[i + 1][0]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Up, Gyroscope, Y Axis : ${allResultsGyro[i + 1][1]}",
                            style: const TextStyle(fontSize: 20.0)),
                        Text(
                            "Hand Up, Gyroscope, Z Axis : ${allResultsGyro[i + 1][2]}",
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$_start",
                    style: const TextStyle(
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
                //measureBloc.cancelMeasure();
                measureBloc.endMeasure();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const HomePage()));
              },
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
