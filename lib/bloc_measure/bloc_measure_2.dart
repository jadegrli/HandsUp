
import 'dart:async';

import 'package:intl/intl.dart';

import '../bloc_database/db_bloc_score.dart';
import '../models/measure.dart';
import '../models/score.dart';
import '../repositories/sensors_repository.dart';
import '../score_calculation/angle_score_live.dart';
import '../score_calculation/p_score_live.dart';

class MeasureBloc2  {
  final SensorsRepository sensorsRepository = SensorsRepository();

  final _measureController = StreamController<MeasureStates>();

  get measurePhase => _measureController.stream;

  final midRangesAcc = <List<double>>[];
  final midRangesGyro = <List<double>>[];

  final allRangesAcc = <List<double>>[];
  final allRangesGyro = <List<double>>[];

  double bbScore = 0;
  double elevationAngleHealthy = 0;
  double elevationAngleInjured = 0;

  final DataBaseBlocScore blocScore = DataBaseBlocScore();


  static bool isCanceled = false;


  MeasureBloc2() {
    _measureController.sink.add(StateReady([], [], [], 0));
  }


  launchSide(int nbRepetition, int movementDuration, bool firstSide) async {
    _measureController.sink.add(StateLoading([], [], [], 0));
    sensorsRepository.initSensor();
    for (int i = 0; i < nbRepetition; ++i) {
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([], [], [], 0));
        return;
      }
      _measureController.sink.add(StateRest([], [], [], 0));
      await Future.delayed(Duration(seconds: movementDuration), () {});
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([], [], [], 0));
        return;
      }
      _measureController.sink.add(StateHandBack([], [], [], 0));
      await sensorsRepository.sensorsMeasure(movementDuration);
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([], [], [], 0));
        return;
      }
      _measureController.sink.add(StateRest([], [], [], 0));
      await Future.delayed(Duration(seconds: movementDuration), () {});
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([], [], [], 0));
        return;
      }
      _measureController.sink.add(StateHandUp([], [], [], 0));
      await sensorsRepository.sensorsMeasure(movementDuration);
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([], [], [], 0));
        return;
      }
    }
    _measureController.sink.add(StateLoading([], [], [], 0));
    if (firstSide) {
      int error = midResult(List.from(sensorsRepository.sensorsValues), nbRepetition);
      _measureController.sink.add(StateAllMeasuresFirstSide(midRangesAcc, midRangesGyro, [], error));
    } else {
      int error2 = finalResult(List.from(sensorsRepository.sensorsValues), nbRepetition);
      _measureController.sink.add(StateAllMeasuresSecondSide([], [], [bbScore, elevationAngleHealthy, elevationAngleInjured], error2));
    }
  }

  saveToDataBase(int patientID) async {
    _measureController.sink.add(StateLoading([], [], [], 0));
    final newScore = patientID == 0
        ? Score(
        creationDate: DateFormat("yyyy-MM-dd")
            .format(DateTime.now()),
        elevationAngleInjured: elevationAngleInjured,
        elevationAngleHealthy: elevationAngleHealthy,
        bbScore: bbScore,
        notes: "")
        : Score(
        creationDate: DateFormat("yyyy-MM-dd")
            .format(DateTime.now()),
        elevationAngleInjured: elevationAngleInjured,
        elevationAngleHealthy: elevationAngleHealthy,
        bbScore: bbScore,
        patientId: patientID,
        notes: "");

    await blocScore.addScoreWithRepetition(
        newScore,
        List.from(allRangesAcc),
        List.from(allRangesGyro),
        elevationAngleInjured,
        elevationAngleHealthy);

    endMeasure();
  }

  midResult(List<Measure> measure, int nbRepetition) {
    final score = PScoreLive(allMeasures: measure);
    int errorType = 0;

    if (nbRepetition * 2 == measure.length) {
      try {
        for (int i = 0; i < nbRepetition * 2; i++) {
          midRangesAcc.add(score.getRanges(measure[i].accelValues));
          midRangesGyro.add(score.getRanges(measure[i].gyroValues));
        }
      } catch (exception) {
        errorType = 1; //error in ranges calculation
      }
    } else {
      errorType = 2; //error in data
    }
    return errorType;
  }

  finalResult(List<Measure> measures, int nbRepetition) {
    int errorType = 0;
    if (nbRepetition * 4 == measures.length) {
      try {
        final mpScoreLive = PScoreLive(allMeasures: measures);
        for (int i = 0; i < nbRepetition * 4; i++) {
          allRangesAcc.add(mpScoreLive.getRanges(measures[i].accelValues));
          allRangesGyro.add(mpScoreLive.getRanges(measures[i].gyroValues));
        }
        mpScoreLive.computeScore();
        bbScore = mpScoreLive.bbScore;
        final mAngleScoreLive = AngleScoreLive(allMeasures: measures);
        mAngleScoreLive.computeScore();
        elevationAngleInjured = mAngleScoreLive.elevationInjured;
        elevationAngleHealthy = mAngleScoreLive.elevationHealthy;
      } catch (exception) {
        errorType = 1;
      }
    } else {
      errorType = 2;
    }
    return errorType;
  }

  cancelMeasure() {
    isCanceled = true;
    //throw loading state of canceling
    _measureController.sink.add(StateAllMeasuresLoadingOfCancel([], [], [], 0));
  }

  endMeasure() async {
    sensorsRepository.reset();
    //isCanceled = false;
    midRangesAcc.clear();
    midRangesGyro.clear();
    allRangesAcc.clear();
    allRangesGyro.clear();
    bbScore = 0;
    elevationAngleHealthy = 0;
    elevationAngleInjured = 0;
    _measureController.sink.add(StateReady([], [], [], 0));
  }

  dispose() {
    _measureController.close();
  }

}



//STATES
abstract class MeasureStates {
  MeasureStates(this.allResultsAcc, this.allResultsGyro, this.values, this.error);
  final List<List<double>> allResultsAcc;
  final List<List<double>> allResultsGyro;
  final List<double> values;
  int error = 0;
}

class StateReady extends MeasureStates {
  StateReady(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);

}

class StateLoading extends MeasureStates {
  StateLoading(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateRest extends MeasureStates {
  StateRest(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateHandBack extends MeasureStates {
  StateHandBack(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateHandUp extends MeasureStates {
  StateHandUp(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateAllMeasuresFirstSide extends MeasureStates {
  StateAllMeasuresFirstSide(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);

}

class StateAllMeasuresSecondSide extends MeasureStates {
  StateAllMeasuresSecondSide(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateAllMeasuresLoadingOfCancel extends MeasureStates {
  StateAllMeasuresLoadingOfCancel(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}

class StateAllMeasuresCanceled extends MeasureStates {
  StateAllMeasuresCanceled(List<List<double>> allResultsAcc, List<List<double>> allResultsGyro, List<double> values, int error) : super(allResultsAcc, allResultsGyro, values, error);
}