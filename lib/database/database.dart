import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const patientTABLE = 'Patient';
const scoreTABLE = 'Score';
const repetitionTABLE = 'Repetition';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  late Database _database;

  Future<Database> get database async {
    _database = await createDatabase();

    return _database;
  }

  _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //"HandsUp.db" is our database instance name
    String path = join(documentsDirectory.path, "HandsUp.db");

    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade, onConfigure: _onConfigure);
    return database;
  }

  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }

  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $patientTABLE ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "name TEXT, "
        "firstName TEXT, "
        "dateOfBirth TEXT, "
        "email TEXT, "
        "creationDate TEXT, "
        "notes TEXT, "
        "healthCondition TEXT, "
        "otherPathology TEXT, "
        "isRightReferenceOrHealthy INTEGER"
        ")");

    await database.execute("CREATE TABLE $scoreTABLE ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "creationDate TEXT, "
        "ElevationAngleInjured REAL, "
        "ElevationAngleHealthy REAL, "
        "BBScore REAL, "
        "notes TEXT, "
        "isExcluded INTEGER, "
        "Patient_id INTEGER,"
        "FOREIGN KEY (Patient_id) REFERENCES $patientTABLE(id) ON DELETE CASCADE"
        ")");

    await database.execute("CREATE TABLE $repetitionTABLE ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "RangeAccBackCoordX REAL, "
        "RangeAccBackCoordY REAL, "
        "RangeAccBackCoordZ REAL, "
        "RangeAccUpCoordX REAL, "
        "RangeAccUpCoordY REAL, "
        "RangeAccUpCoordZ REAL, "
        "RangeGyroBackCoordX REAL, "
        "RangeGyroBackCoordY REAL, "
        "RangeGyroBackCoordZ REAL, "
        "RangeGyroUpCoordX REAL, "
        "RangeGyroUpCoordY REAL, "
        "RangeGyroUpCoordZ REAL, "
        "RangeAngularUp REAL, "
        "isHealthy INTEGER, "
        "Score_id INTEGER,"
        "FOREIGN KEY (Score_id) REFERENCES $scoreTABLE(id) ON DELETE CASCADE"
        ")");
  }
}
