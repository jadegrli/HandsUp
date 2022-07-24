
import 'dart:async';

import '../models/measure.dart';
import '../repositories/sensors_repository.dart';
import '../score_calculation/p_score_live.dart';

class MeasureBloc2  {
  final SensorsRepository sensorsRepository = SensorsRepository();

  final _measureController = StreamController<MeasureStates>();

  get measurePhase => _measureController.stream;

  //CancelableOperation? _myCancelableFuture;

  static bool isCanceled = false;

  cancelMeasure() {
    isCanceled = true;
    //throw loading state of canceling
    _measureController.sink.add(StateAllMeasuresLoadingOfCancel([]));
  }


 /* launchController(int nbRepetition, int movementDuration, bool firstSide) async {
    _myCancelableFuture = CancelableOperation.fromFuture(
      _launchSide(nbRepetition, movementDuration, firstSide),
      onCancel: () => () {
        print("CANCELED FUTURE");
        text = "bruh";
      },
    );
  }*/

  endMeasure() async {
    //await _myCancelableFuture!.cancel();
    sensorsRepository.reset();
    isCanceled = false;
    _measureController.sink.add(StateReady([]));
  }

  MeasureBloc2() {
    _measureController.sink.add(StateReady([]));
  }


  launchSide(int nbRepetition, int movementDuration, bool firstSide) async {
    _measureController.sink.add(StateLoading([]));
    sensorsRepository.initSensor();
    for (int i = 0; i < nbRepetition; ++i) {
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([]));
        return;
      }
      _measureController.sink.add(StateRest([]));
      await Future.delayed(Duration(seconds: movementDuration), () {});
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([]));
        return;
      }
      _measureController.sink.add(StateHandBack([]));
      await sensorsRepository.sensorsMeasure(movementDuration);
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([]));
        return;
      }
      _measureController.sink.add(StateRest([]));
      await Future.delayed(Duration(seconds: movementDuration), () {});
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([]));
        return;
      }
      _measureController.sink.add(StateHandUp([]));
      await sensorsRepository.sensorsMeasure(movementDuration);
      if (isCanceled) {
        _measureController.sink.add(StateAllMeasuresCanceled([]));
        return;
      }
    }
    firstSide ? _measureController.sink.add(StateAllMeasuresFirstSide(List.from(sensorsRepository.sensorsValues))) :
    _measureController.sink.add(StateAllMeasuresSecondSide(List.from(sensorsRepository.sensorsValues)));
  }

  dispose() {
    _measureController.close();
  }

}

//STATES
abstract class MeasureStates {
  const MeasureStates(this.allMeasures);
  final List<Measure> allMeasures;
}

class StateReady extends MeasureStates {
  StateReady(List<Measure> allMeasures) : super(allMeasures);
}

class StateLoading extends MeasureStates {
  StateLoading(List<Measure> allMeasures) : super(allMeasures);
}

class StateRest extends MeasureStates {
  StateRest(List<Measure> allMeasures) : super(allMeasures);
}

class StateHandBack extends MeasureStates {
  StateHandBack(List<Measure> allMeasures) : super(allMeasures);
}

class StateHandUp extends MeasureStates {
  StateHandUp(List<Measure> allMeasures) : super(allMeasures);
}


class StateAllMeasuresFirstSide extends MeasureStates {
  StateAllMeasuresFirstSide(List<Measure> allMeasures) : super(allMeasures);
}

class StateAllMeasuresSecondSide extends MeasureStates {
  StateAllMeasuresSecondSide(List<Measure> allMeasures) : super(allMeasures);
}

class StateAllMeasuresLoadingOfCancel extends MeasureStates {
  StateAllMeasuresLoadingOfCancel(List<Measure> allMeasures) : super(allMeasures);
}

class StateAllMeasuresCanceled extends MeasureStates {
  StateAllMeasuresCanceled(List<Measure> allMeasures) : super(allMeasures);
}