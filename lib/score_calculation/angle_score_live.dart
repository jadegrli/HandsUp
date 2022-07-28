

import 'dart:math';

import 'package:hands_up/score_calculation/score_live.dart';

import '../models/measure.dart';


class AngleScoreLive extends ScoreLive {
  AngleScoreLive({required List<Measure> allMeasures})
      : super(allMeasures: allMeasures);

  @override
  void computeScore() {
    //in case we want the elevation angle for the hand back movement
    //var angularRangeBackHealthy = <double>[];
    var angularRangeUpHealthy = <double>[];
    //var angularRangeBackInjured = <double>[];
    var angularRangeUpInjured = <double>[];

    double maxHealthy = _getAngularRange(allMeasures[0].accelValues);

    for (int i = 0; i < allMeasures.length ~/ 2; i++) {
      if (i % 2 == 1) {
        //hand up
          double tmp = _getAngularRange(allMeasures[i].accelValues);
          angularRangeUpHealthy.add(tmp);
          if (tmp > maxHealthy) maxHealthy = tmp;
      } /*else {
        angularRangeBackHealthy
            .add(_getAngularRange(allMeasures[i].accelValues));
      }*/
    }

    double maxInjured = _getAngularRange(
                allMeasures[allMeasures.length ~/ 2].accelValues);

    for (int i = allMeasures.length ~/ 2; i < allMeasures.length; i++) {
      if (i % 2 == 1) {
        //hand up
          double tmp = _getAngularRange(allMeasures[i].accelValues);
          angularRangeUpInjured.add(tmp);
          if (tmp > maxInjured) maxInjured = tmp;
      } /*else {
        angularRangeBackInjured
            .add(_getAngularRange(allMeasures[i].accelValues));
      }*/
    }

    //compute and register the scores
    if (angularRangeUpHealthy.length ==
            angularRangeUpInjured
                .length /*&&
        angularRangeBackHealthy.length == angularRangeBackInjured.length*/
        ) {
      if (maxInjured < 0 || maxHealthy < 0) {
        throw Exception("Error in score calculation : negative results");
      }
      elevationInjured = maxInjured;
      elevationInjured = double.parse(elevationInjured.toStringAsFixed(3));
      elevationHealthy = maxHealthy;
      elevationHealthy = double.parse(elevationHealthy.toStringAsFixed(3));
    } else {
      throw Exception("Error in score calculation : not same number of repetition on both side");
    }
  }

  double _getAngularRange(List<List<double>> values) {
    if (values.isEmpty) {
      throw Exception("Error in score calculation : getAngularRange");
    }
    const int X = 0;
    const int Y = 1;
    const int Z = 2;

    final normAcc = <double>[];
    double mNormAcc;
    double mAngleDegree;

    double angularRange;

    for (int i = 0; i < values.length; i++) {
      if (values[i].length != 3) {
        throw Exception(
            "Error in score calculation : getAngularRange error in values access");
      }
      mNormAcc = sqrt(values[i][X] * values[i][X] +
          values[i][Y] * values[i][Y] +
          values[i][Z] * values[i][Z]);
      normAcc.add(mNormAcc);
    }

    if (normAcc.isEmpty || normAcc[0] == 0) {
      throw Exception("Angle score : error in normAcc 1");
    }
    double maxAngle = _degrees(acos(values[0][Y] / normAcc[0]));
    double minAngle = _degrees(acos(values[0][Y] / normAcc[0]));

    for (int j = 0; j < normAcc.length; j++) {
      if (values[j].length != 3) {
        throw Exception(
            "Error in score calculation : getAngularRange error in values access");
      }
      if (normAcc[j] == 0) {
        throw Exception("Angle score : error in normAcc 2");
      }
      mAngleDegree = _degrees(acos(values[j][Y] / normAcc[j]));
      if (maxAngle < mAngleDegree) maxAngle = mAngleDegree;
      if (minAngle > mAngleDegree) minAngle = mAngleDegree;
    }

    angularRange = maxAngle - minAngle;

    return angularRange;
  }

  double _degrees(double radians) => radians * 180.0 / pi;
}
