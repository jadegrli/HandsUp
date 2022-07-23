import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bloc_database/db_bloc_patient.dart';
import '../models/patient.dart';
import 'home_page.dart';

class ModifyPatientPage extends StatefulWidget {
  const ModifyPatientPage({Key? key, required this.patientId})
      : super(key: key);

  final int patientId;

  @override
  State<ModifyPatientPage> createState() => _ModifyPatientPage();
}

class _ModifyPatientPage extends State<ModifyPatientPage> {
  final firstNameTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final otherPathologyTextController = TextEditingController();
  final notesTextController = TextEditingController();

  bool hasPathology = false;
  bool isLeftShoulder = false;
  bool isRightShoulder = false;
  String creationDate = "";
  bool canUpdate = false;
  bool initOnce = true;

  DateTime date = DateTime.now();
  final DateTime todayDate = DateTime.now();

  String sortChoice = "Rotator cuff";

  final DataBaseBlocPatient bloc = DataBaseBlocPatient();

  bool verifyEntries() {
    if (firstNameTextController.text.isEmpty ||
        nameTextController.text.isEmpty ||
        emailTextController.text.isEmpty ||
        !emailTextController.text.contains("@") ||
        !emailTextController.text.contains(".")) {
      return false;
    }
    if (todayDate.day == date.year &&
        todayDate.month == date.month &&
        todayDate.year == date.year) {
      return false;
    }
    //TODO remove
    if (!isLeftShoulder && !isRightShoulder) {
      return false;
    }

    if (hasPathology && sortChoice == "Other" && otherPathologyTextController.text.isEmpty) {
      return false;
    }
    return true;
  }

  String getMonth(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Month";
    }
  }

  @override
  void initState() {
    super.initState();
    bloc.getPatientByID(id: widget.patientId);
  }

  @override
  void dispose() {
    super.dispose();
    firstNameTextController.dispose();
    nameTextController.dispose();
    emailTextController.dispose();
    otherPathologyTextController.dispose();
    notesTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify patient'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<dynamic>>(
          stream: bloc.data,
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              if (initOnce){
                initOnce = false;
                firstNameTextController.text = snapshot.data!.first.firstName;
                nameTextController.text = snapshot.data!.first.name;
                emailTextController.text = snapshot.data!.first.email;
                otherPathologyTextController.text =
                    snapshot.data!.first.otherPathology == "-" ? "" : snapshot.data!.first.otherPathology;
                notesTextController.text = snapshot.data!.first.notes;
                hasPathology = snapshot.data!.first.healthCondition == "Healthy"
                    ? false
                    : true;
                date = DateTime.parse(snapshot.data!.first.dateOfBirth);
                creationDate = snapshot.data!.first.creationDate;
                if (hasPathology) {
                  sortChoice = snapshot.data!.first.healthCondition;
                }

                if (snapshot.data!.first.isRightReferenceOrHealthy) {
                  isLeftShoulder = false;
                  isRightShoulder = true;
                } else {
                  isLeftShoulder = true;
                  isRightShoulder = false;
                }
                canUpdate = true;
              }

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Name"),
                      maxLines: 1,
                      controller: nameTextController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "First Name"),
                      maxLines: 1,
                      controller: firstNameTextController,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Text("Birth date : ",
                                style: TextStyle(
                                  fontSize: 18.0,
                                )),
                            Text(
                              '${date.day} ${getMonth(date.month)} ${date.year}',
                              style: const TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            IconButton(
                                onPressed: () async {
                                  DateTime? newdate = await showDatePicker(
                                      context: context,
                                      initialDate: date,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100));
                                  if (newdate == null) return;
                                  setState(() {
                                    date = newdate;
                                  });
                                },
                                icon: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.blue,
                                  size: 50.0,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Email"),
                      maxLines: 1,
                      controller: emailTextController,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 10,
                      ), //SizedBox
                      const Text(
                        'Pathology (check if yes) : ',
                        style: TextStyle(fontSize: 17.0),
                      ), //Text
                      const SizedBox(width: 10), //SizedBox
                      Checkbox(
                        checkColor: Colors.white,
                        value: hasPathology,
                        onChanged: (bool? value) {
                          setState(() {
                            hasPathology = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  hasPathology
                      ? selectShoulder("Injured")
                      : selectShoulder("Reference"),
                  if (hasPathology) selectPathology(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Notes"),
                      maxLines: 6,
                      maxLength: 400,
                      controller: notesTextController,
                    ),
                  ),
                ],
              );
            } else {
              canUpdate = false;
              return const Align(
                  child: CircularProgressIndicator(),
                  alignment: FractionalOffset.center);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () {
            if (canUpdate) {
              if (verifyEntries()) {
                final newPatient = Patient(
                    id: widget.patientId,
                    name: nameTextController.text,
                    firstName: firstNameTextController.text,
                    dateOfBirth: DateFormat("yyyy-MM-dd").format(date),
                    email: emailTextController.text,
                    notes: notesTextController.text,
                    creationDate: creationDate,
                    isRightReferenceOrHealthy: isRightShoulder,
                    healthCondition: hasPathology ? sortChoice : "Healthy",
                    otherPathology: sortChoice == "Other" && hasPathology
                        ? otherPathologyTextController.text
                        : "-");
                bloc.updatePatient(newPatient);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              } else {
                showDialog(
                  //if set to true allow to close popup by tapping out of the popup
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) =>
                      AlertDialog(
                        title: const Center(
                          child: Text(
                              "Information are missing or incorrect..."),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: const <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Please fill all information and check that everything is correct",
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
                                  "Ok",
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontSize: 20),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                }),
                          ),
                        ],
                        elevation: 24,
                      ),
                );
              }
            }
          }),
    );
  }

  Widget selectShoulder(String condition) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ), //SizedBox
            Text(
              "$condition shoulder : ",
              style: const TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            const Text(
              'L ',
              style: TextStyle(fontSize: 17.0),
            ),
            Checkbox(
              checkColor: Colors.white,
              value: isLeftShoulder,
              onChanged: (bool? value) {
                setState(() {
                  isLeftShoulder = value!;
                  if (isRightShoulder) {
                    isRightShoulder = false;
                  }
                });
              },
            ),
            const SizedBox(width: 10), //SizedBox
            const Text(
              'R',
              style: TextStyle(fontSize: 17.0),
            ),
            Checkbox(
              checkColor: Colors.white,
              value: isRightShoulder,
              onChanged: (bool? value) {
                setState(() {
                  isRightShoulder = value!;
                  if (isLeftShoulder) {
                    isLeftShoulder = false;
                  }
                });
              },
            ),
          ],
        )
      ],
    );
  }

  //TODO mettre des enum plutot ici, + simple pour comparer
  var pathologies = [
    "Rotator cuff",
    "Humerus fracture",
    "Frozen shoulder",
    "Other"
  ];



  Widget selectPathology() {
    return Column(
      children: [
        Row(
          children: [
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Select a pathology : ",
                    style: TextStyle(fontSize: 12.0))),
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
                  value: sortChoice,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      sortChoice = newValue!;
                    });
                  },
                  items:
                      pathologies.map<DropdownMenuItem<String>>((String value) {
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
        if (sortChoice == "Other")
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Enter pathology"),
              maxLines: 1,
              controller: otherPathologyTextController,
            ),
          ),
      ],
    );
  }
}
