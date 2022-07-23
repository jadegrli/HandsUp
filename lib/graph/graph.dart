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
  List<FlSpot> spotListBBScore = <FlSpot>[];
  List<FlSpot> spotListAngleInjured = <FlSpot>[];
  List<FlSpot> spotListAngleHealthy = <FlSpot>[];
  double _minXBBScore = 0;
  double _maxXBBScore = 0;
  final double _minYBBScore = 0;
  final double _maxYBBScore = 130;
  double _minXAngle = 0;
  double _maxXAngle = 0;
  final double _minYAngle = 0;
  final double _maxYAngle = 180;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
    blocScore.getScoreByPatientId(widget.patientId);
  }

//for all the score took during the same day we make an average of the B-B Score and we take one of the epochDate.
// With those two value we create a new Score and remove the 2 others from the list
  List<Score> sortScoreDayBBScore(List<Score> values) {
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

  List<Score> sortScoreDayAngle(List<Score> values, bool isHealthy) {
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
        double angleAverage = 0;
        for (int i = 0; i < tmp.length; ++i) {
          angleAverage += isHealthy ? tmp[i].elevationAngleHealthy : tmp[i].elevationAngleInjured;
        }
        angleAverage /= tmp.length;
        result.add(Score(
            creationDate: score0.creationDate,
            elevationAngleInjured: angleAverage,
            elevationAngleHealthy: angleAverage,
            bbScore: 0,
            patientId: 0,
            notes: ""));
        list.removeWhere(
                (element) => element.creationDate == score0.creationDate);
        tmp.clear();
      }
    }
    return result;
  }

  List<Score> sortScoreMonthBBScore(List<Score> values) {
    List<Score> list = List.from(values);
    List<Score> tmp = <Score>[];
    Score score0;
    List<Score> result = <Score>[];

    while (list.isNotEmpty) {
      score0 = list[0];
      for (int i = 1; i < list.length; ++i) {
        if (score0.creationDate.substring(0, 7) == list[i].creationDate.substring(0, 7)) {
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
                (element) => element.creationDate.substring(0, 7) == score0.creationDate.substring(0, 7));
        tmp.clear();
      }
    }
    return result;
  }

  List<Score> sortScoreMonthAngle(List<Score> values, bool isHealthy) {
    List<Score> list = List.from(values);
    List<Score> tmp = <Score>[];
    Score score0;
    List<Score> result = <Score>[];

    while (list.isNotEmpty) {
      score0 = list[0];
      for (int i = 1; i < list.length; ++i) {
        if (score0.creationDate.substring(0, 7) == list[i].creationDate.substring(0, 7)) {
          tmp.add(list[i]);
        }
      }
      if (tmp.isEmpty) {
        result.add(score0);
        list.removeAt(0);
      } else {
        tmp.add(score0);
        double angleAverage = 0;
        for (int i = 0; i < tmp.length; ++i) {
          angleAverage += isHealthy ?  tmp[i].elevationAngleHealthy : tmp[i].elevationAngleInjured;
        }
        angleAverage /= tmp.length;
        result.add(Score(
            creationDate: score0.creationDate,
            elevationAngleInjured: angleAverage,
            elevationAngleHealthy: angleAverage,
            bbScore: 0,
            patientId: 0,
            notes: ""));
        list.removeWhere(
                (element) => element.creationDate.substring(0, 7) == score0.creationDate.substring(0, 7));
        tmp.clear();
      }
    }
    return result;
  }

  void getDataFromDbBBScore(List<Score> scoreList) {
    double minX = double.maxFinite;
    double maxX = double.minPositive;

    List<Score> newScoreList = sortScoreDayBBScore(scoreList);
    final format = DateFormat("yyyy-MM-dd");

    spotListBBScore = newScoreList.map((score) {
      var dt = format
          .parse(score.creationDate, true)
          .millisecondsSinceEpoch
          .toDouble();
      if (minX > dt) minX = dt;
      if (maxX < dt) maxX = dt;
      return FlSpot(
        dt,
        score.bbScore > 130 ? 130 : score.bbScore.toInt().toDouble() < 0 ? 0 : score.bbScore.toInt().toDouble(),
      );
    }).toList();

    _minXBBScore = minX - 86400000; //one day before in ms
    _maxXBBScore = maxX + 86400000; //one day after in ms
  }

  void getDataFromDbAngle(List<Score> scoreList) {
    double minX = double.maxFinite;
    double maxX = double.minPositive;

    List<Score> newScoreListHealthy = sortScoreDayAngle(scoreList, true);
    List<Score> newScoreListInjured = sortScoreDayAngle(scoreList, false);
    final format = DateFormat("yyyy-MM-dd");

    spotListAngleInjured = newScoreListInjured.map((score) {
      var dt = format
          .parse(score.creationDate, true)
          .millisecondsSinceEpoch
          .toDouble();
      if (minX > dt) minX = dt;
      if (maxX < dt) maxX = dt;
      return FlSpot(
        dt,
        score.elevationAngleInjured > 180 ? 180 : score.elevationAngleInjured.toInt().toDouble() < 0 ? 0 : score.elevationAngleInjured.toInt().toDouble(),
      );
    }).toList();

    spotListAngleHealthy = newScoreListHealthy.map((score) {
      var dt = format
          .parse(score.creationDate, true)
          .millisecondsSinceEpoch
          .toDouble();
      return FlSpot(
        dt,
        score.elevationAngleHealthy > 180 ? 180 : score.elevationAngleHealthy.toInt().toDouble() < 0 ? 0 : score.elevationAngleHealthy.toInt().toDouble(),
      );
    }).toList();

    _minXAngle = minX ;//- 86400000; //one day before in ms
    _maxXAngle = maxX ;//+ 86400000; //one day after in ms
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: orientation == Orientation.portrait ? MediaQuery.of(context).size.height/2 : MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.all(10),
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
                                    fontSize: 20,
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
                              padding:
                              const EdgeInsets.only(right: 60.0, left: 20.0),
                              child: StreamBuilder<List<Score>>(
                                  stream: blocScore.data,
                                  builder: (context, snapshot) {
                                    blocScore.getScoreByPatientId(widget.patientId);
                                    if (snapshot.data != null &&
                                        snapshot.data!.isNotEmpty) {
                                      getDataFromDbBBScore(snapshot.data!);
                                      return graphBBScore();
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

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: orientation == Orientation.portrait ? MediaQuery.of(context).size.height/2 : MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.all(10),
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
                          Padding(
                            padding: const EdgeInsets.only(right: 60.0, left: 20.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Elevation angle',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(
                                  width: 80,
                                ),
                                Column(
                                  children: const [
                                    Text(
                                      'Healthy',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Injured',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 37,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.only(right: 60.0, left: 20.0),
                              child: StreamBuilder<List<Score>>(
                                  stream: blocScore.data,
                                  builder: (context, snapshot) {
                                    blocScore.getScoreByPatientId(widget.patientId);
                                    if (snapshot.data != null &&
                                        snapshot.data!.isNotEmpty) {
                                      getDataFromDbAngle(snapshot.data!);
                                      return graphAngle();
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
            ],
          ),
        );
      },
    );

  }

  Widget graphBBScore() {
    return Center(
      child: LineChart(
        sampleDataBBScore,
        //swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget graphAngle() {
    return Center(
      child: LineChart(
        sampleDataAngle,
        //swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  LineChartData get sampleDataBBScore => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesDataBBScore,
        borderData: borderData,
        lineBarsData: lineBarsDataBBScore,
        minX: _minXBBScore,
        maxX: _maxXBBScore,
        minY: _minYBBScore,
        maxY: _maxYBBScore,
      );

  LineChartData get sampleDataAngle => LineChartData(
    lineTouchData: lineTouchData, //ok
    gridData: gridData, //ok
    titlesData: titlesDataAngle, //ok
    borderData: borderData, //ok
    lineBarsData: lineBarsDataAngle,
    minX: _minXAngle,//ok tout ça
    maxX: _maxXAngle,
    minY: _minYAngle,
    maxY: _maxYAngle,
  );

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesDataBBScore => FlTitlesData(
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
          sideTitles: leftTitlesBBScore(),
        ),
      );

  FlTitlesData get titlesDataAngle => FlTitlesData(
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
      sideTitles: leftTitlesAngle(),
    ),
  );

  List<LineChartBarData> get lineBarsDataBBScore => [
        /*lineChartBarData1_1,
        lineChartBarData1_2,
        lineChartBarData1_3,*/
        lineChartBarDataBBScore
      ];

  List<LineChartBarData> get lineBarsDataAngle => [
    lineChartBarDataAngleInjured,
    lineChartBarDataAngleHealthy
  ];

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 80,
        interval: 86400000, //one day in ms
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.bold,
      fontSize: 10,
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
      child: RotatedBox( //to display the text vertically
        quarterTurns: 1,
        child: text,
      ),
    );
  }

  SideTitles leftTitlesBBScore() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  SideTitles leftTitlesAngle() => SideTitles(
    getTitlesWidget: leftTitleWidgets,
    showTitles: true,
    interval: 30,
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

  LineChartBarData get lineChartBarDataBBScore => LineChartBarData(
        isCurved: true,
        color: const Color(0xff27b6fc),
        barWidth: 5,
        isStrokeCapRound: true,
        //dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: spotListBBScore, //getDataFromDb(),
      );

  LineChartBarData get lineChartBarDataAngleInjured => LineChartBarData(
    isCurved: true,
    color: Colors.red,
    barWidth: 5,
    isStrokeCapRound: true,
    //dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: spotListAngleInjured, //getDataFromDb(),
  );

  LineChartBarData get lineChartBarDataAngleHealthy=> LineChartBarData(
    isCurved: true,
    color: Colors.green,
    barWidth: 5,
    isStrokeCapRound: true,
    //dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: spotListAngleHealthy //getDataFromDb(),
  );
}
