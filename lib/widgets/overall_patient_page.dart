
import 'package:flutter/material.dart';
import 'package:hands_up/widgets/patient_page.dart';

import '../graph/graph.dart';
import 'all_scores_of_patient_page.dart';

class OverallPatientPage extends StatefulWidget {
  const OverallPatientPage({Key? key, required this.patientId}) : super(key: key);

  final int patientId;

  @override
  _OverallPatientPage createState() => _OverallPatientPage();
}

class _OverallPatientPage extends State<OverallPatientPage> {
  int pageIndex = 0;
  late int id_patient;

  @override
  void initState() {
    super.initState();
    id_patient = widget.patientId;
  }


  @override
  Widget build(BuildContext context) {
    final pages = [
      PatientPage(patientId: widget.patientId),
      AllScoresOfPatientPage(patientID: widget.patientId),
      LineChartSample(patientId: widget.patientId),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2c274c),
        title: const Text(
          "Patient profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xff2c274c),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.person,
              color: Colors.black,
              size: 35,
            )
                : const Icon(
              Icons.person,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.format_list_bulleted_outlined,
              color: Colors.black,
              size: 35,
            )
                : const Icon(
              Icons.format_list_bulleted_outlined,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.auto_graph,
              color: Colors.black,
              size: 35,
            )
                : const Icon(
              Icons.auto_graph,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

}