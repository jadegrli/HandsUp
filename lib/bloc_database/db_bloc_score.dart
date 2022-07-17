import 'dart:async';

import '../models/repetition.dart';
import '../models/score.dart';
import '../repositories/repetition_repository.dart';
import '../repositories/score_repository.dart';


class DataBaseBlocScore {
  final _scoreRepository = ScoreRepository();
  final _repetitionRepository = RepetitionRepository();

  final _controller = StreamController<List<Score>>.broadcast();

  get data => _controller.stream;

  getAllScore() async {
    _controller.sink.add(await _scoreRepository.getAllScores());
  }

  getScoreByPatientId(int id) async {
    _controller.sink.add(await _scoreRepository.getScoreByPatientId(id: id));
  }

  getScoreWithNoPatient() async {
    _controller.sink.add(await _scoreRepository.getScoresWithNoPatient());
  }

  getScoreFromId(int id) async {
    _controller.sink.add(await _scoreRepository.getScoreFromId(id: id));
  }

  addScore(Score score) async {
    await _scoreRepository.insertScore(score);
  }

  addScoreWithRepetition(Score score, List<List<double>> allRangesAcc, List<List<double>> allRangesGyro,
      double elevationInjured, double elevationHealthy) async {
    List<int> id = await _scoreRepository.insertScore(score);

    for (int i = 0; i < allRangesAcc.length - 1; i += 2) {
      final newRepetition = Repetition(
          isHealthy: i < allRangesAcc.length ~/ 2,
          scoreId: id.first,
          rangeAngularUp:
          i < allRangesAcc.length ~/ 2 ? elevationHealthy : elevationInjured,
          rangeAccBackCoordX: allRangesAcc[i][0],
          rangeAccBackCoordY: allRangesAcc[i][1],
          rangeAccBackCoordZ: allRangesAcc[i][2],
          rangeGyroBackCoordX: allRangesGyro[i][0],
          rangeGyroBackCoordY: allRangesGyro[i][1],
          rangeGyroBackCoordZ: allRangesGyro[i][2],
          rangeAccUpCoordX: allRangesAcc[i + 1][0],
          rangeAccUpCoordY: allRangesAcc[i + 1][1],
          rangeAccUpCoordZ: allRangesAcc[i + 1][2],
          rangeGyroUpCoordX: allRangesGyro[i + 1][0],
          rangeGyroUpCoordY: allRangesGyro[i + 1][1],
          rangeGyroUpCoordZ: allRangesGyro[i + 1][2]);
      await addRepetition(newRepetition);
    }
  }

  addRepetition(Repetition repetition) async {
    await _repetitionRepository.insertRepetition(repetition);
  }


  updateScore(Score score) async {
    await _scoreRepository.updateScore(score);
  }

  deleteScoreById(int id) async {
    _scoreRepository.deleteScoreById(id);
    getAllScore();
  }

  dispose() {
    _controller.close();
  }
}
