import '../dao/score_dao.dart';
import '../models/score.dart';

class ScoreRepository {
  final scoreDao = ScoreDao();

  Future getScoreByPatientId({required int id}) =>
      scoreDao.getScoreFromPatientID(id: id);

  Future getScoreByPatientIdExcluded({required int id}) =>
    scoreDao.getScoreFromPatientIDExcluded(id: id);

  Future getScoreFromId({required int id}) => scoreDao.getScoreFromId(id: id);

  Future getAllScores() => scoreDao.getAllScores();

  Future getScoresWithNoPatient() => scoreDao.getScoresWithNoPatient();

  Future insertScore(Score score) => scoreDao.createScore(score);

  Future updateScore(Score score) => scoreDao.updateScore(score);

  Future deleteScoreById(int id) => scoreDao.deleteScore(id);

  Future deleteScoreFromPatientId(int id) =>
      scoreDao.deleteScoreFromPatientID(id);
}
