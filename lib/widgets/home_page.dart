import 'package:flutter/material.dart';
import 'package:hands_up/widgets/measure_page_2.dart';
import 'package:hands_up/widgets/overall_patient_page.dart';

import '../bloc_database/db_bloc_patient.dart';
import '../models/patient.dart';
import 'add_patient_page.dart';
import 'all_scores_without_patient.dart';

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
  var itemsTest = ["3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"];
  var itemsNbRepetitions = ["2", "3", "4", "5"];
  var itemsSortsPatient = [
    "A-Z",
    "Z-A",
    "healthy",
    "rot. cuff",
    "frozen sh.",
    "hum. frac.",
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
        backgroundColor: const Color(0xffeeebf4), //ok
        appBar: AppBar(
          centerTitle: true,
          elevation: 5,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xfff5eaf4),
          title: const Text(
            "HandsUp",
            style: TextStyle(color: Color(0xff000000)),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.info_rounded),
              color: const Color(0xff895cbc),
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
                  color: Color(0xfff5eaf4), // ok
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
                      children: const <Widget>[
                        Text("QUICK START",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
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
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xff7a52a8)), //ok
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.only(
                                  left: 50, right: 50, top: 15, bottom: 15))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeasurePage2(
                                  nbRepetition: int.parse(nbRepetition),
                                  duration: int.parse(movementDuration),
                                  patientID: 0)),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.format_list_bulleted_outlined),
                      label: const Text("All measures"),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xff8cc0cc)), //ok
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.only(left: 50, right: 50))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AllScoresWithoutPatientPage()),
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
                  color: Color(0xfff5eaf4), //ok
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
                        color: Color(0xfff5eaf4), // ok
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0.0, 0.75))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                      controller: controller,
                      onSubmitted: (value) {},
                      decoration: InputDecoration(
                        iconColor: Colors.deepPurple,
                        icon: const Icon(Icons.search_rounded),
                        hintStyle: const TextStyle(color: Colors.black),
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
                          if (controller.text.isEmpty) {
                            switch (sortChoice) {
                              case "A-Z":
                                bloc.getAllPatients();
                                break;
                              case "Z-A":
                                bloc.getAllPatientsZA();
                                break;
                              case "rot. cuff":
                                bloc.getAllPatientPathology("Rotator cuff");
                                break;
                                case "healthy":
                                bloc.getAllPatientPathology("Healthy");
                          break;
                              case "frozen sh.":
                                bloc.getAllPatientPathology("Frozen shoulder");
                                break;
                              case "hum. frac.":
                                bloc.getAllPatientPathology("Humerus fracture");
                                break;
                              case "other":
                                bloc.getAllPatientPathology("Other");
                                break;
                              default:
                                bloc.getAllPatients();
                                break;
                            }
                          } else {
                            String name = controller.text;
                            bloc.getPatientsByName(query: name);
                          }
                          if (snapshot.data != null &&
                              snapshot.data!.isNotEmpty) {
                            return ListView.builder(
                              primary:
                                  false, //if true doesn't scroll because of SingleChildScrollView
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data?.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                          const Color(0xff8cc0cc),
                                          child: Text(
                                            snapshot.data![index].name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(snapshot.data![index].name),
                                        const SizedBox(width: 5),
                                        Text(snapshot.data![index].firstName),
                                      ],
                                    ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OverallPatientPage(
                                                    patientId: snapshot
                                                        .data![index].id!)));
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreatePatientPage()));
            },
            backgroundColor: const Color(0xff8cc0cc), //ok
            child: const Icon(
              Icons.person_add,
              size: 40,
            ),
          ),
        )
        );
  }

}
