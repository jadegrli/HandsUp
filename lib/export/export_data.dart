import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:hands_up/models/repetition.dart';
import 'package:hands_up/repositories/repetition_repository.dart';
import 'package:hands_up/repositories/score_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/patient.dart';
import '../models/score.dart';
import '../repositories/patient_repository.dart';

class ExportDataBloc {
  final _patientRepository = PatientRepository();
  final _scoreRepository = ScoreRepository();
  final _repetitionRepository = RepetitionRepository();



  /// create a folder at app root and return its name
  static Future<String> _createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  export(int patientId) async {
    List<Patient> patientList = await _patientRepository.getPatientById(id: patientId);
    Patient patient = patientList.first;
    List<Score> scoresList = await _scoreRepository.getScoreByPatientId(id: patientId);

    String patientFolderName = "${patient.name}_${patient.firstName}";

    await _createFolderInAppDocDir(patientFolderName);

    for (int i = 0; i < scoresList.length; ++i) {
      String folderScore = await _createFolderInAppDocDir("$patientFolderName/score$i");
      List<List<String>> data = [
        [
          "Patient name",
          "Patient first name",
          "creationDate",
          "B-B Score",
          "Elevation angle healthy",
          "Elevation angle injured",
          "notes"
        ],
        [
          patient.name,
          patient.firstName,
          scoresList[i].creationDate,
          scoresList[i].bbScore.toString(),
          scoresList[i].elevationAngleHealthy.toString(),
          scoresList[i].elevationAngleInjured.toString(),
          scoresList[i].notes
        ],
      ];
      String csvData = const ListToCsvConverter().convert(data);
      final path = "$folderScore/csv-${scoresList[i].creationDate}.csv";
      final File file = File(path);
      await file.writeAsString(csvData);

      List<Repetition> repetitionList = await _repetitionRepository.getRepetitionsByScoreId(id: scoresList[i].id!);
      List<List<String>> data2 = [
        ["No",
          "RangeAccBackCoordX",
          "RangeAccBackCoordY",
          "RangeAccBackCoordZ",
          "RangeAccUpCoordX",
          "RangeAccUpCoordY",
          "RangeAccUpCoordZ",
          "RangeGyroBackCoordX",
          "RangeGyroBackCoordY",
          "RangeGyroBackCoordZ",
          "RangeGyroUpCoordX",
          "RangeGyroUpCoordY",
          "RangeGyroUpCoordZ",
          "RangeAngularUp",
          "isHealthy",
        ]
      ];
      for (int i = 0; i < repetitionList.length; ++i) {
        List<String> tmp = [
          "${i+1}",
          repetitionList[i].rangeAccBackCoordX.toString(),
          repetitionList[i].rangeAccBackCoordY.toString(),
          repetitionList[i].rangeAccBackCoordZ.toString(),
          repetitionList[i].rangeAccUpCoordX.toString(),
          repetitionList[i].rangeAccUpCoordY.toString(),
          repetitionList[i].rangeAccUpCoordZ.toString(),
          repetitionList[i].rangeGyroBackCoordX.toString(),
          repetitionList[i].rangeGyroBackCoordY.toString(),
          repetitionList[i].rangeGyroBackCoordZ.toString(),
          repetitionList[i].rangeGyroUpCoordX.toString(),
          repetitionList[i].rangeGyroUpCoordY.toString(),
          repetitionList[i].rangeGyroUpCoordZ.toString(),
          repetitionList[i].rangeAngularUp.toString(),
          repetitionList[i].isHealthy.toString(),
        ];
        data2.add(tmp);
      }
      String csvData2 = const ListToCsvConverter().convert(data2);
      final path2 = "$folderScore/csv-repetitions_score_${scoresList[i].creationDate}.creationDate}.csv";
      final File file2 = File(path2);
      await file2.writeAsString(csvData2);
    }

    //zip folder
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder = Directory('${_appDocDir.path}/$patientFolderName/');
    print("test");
    var encoder = ZipFileEncoder();
    encoder.create('${_appDocDir.path}/$patientFolderName/$patientFolderName.zip');
    encoder.addDirectory(_appDocDirFolder);
    encoder.close();

    //share file
    Share.shareFiles(['${_appDocDirFolder.path}/$patientFolderName.zip'], text: 'All scores for patient');
   // _appDocDirFolder.deleteSync(recursive: true);
  }

}
