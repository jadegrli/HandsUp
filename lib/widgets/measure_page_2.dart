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
  //TODO gérer ça encore
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

/*
  final player = AudioPlayer();

  playSoundTransition() async
  {
    //TODO exception ici : essayer de pause/start/stop et pas recreer et detruire a chaque fois
    await player.play(AssetSource('sounds/bip_sound.mp3'));
  }

  final player2 = AudioPlayer();

  playSoundMeasurePages() async
  {
    //TODO exception ici
    await player2.play(AssetSource('sounds/validation_sound.mp3'));
  }

*/
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
    //_timer.cancel();
    //player.dispose();
    // player2.dispose();
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
    //TODO make scrollable ?
    return Scaffold(
      appBar: AppBar(
        title: const Text("Measure"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<MeasureStates>(
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
                    //playSoundTransition();
                    if (timerLaunched) stopTimer();
                    startTimer();
                  }
                  lastState = "Rest";
                  return movement(context, "Rest");
                }

                if (snapshot.data is StateHandBack) {
                  if (lastState != "Hand back") {
                    //playSoundTransition();
                    if (timerLaunched) stopTimer();
                    startTimer();
                  }
                  lastState = "Hand back";
                  return movement(context, "Hand back");
                }

                if (snapshot.data is StateHandUp) {
                  if (lastState != "Hand up") {
                    //playSoundTransition();
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
                  //playSoundMeasurePages();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
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
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(0),
                                child: Text(
                                  "Values for the first shoulder",
                                  style: TextStyle(fontSize: 25),
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
                              ElevatedButton(
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
                  //playSoundMeasurePages();
                  return SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          finalResults(
                              snapshot.data!.error, snapshot.data!.values),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!exceptionCalculation)
                                ElevatedButton(
                                    onPressed: () {
                                      measureBloc.saveToDataBase(widget.patientID);
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
      return const Text(
          "Error while calculating middle score, length error in data lists");
    } else if (error == 1) {
      return Column(
        children: const [
          Center(
            child: Text(
                "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again."),
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
                color: Color(0xff9abdda),
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
                          color: Colors.blueAccent,
                          style: BorderStyle.solid),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Colors.blue,
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
                                  style: const TextStyle(fontSize: 15.0)),
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
                            color: Colors.blue,
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
                                  style: const TextStyle(fontSize: 15.0)),
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
                          color: Colors.purple,
                          style: BorderStyle.solid),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Colors.blue,
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
                                  style: const TextStyle(fontSize: 15.0)),
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
                            color: Colors.blue,
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
                                  style: const TextStyle(fontSize: 15.0)),
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
      return Column(
        children: const [
          Center(
            child: Text(
                "Error in calculation, it can happen when the smartphone is not moving during the measure. Please try again."),
          ),
        ],
      );
    } else if (error == 2) {
      return Column(
        children: const [
          Text(
              "Error while calculating final score, length error in data lists",
              style: TextStyle(fontSize: 20.0)),
        ],
      );
    } else {
      return Container(
            padding: const EdgeInsets.all(20.0),
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
                            Text(values[0] > 135 ? ">135%" :
                              "${values[0] ~/ 1}%",
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
                                  Text(values[2] > 180 ? ">180°" :
                                    "${values[2] ~/ 1}°",
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
                                          value: values[2] > 180 ? 180 : (values[2]).toDouble(),
                                          title:
                                              "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                        PieChartSectionData(
                                          color: const Color(0xff7699b7),
                                          value: values[2] > 180 ? 0 : (180 - values[2]).toDouble(),
                                          title: "",
                                          /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
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
                        //TODO ajouter securité pour si angle + grand que 180 ou plus petit que 0 -> ramener tout a 0 ou 180
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
                                  Text(values[1] > 180 ? ">180°" :
                                    "${values[1] ~/ 1}°",
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
                                          value: values[1] > 180 ? 180 : (values[1]).toDouble(),
                                          title:
                                              "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                          radius: 10,
                                          titleStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xffffffff)),
                                        ),
                                        PieChartSectionData(
                                          color: const Color(0xff7699b7),
                                          value: values[1] > 180 ? 0 : (180 - values[1]).toDouble(),
                                          title: "",
                                          /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
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
                /*measureBloc.endMeasure();
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
                }*/
              },
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
