
import 'dart:async';

import '../models/repetition.dart';
import '../repositories/repetition_repository.dart';



class DataBaseBlocRepetition {
  final _repetitionRepository = RepetitionRepository();

  final _controller = StreamController<List<Repetition>>.broadcast();

  get data => _controller.stream;

  getAllRepetitions() async {
    _controller.sink.add(await _repetitionRepository.getAllRepetitions());
  }

  getRepetitionsByScoreId(int id) async {
    _controller.sink
        .add(await _repetitionRepository.getRepetitionsByScoreId(id: id));
  }

  addRepetition(Repetition repetition) async {
    await _repetitionRepository.insertRepetition(repetition);
  }

  deleteRepetitionById(int id) async {
    _repetitionRepository.deleteRepetitionById(id);
  }

  dispose() {
    _controller.close();
  }

}
