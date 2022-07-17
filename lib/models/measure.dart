
class Measure {
  final List<List<double>> accelValues;
  final List<List<double>> gyroValues;

  Measure({required this.accelValues, required this.gyroValues});

  List<List<double>> getGyroValues() => gyroValues;
  List<List<double>> getAccelValues() => accelValues;

  @override
  String toString() {
    return 'Measure{accelValues: $accelValues, gyroValues: $gyroValues}';
  }

  Measure copyWith(
    List<List<double>>? accelValues,
    List<List<double>>? gyroValues,
  ) =>
      Measure(
        accelValues: accelValues ?? this.accelValues,
        gyroValues: gyroValues ?? this.gyroValues,
      );
}
