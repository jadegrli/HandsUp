import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

import '../models/measure.dart';



class SensorsRepository {

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final accelValuesTab = <List<double>>[];
  final gyroValuesTab = <List<double>>[];
  final sensorsValues = <Measure>[];

  Future<void> sensorsMeasure(int nbSeconds) async {
    await _runSensors(nbSeconds);
    sensorsValues.add(Measure(accelValues: List.from(accelValuesTab), gyroValues: List.from(gyroValuesTab)));
  }

  Future<void> _runSensors(int nbSeconds) async {
    if (!_streamSubscriptions.first.isPaused) {
      _streamSubscriptions.first.pause();
    }
    if (!_streamSubscriptions.last.isPaused) {
      _streamSubscriptions.last.pause();
    }
    _clearAcc();
    _clearGyro();
    _streamSubscriptions.first.resume();
    _streamSubscriptions.last.resume();

    return Future.delayed(Duration(seconds: nbSeconds), () {
      _streamSubscriptions.first.pause();
      _streamSubscriptions.last.pause();
    });
  }

  void initSensor() {
    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        _addValToTabAcc(event);
      }),
    );

    _streamSubscriptions.add(
      gyroscopeEvents.listen((GyroscopeEvent event) {
        _addValToTabGyro(event);
      }),
    );

    _streamSubscriptions.first.pause();
    _streamSubscriptions.last.pause();
    _clearAcc();
    _clearGyro();
  }

  // add triplet values from acc sensors to the tab
  void _addValToTabAcc(AccelerometerEvent event) {
    //crée une liste de double par exemple [1.2, 4.4, 3.0]
    double valX = double.parse((event.x).toStringAsFixed(3));
    double valY = double.parse((event.y).toStringAsFixed(3));
    double valZ = double.parse((event.z).toStringAsFixed(3));
    accelValuesTab.add(<double>[valX, valY, valZ]);
  }

  //erase all values from acc sensor values tab
  void _clearAcc() {
    accelValuesTab.clear();
  }
  // add triplet values from gyro sensors to the tab
  void _addValToTabGyro(GyroscopeEvent event) {
    //crée une liste de double par exemple [1.2, 4.4, 3.0]
    double valX = double.parse((event.x).toStringAsFixed(3));
    double valY = double.parse((event.y).toStringAsFixed(3));
    double valZ = double.parse((event.z).toStringAsFixed(3));
    gyroValuesTab.add(<double>[valX, valY, valZ]);
  }

  //erase all values from gyro sensor values tab
  void _clearGyro() {
    gyroValuesTab.clear();
  }

  void reset() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _clearAcc();
    _clearGyro();
    sensorsValues.clear();
  }

}
