import 'package:hands_up/score_calculation/score_live.dart';

import '../models/measure.dart';

class PScoreLive extends ScoreLive {
  PScoreLive({required List<Measure> allMeasures})
      : super(allMeasures: allMeasures);

  @override
  void computeScore() {
    //ranges pour les hand back Healthy
    final accRangeBackHealthy = <List<double>>[];
    final gyroRangeBackHealthy = <List<double>>[];
    //range pour les hand up healthy
    final accRangeUpHealthy = <List<double>>[];
    final gyroRangeUpHealthy = <List<double>>[];
    //range pour les hand back injured
    final accRangeBackInjured = <List<double>>[];
    final gyroRangeBackInjured = <List<double>>[];
    //range pour les hand up injured
    final accRangeUpInjured = <List<double>>[];
    final gyroRangeUpInjured = <List<double>>[];

    //met ensemble les acc et gyro de chaque mouvement côté Healthy
    final pRupHealthy = <double>[];
    final pRbackHealthy = <double>[];
    //met ensemble les acc et gyro de chaque mouvement côté Injured
    final pRupInjured = <double>[];
    final pRbackInjured = <double>[];

    //fais les ratios entre healthy et injured
    var deltaPrUp = <double>[];
    var deltaPrBack = <double>[];

    //somme les deltas de chaque répétition
    double pScoreUp = 0;
    double pScoreBack = 0;

    for (int i = 0; i < allMeasures.length ~/ 2; ++i) {
      if (i % 2 == 0) {
        //hand back
        accRangeBackHealthy.add(getRanges(allMeasures[i].accelValues));
        gyroRangeBackHealthy.add(getRanges(allMeasures[i].gyroValues));
      } else {
        //hand up
        accRangeUpHealthy.add(getRanges(allMeasures[i].accelValues));
        gyroRangeUpHealthy.add(getRanges(allMeasures[i].gyroValues));
      }
    }

    for (int i = allMeasures.length ~/ 2; i < allMeasures.length; ++i) {
      if (i % 2 == 0) {
        //hand back
        accRangeBackInjured.add(getRanges(allMeasures[i].accelValues));
        gyroRangeBackInjured.add(getRanges(allMeasures[i].gyroValues));
      } else {
        //hand up
        accRangeUpInjured.add(getRanges(allMeasures[i].accelValues));
        gyroRangeUpInjured.add(getRanges(allMeasures[i].gyroValues));
      }
    }

    if (accRangeUpHealthy.length == gyroRangeUpHealthy.length &&
        accRangeBackHealthy.length == gyroRangeBackHealthy.length &&
        accRangeUpHealthy.length == accRangeBackHealthy.length) {
      for (int i = 0; i < accRangeUpHealthy.length; i++) {
        pRupHealthy
            .add(_computePr(accRangeUpHealthy[i], gyroRangeUpHealthy[i]));
        pRbackHealthy
            .add(_computePr(accRangeBackHealthy[i], gyroRangeBackHealthy[i]));
        pRupInjured
            .add(_computePr(accRangeUpInjured[i], gyroRangeUpInjured[i]));
        pRbackInjured
            .add(_computePr(accRangeBackInjured[i], gyroRangeBackInjured[i]));
      }
    }

    //compute deltaPr for both movements
    deltaPrUp = _computeDeltaPr(pRupHealthy, pRupInjured);
    deltaPrBack = _computeDeltaPr(pRbackHealthy, pRbackInjured);

    //compute P scores
    if (deltaPrUp.length == deltaPrBack.length) {
      for (int i = 0; i < deltaPrUp.length; i++) {
        pScoreUp += deltaPrUp[i];
        pScoreBack += deltaPrBack[i];
      }

      if (deltaPrUp.isEmpty) {
        throw Exception("Error in score calculation : deltaPrUp is Empty");
      }
      upScore = 100 * pScoreUp / deltaPrUp.length;
      upScore = double.parse(upScore.toStringAsFixed(3));

      if (deltaPrBack.isEmpty) {
        throw Exception("Error in score calculation : deltaPrBack is Empty");
      }
      backScore = 100 * pScoreBack / deltaPrBack.length;
      backScore = double.parse(backScore.toStringAsFixed(3));
      bbScore = 16.71 + 0.32 * backScore + 0.45 * upScore;
      if (bbScore < 0) {
        throw Exception("Error in score calculation : negative result");
      }
      bbScore = double.parse(bbScore.toStringAsFixed(3));
    } else {
      throw Exception("Error in score calculation : not same number of repetition on both side");
    }
  }

  double _computePr(List<double> accRange, List<double> gyroRange) {
    double pR;
    pR = accRange[2] * gyroRange[0] +
        accRange[0] * gyroRange[1] +
        accRange[1] * gyroRange[2];
    return pR;
  }

  List<double> _computeDeltaPr(List<double> prHealthy, List<double> prInjured) {
    final deltaPr = <double>[];
    if (prHealthy.length == prHealthy.length) {
      for (int i = 0; i < prHealthy.length; i++) {
        if (prHealthy[i] == 0) {
          throw Exception("Error in score calculation : prHealthy is zero");
        }
        deltaPr.add(prInjured[i] / prHealthy[i]);
      }
    }
    return deltaPr;
  }
}
