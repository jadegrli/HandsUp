
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/score.dart';

class LineChartSample extends StatefulWidget {
  const LineChartSample({Key? key, required this.patientId}) : super(key: key);

  final int patientId;

  @override
  State<StatefulWidget> createState() => _LineChartSample();
}

class _LineChartSample extends State<LineChartSample> {
  late bool isShowingMainData;
  final DataBaseBlocScore blocScore = DataBaseBlocScore();
  List<FlSpot> spotList = <FlSpot>[];
  double _minX = 0;
  double _maxX = 0;
  final double _minY = 0;
  final double _maxY = 130;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
    blocScore.getScoreByPatientId(widget.patientId);
  }

//for all the score took during the same day we make an average of the B-B Score and we take one of the epochDate.
// With those two value we create a new Score and remove the 2 others from the list
  List<Score> sortScoreDay(List<Score> values) {
    List<Score> list = List.from(values);
    List<Score> tmp = <Score>[];
    Score score0;
    List<Score> result = <Score>[];

    while (list.isNotEmpty) {
      score0 = list[0];
      for (int i = 1; i < list.length; ++i) {
        if (score0.creationDate == list[i].creationDate) {
          tmp.add(list[i]);
        }
      }
      if (tmp.isEmpty) {
        result.add(score0);
        list.removeAt(0);
      } else {
        tmp.add(score0);
        double bbScoreAverage = 0;
        for (int i = 0; i < tmp.length; ++i) {
          bbScoreAverage += tmp[i].bbScore;
        }
        bbScoreAverage /= tmp.length;
        result.add(Score(
            creationDate: score0.creationDate,
            elevationAngleInjured: 0,
            elevationAngleHealthy: 0,
            bbScore: bbScoreAverage,
            patientId: 0,
            notes: ""));
        list.removeWhere(
            (element) => element.creationDate == score0.creationDate);
        tmp.clear();
      }
    }
    return result;
  }

  void getDataFromDb(List<Score> scoreList) {
    double minX = double.maxFinite;
    double maxX = double.minPositive;

    List<Score> newScoreList = sortScoreDay(scoreList);
    final format = DateFormat("yyyy-MM-dd");

    spotList = newScoreList.map((score) {
      var dt = format
          .parse(score.creationDate, true)
          .millisecondsSinceEpoch
          .toDouble();
      if (minX > dt) minX = dt;
      if (maxX < dt) maxX = dt;
      return FlSpot(
        dt,
        score.bbScore,
      );
    }).toList();

    _minX = minX - 86400000; //one day before in ms
    _maxX = maxX + 86400000; //one day after in ms
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Graph"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AspectRatio(
          aspectRatio: 2,
          child: Container(
            margin: const EdgeInsets.all(45),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              gradient: LinearGradient(
                colors: [
                  Color(0xff2c274c),
                  Color(0xff46426c),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(
                      height: 37,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 60.0, left: 20.0),
                      child: Text(
                        'B-B Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 37,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 60.0, left: 20.0),
                        child: StreamBuilder<List<Score>>(
                            stream: blocScore.data,
                            builder: (context, snapshot) {
                              blocScore.getScoreByPatientId(widget.patientId);
                              if (snapshot.data != null &&
                                  snapshot.data!.isNotEmpty) {
                                getDataFromDb(snapshot.data!);
                                return graph();
                              } else {
                                return const Align(
                                    child: CircularProgressIndicator(),
                                    alignment: FractionalOffset.center);
                              }
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget graph() {
    return Center(
      child: LineChart(
        sampleData1,
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        lineTouchData: lineTouchData1,
        gridData: gridData,
        titlesData: titlesData1,
        borderData: borderData,
        lineBarsData: lineBarsData1,
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        /*lineChartBarData1_1,
        lineChartBarData1_2,
        lineChartBarData1_3,*/
        lineChartBarData
      ];

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 130,
        interval: 86400000, //one day in ms
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final String dateFormat = DateFormat("yyyy-MM-dd").format(date);

    Widget text = Text(
      dateFormat,
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: RotatedBox(
          quarterTurns: 1,
          child: text, //your text
      ),
    );
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 10,
        reservedSize: 40,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff75729e),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = value.toInt().toString();

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  FlGridData get gridData => FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 4),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData => LineChartBarData(
        isCurved: true,
        color: const Color(0xff27b6fc),
        barWidth: 8,
        isStrokeCapRound: true,
        //dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: spotList, //getDataFromDb(),
      );
}
