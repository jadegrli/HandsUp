
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hands_up/export/export_data.dart';
import 'package:hands_up/widgets/score_page.dart';

import '../bloc_database/db_bloc_score.dart';



class AllScoresOfPatientPage extends StatefulWidget {
  final int patientID;
  const AllScoresOfPatientPage({Key? key, required this.patientID}) : super(key: key);

  @override
  State<AllScoresOfPatientPage> createState() => _AllScoresOfPatientPage();
}

class _AllScoresOfPatientPage extends State<AllScoresOfPatientPage> {

  final DataBaseBlocScore bloc = DataBaseBlocScore();

  @override
  void initState() {
    super.initState();
    bloc.getScoreByPatientId(widget.patientID);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
                stream: bloc.data,
                builder: (context, snapshot) {
                  bloc.getScoreByPatientId(widget.patientID);
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      primary: true, //sinon ça scroll pas à cause du SingleChildScrollView
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(5),
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
                                    Text(snapshot.data![index].creationDate,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                            Icons.question_mark_outlined)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const SizedBox(
                                            height: 25),
                                        Text(
                                          "${snapshot.data![index].bbScore ~/ 1}%",
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
                                        const Text("B-B Score", style: TextStyle(fontSize: 14)),
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
                                              Text(
                                                "${snapshot.data![index].elevationAngleInjured ~/ 1}°",
                                                style: const TextStyle(
                                                    color: Colors
                                                        .deepPurple,
                                                    fontSize: 23,
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
                                                      value: (snapshot.data![index].elevationAngleInjured *
                                                          100 ~/
                                                          180)
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
                                                      value: (100 -
                                                          snapshot.data![index].elevationAngleInjured *
                                                              100 ~/
                                                              180)
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
                                            "Injured shoulder", style: TextStyle(fontSize: 13)),
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
                                              Text(
                                                "${snapshot.data![index].elevationAngleHealthy ~/ 1}°",
                                                style: const TextStyle(
                                                    color: Colors
                                                        .deepPurple,
                                                    fontSize: 23,
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
                                                      value: (snapshot.data![index].elevationAngleHealthy *
                                                          100 ~/
                                                          180)
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
                                                      value: (100 -
                                                          snapshot.data![index].elevationAngleHealthy *
                                                              100 ~/
                                                              180)
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
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScorePage(id: snapshot.data![index].id!, patientId: widget.patientID,)),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const Align(
                        child: CircularProgressIndicator(),
                        alignment: FractionalOffset.center);
                  }
                });

  }

}