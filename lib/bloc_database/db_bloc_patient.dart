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
    _controller.sink.add(await _patientRepository.getAllPatients());
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
