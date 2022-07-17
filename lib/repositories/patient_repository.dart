import '../dao/patient_dao.dart';
import '../models/patient.dart';

class PatientRepository {
  final patientDao = PatientDao();

  Future getPatientById({required int id}) => patientDao.getPatientFromId(id: id);

  Future getPatientsByName({required String query}) => patientDao.getPatientsByName(query: query);

  Future getAllPatients() => patientDao.getAllPatients();

  Future insertPatient(Patient patient) => patientDao.createPatient(patient);

  Future updatePatient(Patient patient) => patientDao.updatePatient(patient);

  Future deletePatientById(int id) => patientDao.deletePatient(id);

}