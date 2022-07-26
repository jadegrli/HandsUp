import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hands_up/bloc_database/db_bloc_score.dart';
import 'package:hands_up/widgets/modify_patient.dart';

import '../bloc_database/db_bloc_patient.dart';
import '../models/patient.dart';
import '../models/score.dart';
import 'home_page.dart';
import 'measure_page_2.dart';

class PatientPage extends StatefulWidget {
  final int patientId;

  const PatientPage({Key? key, required this.patientId, patientID})
      : super(key: key);

  @override
  State<PatientPage> createState() => _PatientPage();
}

class _PatientPage extends State<PatientPage> {
  final DataBaseBlocPatient blocPatient = DataBaseBlocPatient();
  final DataBaseBlocScore blocScore = DataBaseBlocScore();

  @override
  initState() {
    super.initState();
    blocPatient.getPatientByID(id: widget.patientId);
    blocScore.getScoreByPatientId(widget.patientId);
  }

  bool isTextFieldPatientClear = true;
  String movementDuration = "8";
  String nbRepetition = "3";
  var itemsTest = ["3", "4", "5", "6", "7", "8", "9"];
  var itemsNbRepetitions = ["2", "3", "4", "5"];

  String getMonth(String month) {
    switch (month) {
      case "01":
        return "January";
      case "02":
        return "February";
      case "03":
        return "March";
      case "04":
        return "April";
      case "05":
        return "May";
      case "06":
        return "June";
      case "07":
        return "July";
      case "08":
        return "August";
      case "09":
        return "September";
      case "10":
        return "October";
      case "11":
        return "November";
      case "12":
        return "December";
      default:
        return "Month";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<List<Patient>>(
                stream: blocPatient.data,
                builder: (context, snapshot) {
                  blocPatient.getPatientByID(id: widget.patientId);
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${snapshot.data!.first.name} ${snapshot.data!.first.firstName}",
                                      style: const TextStyle(fontSize: 20)),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ModifyPatientPage(
                                                            patientId: widget
                                                                .patientId)));
                                          },
                                          icon: const Icon(
                                            Icons.brush_rounded,
                                            size: 40,
                                          )),
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
                                                              "DELETE PATIENT",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            onPressed: () {
                                                              blocPatient
                                                                  .deletePatientById(
                                                                      widget
                                                                          .patientId);
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const HomePage()));
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
                                            Icons.delete,
                                            size: 40,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                                height: 10,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 20),
                                        children: [
                                          const TextSpan(
                                              text: "Birth date : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  "${snapshot.data!.first.dateOfBirth.substring(8, 10)} ${getMonth(snapshot.data!.first.dateOfBirth.substring(5, 7))} ${snapshot.data!.first.dateOfBirth.substring(0, 4)}"),
                                        ]),
                                  ),
                                  const SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 20),
                                        children: [
                                          const TextSpan(
                                              text:
                                                  "Reference/Healthy shoulder : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: snapshot.data!.first
                                                      .isRightReferenceOrHealthy
                                                  ? "Right"
                                                  : "Left"),
                                        ]),
                                  ),
                                  const SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                            fontSize: 20),
                                        children: [
                                          const TextSpan(
                                              text: "Pathology : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  snapshot.data!.first.healthCondition == "Other" ? snapshot.data!.first.otherPathology : snapshot.data!.first.healthCondition),
                                        ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text("NEW MEASURE",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.quiz_outlined),
                                    color: Colors.black,
                                    iconSize: 25,
                                    onPressed: () {
                                      showDialog(
                                        //if set to true allow to close popup by tapping out of the popup
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Center(
                                            child: Text("Measure information"),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: const <Widget>[
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "INFO",
                                                    style: TextStyle(
                                                        fontSize: 18.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          actions: [
                                            Center(
                                              child: TextButton(
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .deepPurpleAccent),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  }),
                                            ),
                                          ],
                                          elevation: 24,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text("Movement duration :",
                                      style: TextStyle(fontSize: 18)),
                                  DecoratedBox(
                                    // to style the dropdown button
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        //background color of dropdown button
                                        borderRadius: BorderRadius.circular(50),
                                        //border raiuds of dropdown button
                                        boxShadow: const <BoxShadow>[
                                          //apply shadow on Dropdown button
                                          BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.57),
                                              //shadow for button
                                              blurRadius: 5)
                                          //blur radius of shadow
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30),
                                      child: DropdownButton(
                                        value: movementDuration,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            movementDuration = newValue!;
                                          });
                                        },
                                        items: itemsTest
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text("Number of repetition :",
                                      style: TextStyle(fontSize: 18)),
                                  DecoratedBox(
                                    // to style the dropdown button
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        //background color of dropdown button
                                        borderRadius: BorderRadius.circular(50),
                                        //border radius of dropdown button
                                        boxShadow: const <BoxShadow>[
                                          //apply shadow on Dropdown button
                                          BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.57),
                                              //shadow for button
                                              blurRadius: 5)
                                          //blur radius of shadow
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30),
                                      child: DropdownButton(
                                        value: nbRepetition,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            nbRepetition = newValue!;
                                          });
                                        },
                                        items: itemsNbRepetitions
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text("NEW MEASUREMENT"),
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.only(
                                              left: 50,
                                              right: 50,
                                              top: 15,
                                              bottom: 15)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xff2c274c)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MeasurePage2(
                                            nbRepetition:
                                                int.parse(nbRepetition),
                                            duration:
                                                int.parse(movementDuration),
                                            patientID:
                                                snapshot.data!.first.id!)),
                                  );
                                },
                              ),
                              //const SizedBox(height: 10),
                            ],
                          ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Last Measure",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.question_mark_outlined)),
                                ],
                              ),
                              //TODO change type dynamic
                              StreamBuilder<List<Score>>(
                                  stream: blocScore.data,
                                  builder: (context, snapshot) {
                                    blocScore
                                        .getScoreByPatientId(widget.patientId);
                                    if (snapshot.data != null &&
                                        snapshot.data!.isNotEmpty) {
                                      /*print((snapshot.data!.last.elevationAngleInjured * 100 ~/ 180).toDouble().toString());
                                      print((snapshot.data!.last.elevationAngleInjured).toDouble().toString());
                                      print((100 - snapshot.data!.last.elevationAngleInjured * 100 ~/ 180).toDouble().toString());
                                      print((180 - snapshot.data!.last.elevationAngleInjured).toDouble().toString());*/
                                      return Column(
                                        children: [
                                          Text(
                                              snapshot.data!.first.creationDate),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 25),
                                                      Text(snapshot.data!.first.bbScore > 135 ? ">135%" :
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
                                                      const Text("B-B Score", style: TextStyle(fontSize: 14),),
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
                                                            Text(snapshot.data!.first.elevationAngleInjured > 180 ? ">180°" :
                                                              "${snapshot.data!.first.elevationAngleInjured ~/ 1}°",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .deepPurple,
                                                                  fontSize: 20,
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
                                                                    value: snapshot.data!.first.elevationAngleInjured > 180 ? 180 : (snapshot.data!.first.elevationAngleInjured)
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
                                                                    value: snapshot.data!.first.elevationAngleInjured > 180 ? 0 : (180 -
                                                                        snapshot.data!.first.elevationAngleInjured)
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
                                                          "Elevation Angle", style: TextStyle(fontSize: 13),),
                                                      const Text(
                                                          "Injured shoulder", style: TextStyle(fontSize: 13)),
                                                    ],
                                                  ),
                                                  //TODO ajouter securité pour si angle + grand que 180 ou plus petit que 0 -> ramener tout a 0 ou 180
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
                                                            Text( snapshot.data!.first.elevationAngleHealthy > 180 ? ">180°":
                                                              "${snapshot.data!.first.elevationAngleHealthy ~/ 1}°",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .deepPurple,
                                                                  fontSize: 20,
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
                                                                    value: snapshot.data!.first.elevationAngleHealthy > 180 ? 180 : (snapshot.data!.first.elevationAngleHealthy)
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
                                                                    value: snapshot.data!.first.elevationAngleHealthy > 180 ? 0 : (180 -
                                                                            snapshot.data!.first.elevationAngleHealthy)
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
                                              )
                                        ],
                                      );
                                    }
                                    return const Text("No Data");
                                  }),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Align(
                        child: CircularProgressIndicator(),
                        alignment: FractionalOffset.center);
                  }
                }),
          ],
        ),
      );

  }
}
