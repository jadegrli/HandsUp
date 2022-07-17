import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/measure.dart';
import '../repositories/sensors_repository.dart';



class MeasureBloc extends Bloc<MeasureEvents, MeasureStates> {
  final SensorsRepository sensorsRepository = SensorsRepository();

  MeasureBloc() : super(StateReady()) {
    on<MeasureEvents>(_onEvent, transformer: sequential());
  }

  FutureOr<void> _onEvent(MeasureEvents event, Emitter<MeasureStates> emit) async {
    if (event is EventLaunchFirstSide) {
      emit(StateLoading());
      sensorsRepository.initSensor();
      for (int i = 0; i < event.nbRepetition; ++i) {
        emit(StateRest());
        await Future.delayed(Duration(seconds: event.movementDuration), () {});
        emit(StateHandBack());
        await sensorsRepository.sensorsMeasure(event.movementDuration);
        emit(StateRest());
        await Future.delayed(Duration(seconds: event.movementDuration), () {});
        emit(StateHandUp());
        await sensorsRepository.sensorsMeasure(event.movementDuration);
      }
      emit(StateAllMeasuresFirstSide(allMeasures: sensorsRepository.sensorsValues));
    } else if (event is EventLaunchSecondSide) {
      emit(StateLoading());
      sensorsRepository.initSensor();
      for (int i = 0; i < event.nbRepetition; ++i) {
        emit(StateRest());
        await Future.delayed(Duration(seconds: event.movementDuration), () {});
        emit(StateHandBack());
        await sensorsRepository.sensorsMeasure(event.movementDuration);
        emit(StateRest());
        await Future.delayed(Duration(seconds: event.movementDuration), () {});
        emit(StateHandUp());
        await sensorsRepository.sensorsMeasure(event.movementDuration);
      }
      emit(StateAllMeasuresSecondSide(allMeasures: sensorsRepository.sensorsValues));

    } else if (event is EventEnd) {
      sensorsRepository.reset();
      emit(StateReady());
    } else {
      emit(StateError());
    }
  }

}

//EVENTS
abstract class MeasureEvents {
  const MeasureEvents();
}

class EventLaunchFirstSide extends MeasureEvents {
  final int nbRepetition;
  final int movementDuration;
  const EventLaunchFirstSide({required this.nbRepetition, required this.movementDuration});
}

class EventLaunchSecondSide extends MeasureEvents {
  final int nbRepetition;
  final int movementDuration;
  const EventLaunchSecondSide({required this.nbRepetition, required this.movementDuration});
}

class EventEnd extends MeasureEvents {}


//STATES
abstract class MeasureStates {
  const MeasureStates();
}

class StateReady extends MeasureStates {}
class StateLoading extends MeasureStates {}
class StateRest extends MeasureStates {}
class StateHandBack extends MeasureStates {}
class StateHandUp extends MeasureStates {}
class StateError extends MeasureStates {}

class StateAllMeasuresFirstSide extends MeasureStates {
  final List<Measure> allMeasures;
  const StateAllMeasuresFirstSide({required this.allMeasures});
}

class StateAllMeasuresSecondSide extends MeasureStates {
  final List<Measure> allMeasures;
  const StateAllMeasuresSecondSide({required this.allMeasures});
}
