import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
    _timer.cancel();
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
                //playSoundMeasurePages();
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
                        midResult(snapshot.data!.allResultsAcc, snapshot.data!.allResultsGyro, snapshot.data!.error),
                      ],
                    ),
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
                        const Text("All measures"),
                        finalResults(snapshot.data!.error, snapshot.data!.values),
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


  Widget midResult(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, int error) {
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
                       "Hand Up, Accelerometer, X Axis : ${allResultsAcc[i +
                           1][0]}",
                       style: const TextStyle(fontSize: 20.0)),
                   Text(
                       "Hand Up, Accelerometer, Y Axis : ${allResultsAcc[i +
                           1][1]}",
                       style: const TextStyle(fontSize: 20.0)),
                   Text(
                       "Hand Up, Accelerometer, Z Axis : ${allResultsAcc[i +
                           1][2]}",
                       style: const TextStyle(fontSize: 20.0)),
                   Text("Hand Up, Gyroscope, X Axis : ${allResultsGyro[i +
                       1][0]}",
                       style: const TextStyle(fontSize: 20.0)),
                   Text("Hand Up, Gyroscope, Y Axis : ${allResultsGyro[i +
                       1][1]}",
                       style: const TextStyle(fontSize: 20.0)),
                   Text("Hand Up, Gyroscope, Z Axis : ${allResultsGyro[i +
                       1][2]}",
                       style: const TextStyle(fontSize: 20.0)),
                 ],
               ),
           ],
         );
       }


  }

  Widget finalResults(int error, List<double> values) { // lui passer un score
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
          Text("Error while calculating final score, length error in data lists", style: TextStyle(fontSize: 20.0)),
        ],
      );
    } else {
      return Column(
        children: [
          Text("BBScore : ${values[0]}", style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Healthy : ${values[1]}",
              style: const TextStyle(fontSize: 20.0)),
          Text("Elevation Angle Injured : ${values[2]}",
              style: const TextStyle(fontSize: 20.0)),
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
              child: const Text("CANCEL")),
        ],
      ),
    );
  }
}
