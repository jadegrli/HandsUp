import 'package:flutter/material.dart';
import 'package:hands_up/widgets/overall_patient_page.dart';
import 'package:hands_up/widgets/page_test.dart';
import 'package:hands_up/widgets/patient_page.dart';


import '../bloc_database/db_bloc_patient.dart';
import '../models/patient.dart';
import 'add_patient_page.dart';
import 'all_scores_page.dart';
import 'all_scores_without_patient.dart';
import 'measure_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late TextEditingController controller;
  bool isTextFieldPatientClear = true;
  String movementDuration = "8";
  String nbRepetition = "3";
  String sortChoice = "A-Z";
  String patientNameToFind = "";
  var itemsTest = ["3", "4", "5", "6", "7", "8", "9"];
  var itemsNbRepetitions = ["2", "3", "4", "5"];
  //TODO mettre des enum plutot ici, + simple pour comparer
  var itemsSortsPatient = [
    "A-Z",
    "Z-A",
    "rot. cuff",
    "froz. sh.",
    "hum. fr.",
    "other"
  ];

  final DataBaseBlocPatient bloc = DataBaseBlocPatient();

  void clearText() {
    controller = "" as TextEditingController;
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    bloc.getAllPatients();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 5,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.indigo[50],
          title: const Text(
            "HandsUp",
            style: TextStyle(color: Color(0xff000000)),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_rounded),
              color: Colors.deepPurpleAccent,
              iconSize: 35,
              onPressed: () {
                showDialog(
                  //if set to true allow to close popup by tapping out of the popup
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Center(
                      child: Text("Information"),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        children: const <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "INFO",
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    actions: [
                      Center(
                        child: TextButton(
                            child: const Text(
                              "Close",
                              style: TextStyle(color: Colors.deepPurpleAccent),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                        const Text("QUICK START",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.quiz_outlined),
                          color: Colors.deepPurpleAccent,
                          iconSize: 25,
                          onPressed: () {
                            showDialog(
                              //if set to true allow to close popup by tapping out of the popup
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
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
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                actions: [
                                  Center(
                                    child: TextButton(
                                        child: const Text(
                                          "Close",
                                          style: TextStyle(
                                              color: Colors.deepPurpleAccent),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
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
                              //border radius of dropdown button
                              boxShadow: const <BoxShadow>[
                                //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57),
                                    //shadow for button
                                    blurRadius: 5)
                                //blur radius of shadow
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: DropdownButton(
                              value: movementDuration,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  movementDuration = newValue!;
                                });
                              },
                              items: itemsTest.map<DropdownMenuItem<String>>(
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
                                    color: Color.fromRGBO(0, 0, 0, 0.57),
                                    //shadow for button
                                    blurRadius: 5)
                                //blur radius of shadow
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: DropdownButton(
                              value: nbRepetition,
                              icon: const Icon(Icons.keyboard_arrow_down),
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
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.only(
                                  left: 50, right: 50, top: 15, bottom: 15))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeasurePage(nbRepetition: int.parse(nbRepetition), duration: int.parse(movementDuration), patientID: 0)),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.format_list_bulleted_outlined),
                      label: const Text("All measures"),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.only(left: 50, right: 50))),
                      onPressed: () {
                        //TODO pages with all score with id patient = 0 -> no patient
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AllScoresWithoutPatientPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10),
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
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(10),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text("Patient List",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                                      color: Color.fromRGBO(0, 0, 0, 0.57),
                                      //shadow for button
                                      blurRadius: 5)
                                  //blur radius of shadow
                                ]),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 30),
                              child: DropdownButton(
                                value: sortChoice,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    sortChoice = newValue!;
                                  });
                                },
                                items: itemsSortsPatient
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
                          IconButton(
                            icon: const Icon(Icons.quiz_outlined),
                            color: Colors.deepPurpleAccent,
                            iconSize: 25,
                            onPressed: () {
                              showDialog(
                                //if set to true allow to close popup by tapping out of the popup
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
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
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  actions: [
                                    Center(
                                      child: TextButton(
                                          child: const Text(
                                            "Close",
                                            style: TextStyle(
                                                color: Colors.deepPurpleAccent),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
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
                    ),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded),
                        hintStyle: const TextStyle(color: Colors.blue),
                        hintText: "Enter a name",
                        suffixIcon: isTextFieldPatientClear
                            ? null
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    isTextFieldPatientClear = true;
                                    controller.clear();
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              ),
                      ),
                      onChanged: (val) {
                        setState(
                          () {
                            if (controller.text.isEmpty) {
                              isTextFieldPatientClear = true;
                            } else {
                              isTextFieldPatientClear = false;
                            }
                          },
                        );
                      },
                    ),
                    StreamBuilder<List<Patient>>(
                        stream: bloc.data,
                        builder: (context, snapshot) {
                          bloc.getAllPatients();
                          if (snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return ListView.builder(
                              primary:
                                  false, //sinon ça scroll pas à cause du SingleChildScrollView
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Row(
                                    children: [
                                      Text(snapshot.data![index].name),
                                      const SizedBox(width: 5),
                                      Text(snapshot.data![index].firstName),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OverallPatientPage(
                                                patientId:
                                                snapshot.data![index].id!)));
                                    /*Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PatientPage(
                                                patientId:
                                                    snapshot.data![index].id!)));*/
                                  },
                                );
                              },
                            );
                          } else {
                            return Column(
                              children: const [
                                SizedBox(height: 15),
                                Center(
                                  child: Text("No patient",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 15),
                              ],
                            );
                          }
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: SizedBox(
          height: 70.0,
          width: 70.0,
          child: FloatingActionButton(
            onPressed: () {
              /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PageTest()));*/
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePatientPage()));
              //addPatient();
              /*showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    // Retrieve the text that the user has entered by using the
                    // TextEditingController.
                    //content: Text(controller.text),
                    content: Text("Patient added!"),
                  );
                },
              );*/
            },
            backgroundColor: Colors.deepPurpleAccent,
            child: const Icon(
              Icons.person_add,
              size: 40,
            ),
          ),
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void addPatient() {
    final patient = Patient(
        name: "Doe",
        firstName: "Jane",
        dateOfBirth: "01.01.1990",
        email: "jane.doe@gmail.com",
        notes: "pas disponible en juillet",
        creationDate: "06.06.2021",
        isRightReferenceOrHealthy: true,
        healthCondition: "frozen shoulder",
        otherPathology: "none");
    bloc.addPatient(patient);
  }
}
