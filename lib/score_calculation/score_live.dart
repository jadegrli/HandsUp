import '../models/measure.dart';

abstract class ScoreLive {
  final List<Measure> allMeasures;

  double upScore = 0;
  double backScore = 0;
  double bbScore = 0;
  double elevationInjured = 0;
  double elevationHealthy = 0;

  ScoreLive({required this.allMeasures});

  void computeScore();

  List<double> getRanges(List<List<double>> values) {
    final getRanges = List<double>.filled(3, 0);

    if (values.isEmpty) {
      throw Exception("Error in score calculation : getRanges");
    }

    const int X = 0;
    const int Y = 1;
    const int Z = 2;

    if (values[0].length != 3) {
      throw Exception(
          "Error in score calculation : getRanges error in values access 1");
    }

    double minX = values[0][X];
    double minY = values[0][Y];
    double minZ = values[0][Z];

    double maxX = values[0][X];
    double maxY = values[0][Y];
    double maxZ = values[0][Z];

    for (int i = 0; i < values.length; i++) {
      if (values[i].length != 3) {
        throw Exception(
            "Error in score calculation : getRanges error in values access 2");
      }

      if (values[i][X] < minX) minX = values[i][X];
      if (values[i][Y] < minY) minY = values[i][Y];
      if (values[i][Z] < minZ) minZ = values[i][Z];

      if (values[i][X] > maxX) maxX = values[i][X];
      if (values[i][Y] > maxY) maxY = values[i][Y];
      if (values[i][Z] > maxZ) maxZ = values[i][Z];
    }
    getRanges[0] = maxX - minX;
    getRanges[1] = maxY - minY;
    getRanges[2] = maxZ - minZ;

    return getRanges;
  }
}
