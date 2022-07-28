class Score {
  static final columns = [
    "id",
    "ElevationAngleInjured",
    "ElevationAngleHealthy",
    "BBScore",
    "creationDate",
    "isExcluded",
    "notes",
    "Patient_id",
  ];

  final int? id;
  final String creationDate;
  final double elevationAngleInjured;
  final double elevationAngleHealthy;
  final double bbScore;
  final String notes;
  final int? patientId;
  final bool isExcluded;

  Score(
      {this.id,
      this.patientId,
      required this.isExcluded,
      required this.creationDate,
      required this.elevationAngleInjured,
      required this.elevationAngleHealthy,
      required this.bbScore,
      required this.notes});

  factory Score.fromDatabaseJson(Map<String, dynamic> data) => Score(
      id: data['id'],
      creationDate: data['creationDate'],
      elevationAngleInjured: data['ElevationAngleInjured'],
      elevationAngleHealthy: data['ElevationAngleHealthy'],
      notes: data['notes'],
      isExcluded: data['isExcluded'] == 1,
      patientId: data["Patient_id"],
      bbScore: data['BBScore']);

  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "creationDate": creationDate,
        "ElevationAngleInjured": elevationAngleInjured,
        "ElevationAngleHealthy": elevationAngleHealthy,
        "BBScore": bbScore,
        "notes": notes,
        "isExcluded": isExcluded == true ? 1 : 0,
        "Patient_id": patientId,
      };

  Score copy({
    int? id,
    String? creationDate,
    double? elevationAngleInjured,
    double? elevationAngleHealthy,
    double? bbScore,
    String? notes,
    bool? isExcluded,
    int? patientId,
  }) =>
      Score(
        id: id ?? this.id,
        isExcluded: isExcluded ?? this.isExcluded,
        creationDate: creationDate ?? this.creationDate,
        elevationAngleInjured:
            elevationAngleInjured ?? this.elevationAngleInjured,
        elevationAngleHealthy:
            elevationAngleHealthy ?? this.elevationAngleHealthy,
        bbScore: bbScore ?? this.bbScore,
        notes: notes ?? this.notes,
        patientId: patientId ?? this.patientId,
      );
}
