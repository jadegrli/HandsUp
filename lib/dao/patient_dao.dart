import 'dart:async';

import '../database/database.dart';
import '../models/patient.dart';

class PatientDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createPatient(Patient patient) async {
    final db = await dbProvider.database;
    //returns the ID of the created patient
    final id = await db.insert(patientTABLE, patient.toDatabaseJson());
    patient.copy(id: id);
    return id;
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    result = await db.query(patientTABLE,
        columns: Patient.columns,
        orderBy:
            "name ASC");

    List<Patient> patientsList = result.isNotEmpty
        ? result.map((item) => Patient.fromDatabaseJson(item)).toList()
        : [];
    return patientsList;
  }

  Future<List<Patient>> getPatientsByName({required String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result = [];
    //an empty String will return all the patients in database
    if (query.isNotEmpty) {
      result = await db.query(patientTABLE,
          columns: Patient.columns,
          where: 'name LIKE ? ',
          whereArgs: ["%$query%"],
          orderBy: "name ASC");
    } else {
      result = await db.query(patientTABLE,
          columns: Patient.columns,
          orderBy:
              "name ASC");
    }

    List<Patient> patientsList = result.isNotEmpty
        ? result.map((item) => Patient.fromDatabaseJson(item)).toList()
        : [];
    return patientsList;
  }

  Future<List<Patient>> getPatientFromId({required int id}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result = [];
    result = await db.query(patientTABLE,
        columns: Patient.columns,
        where: 'id = ? ',
        whereArgs: [id],
        orderBy: "name ASC");

    List<Patient> patientsList = result.isNotEmpty
        ? result.map((item) => Patient.fromDatabaseJson(item)).toList()
        : [];
    return patientsList;
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await dbProvider.database;

    var result = await db.update(patientTABLE, patient.toDatabaseJson(),
        where: "id = ?", whereArgs: [patient.id]);

    return result;
  }

  Future<int> deletePatient(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(patientTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
