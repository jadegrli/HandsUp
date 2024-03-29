import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hands_up/widgets/score_page.dart';

import '../bloc_database/db_bloc_score.dart';

class AllScoresWithoutPatientPage extends StatefulWidget {
  const AllScoresWithoutPatientPage({Key? key}) : super(key: key);

  @override
  State<AllScoresWithoutPatientPage> createState() =>
      _AllScoresWithoutPatientPage();
}

class _AllScoresWithoutPatientPage extends State<AllScoresWithoutPatientPage> {
  final DataBaseBlocScore bloc = DataBaseBlocScore();

  @override
  void initState() {
    super.initState();
    bloc.getScoreWithNoPatient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All scores with no patient",
            style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xfff5eaf4),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<dynamic>>(
                  stream: bloc.data,
                  builder: (context, snapshot) {
                    bloc.getScoreWithNoPatient();
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        primary:
                            false, //if true doesn't scroll because of SingleChildScrollView
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Color(0xfff5eaf4),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 15.0,
                                      offset: Offset(0.0, 0.75))
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                        snapshot.data![index].creationDate,
                                        style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 25),
                                          Text(
                                            snapshot.data![index].bbScore > 135
                                                ? ">135%"
                                                : "${snapshot.data![index].bbScore ~/ 1}%",
                                            style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 40),
                                          const Text("B-B Score",
                                              style: TextStyle(fontSize: 14)),
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Color(0xfff5eaf4),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Text(
                                                  snapshot.data![index]
                                                              .elevationAngleInjured >
                                                          180
                                                      ? ">180°"
                                                      : "${snapshot.data![index].elevationAngleInjured ~/ 1}°",
                                                  style: const TextStyle(
                                                      color: Colors.deepPurple,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                        color:
                                                            Colors.deepPurple,
                                                        value: snapshot
                                                                    .data![
                                                                        index]
                                                                    .elevationAngleInjured >
                                                                180
                                                            ? 100
                                                            : (snapshot
                                                                        .data![
                                                                            index]
                                                                        .elevationAngleInjured *
                                                                    100 ~/
                                                                    180)
                                                                .toDouble(),
                                                        title:
                                                            "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                                        radius: 10,
                                                        titleStyle:
                                                            const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffffffff)),
                                                      ),
                                                      PieChartSectionData(
                                                        color: const Color(
                                                            0xffb5abcc),
                                                        value: snapshot
                                                                    .data![
                                                                        index]
                                                                    .elevationAngleInjured >
                                                                100
                                                            ? 0
                                                            : (100 -
                                                                    snapshot.data![index]
                                                                            .elevationAngleInjured *
                                                                        100 ~/
                                                                        180)
                                                                .toDouble(),
                                                        title: "",
                                                        /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
                                                        radius: 10,
                                                        titleStyle:
                                                            const TextStyle(
                                                                fontSize: 20,
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
                                          const Text("Elevation Angle",
                                              style: TextStyle(fontSize: 13)),
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)),
                                              color: Color(0xfff5eaf4),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Text(
                                                  snapshot.data![index]
                                                              .elevationAngleHealthy >
                                                          180
                                                      ? ">180°"
                                                      : "${snapshot.data![index].elevationAngleHealthy ~/ 1}°",
                                                  style: const TextStyle(
                                                      color: Colors.deepPurple,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                        color:
                                                            Colors.deepPurple,
                                                        value: snapshot
                                                                    .data![
                                                                        index]
                                                                    .elevationAngleHealthy >
                                                                180
                                                            ? 100
                                                            : (snapshot
                                                                        .data![
                                                                            index]
                                                                        .elevationAngleHealthy *
                                                                    100 ~/
                                                                    180)
                                                                .toDouble(),
                                                        title:
                                                            "", //(snapshot.data!.last.elevationAngleInjured ~/ 1).toString(),
                                                        radius: 10,
                                                        titleStyle:
                                                            const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    0xffffffff)),
                                                      ),
                                                      PieChartSectionData(
                                                        color: const Color(
                                                            0xffb5abcc),
                                                        value: snapshot
                                                                    .data![
                                                                        index]
                                                                    .elevationAngleHealthy >
                                                                180
                                                            ? 0
                                                            : (100 -
                                                                    snapshot.data![index]
                                                                            .elevationAngleHealthy *
                                                                        100 ~/
                                                                        180)
                                                                .toDouble(),
                                                        title: "",
                                                        /*((180 - snapshot.data!.last.elevationAngleInjured ~/ 1)).toString(),*/
                                                        radius: 10,
                                                        titleStyle:
                                                            const TextStyle(
                                                                fontSize: 20,
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
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScorePage(
                                          id: snapshot.data![index].id!,
                                          patientId: 0,
                                        )),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return const Align(
                          child: Text("No data"),
                          alignment: FractionalOffset.center);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
