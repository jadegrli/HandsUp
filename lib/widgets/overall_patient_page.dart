
import 'package:flutter/material.dart';
import 'package:hands_up/bloc_database/db_bloc_repetition.dart';
import 'package:hands_up/export/export_data.dart';
import 'package:hands_up/widgets/patient_page.dart';

import '../bloc_database/db_bloc_score.dart';
import '../graph/graph.dart';
import '../models/repetition.dart';
import '../models/score.dart';
import 'all_scores_of_patient_page.dart';

class OverallPatientPage extends StatefulWidget {
  const OverallPatientPage({Key? key, required this.patientId}) : super(key: key);

  final int patientId;

  @override
  _OverallPatientPage createState() => _OverallPatientPage();
}

class _OverallPatientPage extends State<OverallPatientPage> {
  int pageIndex = 0;
  late int idPatient;
  bool showAppBar = true;
   final blocScore = DataBaseBlocScore();
   final blocRepetition = DataBaseBlocRepetition();
   final export = ExportDataBloc();

  @override
  void initState() {
    super.initState();
    idPatient = widget.patientId;
  }


  @override
  Widget build(BuildContext context) {
    final pages = [
      PatientPage(patientId: widget.patientId),
      AllScoresOfPatientPage(patientID: widget.patientId),
      LineChartSample(patientId: widget.patientId),
    ];

    return Scaffold(
      appBar: showAppBar ? AppBar(
        backgroundColor: const Color(0xff2c274c),
        title: const Text(
          "Patient profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(onPressed: () async {
            export.export(widget.patientId);
          }, icon: const Icon(Icons.share),)
        ],
      ) : null,
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            if (pageIndex == 0 || pageIndex == 1) {
              showAppBar = true;
            } else {
              showAppBar = !showAppBar;
            }
          });
        },
        child: pages[pageIndex],
      ),
      bottomNavigationBar: showAppBar ? buildMyNavBar(context) : null,
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