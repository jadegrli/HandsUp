import 'dart:async';

import '../models/score.dart';
import '../repositories/score_repository.dart';


class DataBaseBlocScore {
  final _scoreRepository = ScoreRepository();

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
