import 'package:flutter/material.dart';
import 'package:hands_up/widgets/modify_patient.dart';

import '../bloc_database/db_bloc_patient.dart';
import '../graph/graph.dart';
import 'all_scores_of_patient_page.dart';
import 'home_page.dart';
import 'measure_page.dart';

class PatientPage extends StatefulWidget {
  //final Patient patient;
  final int patientId;

  const PatientPage({Key? key, required this.patientId, patientID})
      : super(key: key);

  @override
  State<PatientPage> createState() => _PatientPage();
}

class _PatientPage extends State<PatientPage> {
  final DataBaseBlocPatient bloc = DataBaseBlocPatient();

  @override
  initState() {
    super.initState();
    bloc.getPatientByID(id: widget.patientId);
  }

  bool isTextFieldPatientClear = true;
  String movementDuration = "8";
  String nbRepetition = "3";
  var itemsTest = ["3", "4", "5", "6", "7", "8", "9"];
  var itemsNbRepetitions = ["2", "3", "4", "5"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile patient"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<List<dynamic>>(
                stream: bloc.data,
                builder: (context, snapshot) {
                  bloc.getPatientByID(id: widget.patientId);
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return Column(children: [
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        margin: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.lightBlueAccent,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.black54,
                                blurRadius: 15.0,
                                offset: Offset(0.0, 0.75))
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text("PATIENT INFORMATION",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            Text("ID : ${snapshot.data!.first.id.toString()}"),
                            Text("Name : ${snapshot.data!.first.name}"),
                            Text(
                                "First name : ${snapshot.data!.first.firstName}"),
                            Text(
                                "Birth date : ${snapshot.data!.first.dateOfBirth}"),
                            Text("Email : ${snapshot.data!.first.email}"),
                            Text(
                                "Creation date : ${snapshot.data!.first.creationDate}"),
                            Text(
                                "Shoulder reference : ${snapshot.data!.first.isRightReferenceOrHealthy ? "Right" : "Left"}"),
                            Text(
                                "Health condition : ${snapshot.data!.first.healthCondition}"),
                            Text(
                                "Other pathology : ${snapshot.data!.first.otherPathology}"),
                            Text("Notes : ${snapshot.data!.first.notes}"),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        margin: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.lightBlueAccent,
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
                              children: <Widget>[
                                const Text("MEASURE",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.quiz_outlined),
                                  color: Colors.deepPurpleAccent,
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
                                                  style:
                                                      TextStyle(fontSize: 18.0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
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
                                              bottom: 15))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MeasurePage(
                                          nbRepetition: int.parse(nbRepetition),
                                          duration: int.parse(movementDuration),
                                          patientID: snapshot.data!.first.id)),
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              icon: const Icon(
                                  Icons.format_list_bulleted_outlined),
                              label: const Text("All measures"),
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.only(
                                              left: 50, right: 50))),
                              onPressed: () {
                                //go to scores page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AllScoresOfPatientPage(
                                              patientID:
                                                  snapshot.data!.first.id)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            bloc.deletePatientById(widget.patientId);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          },
                          child: const Text("Delete this patient")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LineChartSample(
                                        patientId: snapshot.data!.first.id)));
                          },
                          child: const Text("Plot values")),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ModifyPatientPage(
                                        patientId: widget.patientId)));
                          },
                          child: const Text("Modify patient")),
                    ]);
                  } else {
                    return const Align(
                        child: CircularProgressIndicator(),
                        alignment: FractionalOffset.center);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
