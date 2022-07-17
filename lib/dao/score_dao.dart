import 'dart:async';

import '../database/database.dart';
import '../models/score.dart';


class ScoreDao {
  final dbProvider = DatabaseProvider.dbProvider;

  //Adds new Score records
  Future<List<int>> createScore(Score score) async {
    final db = await dbProvider.database;
    final id = await db.insert(scoreTABLE, score.toDatabaseJson());
    score.copy(id: id);
    final list = <int>[];
    list.add(id);
    return list;
  }

  //FOR TESTS
  Future<List<Score>> getAllScores() async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result =
        await db.query(scoreTABLE, columns: Score.columns, orderBy: "id ASC");

    List<Score> scoreList = result.isNotEmpty
        ? result.map((item) => Score.fromDatabaseJson(item)).toList()
        : [];
    return scoreList;
  }

  Future<List<Score>> getScoreFromPatientID({required int id}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(scoreTABLE,
        columns: Score.columns, where: 'Patient_id = ? ', whereArgs: [id], orderBy: "id ASC");

    List<Score> scoresList = result.isNotEmpty
        ? result.map((item) => Score.fromDatabaseJson(item)).toList()
        : [];
    return scoresList;
  }

  Future<List<Score>> getScoreFromId({required int id}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(scoreTABLE,
        columns: Score.columns, where: 'id = ? ', whereArgs: [id]);

    List<Score> scoresList = result.isNotEmpty
        ? result.map((item) => Score.fromDatabaseJson(item)).toList()
        : [];
    return scoresList;
  }

  Future<List<Score>> getScoresWithNoPatient() async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(scoreTABLE,
        columns: Score.columns, where: 'HasPatient = ? ', whereArgs: ["0"]);

    List<Score> scoresList = result.isNotEmpty
        ? result.map((item) => Score.fromDatabaseJson(item)).toList()
        : [];
    return scoresList;
  }

  Future<int> updateScore(Score score) async {
    final db = await dbProvider.database;
    var result = await db.update(scoreTABLE, score.toDatabaseJson(),
        where: "id = ?", whereArgs: [score.id]);
    return result;
  }

  Future<int> deleteScore(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(scoreTABLE, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteScoreFromPatientID(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(scoreTABLE, where: 'Patient_id = ?', whereArgs: [id]);
    return result;
  }
}
