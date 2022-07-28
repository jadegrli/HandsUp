import 'dart:async';

import '../database/database.dart';
import '../models/repetition.dart';


class RepetitionDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createRepetition(Repetition repetition) async {
    final db = await dbProvider.database;
    final id = await db.insert(repetitionTABLE, repetition.toDatabaseJson());
    repetition.copy(id: id);
    return id;
  }

  Future<List<Repetition>> getAllRepetitions() async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(repetitionTABLE,
        columns: Repetition.columns,
        orderBy:
            "id ASC");

    List<Repetition> repetitionsList = result.isNotEmpty
        ? result.map((item) => Repetition.fromDatabaseJson(item)).toList()
        : [];
    return repetitionsList;
  }

  Future<List<Repetition>> getRepetitionFromScoreID({required int id}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(repetitionTABLE,
        columns: Repetition.columns, where: 'Score_id = ? ', whereArgs: [id]);

    List<Repetition> repetitionsList = result.isNotEmpty
        ? result.map((item) => Repetition.fromDatabaseJson(item)).toList()
        : [];
    return repetitionsList;
  }

  Future<int> deleteRepetitionFromScoreID(int id) async {
    final db = await dbProvider.database;
    var result = await db
        .delete(repetitionTABLE, where: 'Score_id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> deleteRepetition(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(repetitionTABLE, where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
