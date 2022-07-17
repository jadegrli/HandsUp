
class Patient {
  static final columns = [
    "id",
    "name",
    "firstName",
    "dateOfBirth",
    "email",
    "creationDate",
    "notes",
    "healthCondition",
    "otherPathology",
    "isRightReferenceOrHealthy" 
  ];

  final int?
      id; //if we give a value to id at the initialization -> override autoincrement in database but make sure it doesn't already exist before
  final String name;
  final String firstName;
  final String dateOfBirth;
  final String email;
  final String notes;
  final String creationDate;
  final bool isRightReferenceOrHealthy;
  final String healthCondition;
  final String otherPathology;

  Patient(
      {this.id,
      required this.name,
      required this.firstName,
      required this.dateOfBirth,
      required this.email,
      required this.notes,
      required this.creationDate,
      required this.isRightReferenceOrHealthy,
      required this.healthCondition,
      required this.otherPathology});

  factory Patient.fromDatabaseJson(Map<String, dynamic> data) => Patient(
      id: data['id'],
      name: data['name'],
      firstName: data['firstName'],
      dateOfBirth: data['dateOfBirth'],
      email: data['email'],
      notes: data['notes'],
      creationDate: data['creationDate'],
      isRightReferenceOrHealthy: data['isRightReferenceOrHealthy'] == 0,
      healthCondition: data['healthCondition'],
      otherPathology: data['otherPathology']);

  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "name": name,
        "firstName": firstName,
        "dateOfBirth": dateOfBirth,
        "email": email,
        "notes": notes,
        "creationDate": creationDate,
        "isRightReferenceOrHealthy": isRightReferenceOrHealthy ? 1 : 0,
        "healthCondition": healthCondition,
        "otherPathology": otherPathology
      };

  Patient copy({
    int? id,
    String? name,
    String? firstName,
    String? dateOfBirth,
    String? email,
    String? notes,
    String? creationDate,
    bool? isRightReferenceOrHealthy,
    String? healthCondition,
    String? otherPathology,
  }) =>
      Patient(
        id: id ?? this.id,
        name: name ?? this.name,
        firstName: firstName ?? this.firstName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        creationDate: creationDate ?? this.creationDate,
        isRightReferenceOrHealthy:
        isRightReferenceOrHealthy ?? this.isRightReferenceOrHealthy,
        healthCondition: healthCondition ?? this.healthCondition,
        otherPathology: otherPathology ?? this.otherPathology,
      );
}
