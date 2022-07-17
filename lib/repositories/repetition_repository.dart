import '../dao/repetition_dao.dart';
import '../models/repetition.dart';

class RepetitionRepository {
  final repetitionDao = RepetitionDao();

  Future getRepetitionsByScoreId({required int id}) =>
      repetitionDao.getRepetitionFromScoreID(id: id);

  Future getAllRepetitions() => repetitionDao.getAllRepetitions();

  Future insertRepetition(Repetition repetition) =>
      repetitionDao.createRepetition(repetition);

  Future deleteRepetitionById(int id) => repetitionDao.deleteRepetition(id);

  Future deleteRepetitionFromScoreId(int id) =>
      repetitionDao.deleteRepetitionFromScoreID(id);
}
