import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hands_up/bloc_measure/bloc_measure_2.dart';
import 'package:hands_up/widgets/home_page.dart';
import 'package:hands_up/widgets/overall_patient_page.dart';

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
  bool exceptionCalculation = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff5eaf4),
        title: const Text("Measure", style: TextStyle(color: Colors.black)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<MeasureStates>(
            stream: measureBloc.measurePhase,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                if (snapshot.data is StateReady) {
                  lastState = "Ready";
                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3.5,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Text("Start a new measure",
                            style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.black)),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 40, left: 20, right: 20),
                        child: Text(
                            "Please attach the phone on your arm and the begin the measure",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.black)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text("Cancel")),
                          const SizedBox(
                            width: 40,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green),
                              ),
                              onPressed: () {
                                measureBloc.launchSide(
                                    widget.nbRepetition, widget.duration, true);
                              },
                              child: const Text("Launch")),
                        ],
                      ),
                    ],
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
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3.5,
                        ),
                        const CircularProgressIndicator(),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 30),
                          child: Text("Canceling measure...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black)),
                        ),
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3.5,
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text("The measure is canceled",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black)),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurple),
                            ),
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
                            child: const Text("Go back!"))
                      ],
                    ),
                  );
                }

                if (snapshot.data is StateAllMeasuresFirstSide) {
                  lastState = "Mid result";
                  playSoundMeasurePages();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          margin: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color(0xfff5eaf4),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 15.0,
                                  offset: Offset(0.0, 0.75))
                            ],
                          ),
                          child: Column(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  "Values for the first shoulder",
                                  style: TextStyle(fontSize: 23),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "Please verify the values. \nBefore you continue the measure, please attach the phone on the other arm",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        midResult(
                            snapshot.data!.allResultsAcc,
                            snapshot.data!.allResultsGyro,
                            snapshot.data!.error),
                        Padding(
                          padding: const EdgeInsets.only(top: 50, bottom: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
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
                                                      patientId:
                                                          widget.patientID)));
                                    }
                                  },
                                  child: const Text("Cancel")),
                              const SizedBox(
                                width: 30,
                              ),
                              if (!exceptionCalculation)
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.green),
                                  ),
                                  onPressed: () {
                                    measureBloc.launchSide(widget.nbRepetition,
                                        widget.duration, false);
                                  },
                                  child: const Text("Continue")),
                            ],
                          ),
                        ),
                      ],
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
                          finalResults(
                              snapshot.data!.error, snapshot.data!.values),
                          const SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.red),
                                  ),
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
                                                      patientId:
                                                          widget.patientID)));
                                    }
                                  },
                                  child: const Text("Cancel")),
                              if (!exceptionCalculation)
                                ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                    ),
                                    onPressed: () {
                                      measureBloc
                                          .saveToDataBase(widget.patientID);
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
                            ],
                          ),
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
      ),
    );
  }

  Widget midResult(List<List<double>> allResultsAcc,
      List<List<double>> allResultsGyro, int error) {
    if (error == 2) {
      exceptionCalculation = true;
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          "Error while calculating middle score, length error in data lists",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else if (error == 1) {
      exceptionCalculation = true;
      return Column(
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          for (int i = 0; i < widget.nbRepetition * 2 - 1; i += 2)
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xfff5eaf4),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15.0,
                      offset: Offset(0.0, 0.75))
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Ranges for Repetition ${i ~/ 2 + 1}",
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w900),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text("Hand Back : ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w900)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Table(
                      border: TableBorder.all(
                          width: 2.0,
                          color: Colors.deepPurple,
                          style: BorderStyle.solid),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xff8cc0cc),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Accelerometer",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("", style: TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "X Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsAcc[i][0].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Y Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsAcc[i][1].toDouble()).toStringAsFixed(3))}" /*yA.toStringAsFixed(2)*/,
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Z Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsAcc[i][2].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xff8cc0cc),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gyroscope",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("", style: TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "X Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsGyro[i][0].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Y Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsGyro[i][1].toDouble()).toStringAsFixed(3))}" /*yA.toStringAsFixed(2)*/,
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Z Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  " ${double.parse((allResultsGyro[i][2].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text("Hand Up : ",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.w900)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Table(
                      border: TableBorder.all(
                          width: 2.0,
                          color: Colors.deepPurple,
                          style: BorderStyle.solid),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xff8cc0cc),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Accelerometer",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("", style: TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "X Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsAcc[i + 1][0].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Y Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  " ${double.parse((allResultsAcc[i + 1][1].toDouble()).toStringAsFixed(3))}" /*yA.toStringAsFixed(2)*/,
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Z Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsAcc[i + 1][2].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xff8cc0cc),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Gyroscope",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("", style: TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "X Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsGyro[i + 1][0].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Y Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${double.parse((allResultsGyro[i + 1][1].toDouble()).toStringAsFixed(3))}" /*yA.toStringAsFixed(2)*/,
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Z Axis",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  " ${double.parse((allResultsGyro[i + 1][2].toDouble()).toStringAsFixed(3))}",
                                  style: const TextStyle(fontSize: 20.0)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }
  }

  Widget finalResults(int error, List<double> values) {
    if (error == 1) {
      exceptionCalculation = true;
      return Column(
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again.",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      );
    } else if (error == 2) {
      exceptionCalculation = true;
      return Column(
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Error while calculating final score, length error in data lists",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 5,
          ),
          Container(
            padding: const EdgeInsets.all(15.0),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Result of the measure",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 25),
                            Text(
                              values[0] > 135 ? ">135%" : "${values[0] ~/ 1}%",
                              style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "B-B Score",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(20.0),
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color(0xff9abdda),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    values[2] > 180
                                        ? ">180°"
                                        : "${values[2] ~/ 1}°",
                                    style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  PieChart(
                                    PieChartData(
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 30,
                                      sections: [
                                        PieChartSectionData(
                                          color: Colors.deepPurple,
                                          value: values[2] > 180
                                              ? 180
                                              : (values[2]).toDouble(),
                                          title:
                                              "",
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                        PieChartSectionData(
                                          color: const Color(0xff7699b7),
                                          value: values[2] > 180
                                              ? 0
                                              : (180 - values[2]).toDouble(),
                                          title: "",
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "Elevation Angle",
                              style: TextStyle(fontSize: 13),
                            ),
                            const Text("Injured shoulder",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(20.0),
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color(0xff9abdda),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    values[1] > 180
                                        ? ">180°"
                                        : "${values[1] ~/ 1}°",
                                    style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  PieChart(
                                    PieChartData(
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 30,
                                      sections: [
                                        PieChartSectionData(
                                          color: Colors.deepPurple,
                                          value: values[1] > 180
                                              ? 180
                                              : (values[1]).toDouble(),
                                          title:
                                              "",
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                        PieChartSectionData(
                                          color: const Color(0xff7699b7),
                                          value: values[1] > 180
                                              ? 0
                                              : (180 - values[1]).toDouble(),
                                          title: "",
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text("Elevation Angle",
                                style: TextStyle(fontSize: 13)),
                            const Text("Healthy shoulder",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
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
      height: MediaQuery.of(context).size.height / 1.2,
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
                  height: MediaQuery.of(context).size.height / 1.7,
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
                measureBloc.cancelMeasure();
              },
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
