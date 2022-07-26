import 'dart:async';

import '../models/patient.dart';
import '../repositories/patient_repository.dart';


class DataBaseBlocPatient {
  final _patientRepository = PatientRepository();

  final _controller = StreamController<List<Patient>>.broadcast();

  get data => _controller.stream;


  DataBaseBlocPatient() {
    getAllPatients();
  }

  getAllPatients() async {
    List<Patient> list = await _patientRepository.getAllPatients();
    list.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    list = sortByFirstNameWhenSameName(list);
    _controller.sink.add(list);
  }

  List<Patient> sortByFirstNameWhenSameName(List<Patient> list) {
    var tmp = <Patient>[];
    var result = <Patient>[];
    int counter = 0;
    for (int i = 0; i < list.length; ++i) {
      tmp.add(list[i]);
      for (int j = i + 1; j < list.length; ++j) {
        if (list[i].name == list[j].name) {
          tmp.add(list[j]);
          counter++;
        } else {
            break;
        }
      }

      tmp.sort((a, b) => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));
      result.addAll(tmp);
      tmp.clear();
      i += counter;
      counter = 0;
    }
    return result;
  }

  getAllPatientsZA() async {
    List<Patient> list = await _patientRepository.getAllPatients();
    list.sort((a,b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    list = sortByFirstNameWhenSameName(list);
    _controller.sink.add(list);
    //_controller.sink.add(await _patientRepository.getAllPatients());
  }

  getAllPatientPathology(String pathology) async {
    List<Patient> list = await _patientRepository.getAllPatients();
    List<Patient> listPatholgy = list.where((i) => i.healthCondition == pathology).toList();
    _controller.sink.add(listPatholgy);
  }

  getPatientsByName({required String query}) async {
    _controller.sink
        .add(await _patientRepository.getPatientsByName(query: query));
  }

  updatePatient(Patient patient) async {
    await _patientRepository.updatePatient(patient);
    getPatientByID(id: patient.id!);
  }

  getPatientByID({required int id}) async {
    _controller.sink.add(await _patientRepository.getPatientById(id: id));
  }

  addPatient(Patient patient) async {
    await _patientRepository.insertPatient(patient);
    getAllPatients();
  }

  deletePatientById(int id) async {
    await _patientRepository.deletePatientById(id);
    getAllPatients();
  }

  dispose() {
    _controller.close();
  }
}
