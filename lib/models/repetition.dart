class Repetition {
  static final columns = [
    "id",
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
    "Score_id"
  ];

  final int? id;
  final bool isHealthy;
  final int scoreId;
  final double rangeAngularUp;
  final double rangeAccBackCoordX;
  final double rangeAccBackCoordY;
  final double rangeAccBackCoordZ;
  final double rangeGyroBackCoordX;
  final double rangeGyroBackCoordY;
  final double rangeGyroBackCoordZ;
  final double rangeAccUpCoordX;
  final double rangeAccUpCoordY;
  final double rangeAccUpCoordZ;
  final double rangeGyroUpCoordX;
  final double rangeGyroUpCoordY;
  final double rangeGyroUpCoordZ;

  Repetition({
    this.id,
    required this.isHealthy,
    required this.scoreId,
    required this.rangeAngularUp,
    required this.rangeAccBackCoordX,
    required this.rangeAccBackCoordY,
    required this.rangeAccBackCoordZ,
    required this.rangeGyroBackCoordX,
    required this.rangeGyroBackCoordY,
    required this.rangeGyroBackCoordZ,
    required this.rangeAccUpCoordX,
    required this.rangeAccUpCoordY,
    required this.rangeAccUpCoordZ,
    required this.rangeGyroUpCoordX,
    required this.rangeGyroUpCoordY,
    required this.rangeGyroUpCoordZ,
  });

  factory Repetition.fromDatabaseJson(Map<String, dynamic> data) => Repetition(
        id: data['id'],
        isHealthy: data['isHealthy'] == 0,
        scoreId: data['Score_id'],
        rangeAngularUp: data['RangeAngularUp'],
        rangeAccBackCoordX: data['RangeAccBackCoordX'],
        rangeAccBackCoordY: data['RangeAccBackCoordY'],
        rangeAccBackCoordZ: data['RangeAccBackCoordZ'],
        rangeGyroBackCoordX: data['RangeGyroBackCoordX'],
        rangeGyroBackCoordY: data['RangeGyroBackCoordY'],
        rangeGyroBackCoordZ: data['RangeGyroBackCoordZ'],
        rangeAccUpCoordX: data['RangeAccUpCoordX'],
        rangeAccUpCoordY: data['RangeAccUpCoordY'],
        rangeAccUpCoordZ: data['RangeAccUpCoordZ'],
        rangeGyroUpCoordX: data['RangeGyroUpCoordX'],
        rangeGyroUpCoordY: data['RangeGyroUpCoordY'],
        rangeGyroUpCoordZ: data['RangeGyroUpCoordZ'],
      );

  Map<String, dynamic> toDatabaseJson() => {
        "id": id,
        "isHealthy": isHealthy,
        "Score_id": scoreId,
        "RangeAngularUp": rangeAngularUp,
        "RangeAccBackCoordX": rangeAccBackCoordX,
        "RangeAccBackCoordY": rangeAccBackCoordY,
        "RangeAccBackCoordZ": rangeAccBackCoordZ,
        "RangeGyroBackCoordX": rangeGyroBackCoordX,
        "RangeGyroBackCoordY": rangeGyroBackCoordY,
        "RangeGyroBackCoordZ": rangeGyroBackCoordZ,
        "RangeAccUpCoordX": rangeAccUpCoordX,
        "RangeAccUpCoordY": rangeAccUpCoordY,
        "RangeAccUpCoordZ": rangeAccUpCoordZ,
        "RangeGyroUpCoordX": rangeGyroUpCoordX,
        "RangeGyroUpCoordY": rangeGyroUpCoordY,
        "RangeGyroUpCoordZ": rangeGyroUpCoordZ,
      };

  Repetition copy({
    int? id,
    bool? isHealthy,
    int? scoreId,
    double? rangeAngularUp,
    double? rangeAccBackCoordX,
    double? rangeAccBackCoordY,
    double? rangeAccBackCoordZ,
    double? rangeGyroBackCoordX,
    double? rangeGyroBackCoordY,
    double? rangeGyroBackCoordZ,
    double? rangeAccUpCoordX,
    double? rangeAccUpCoordY,
    double? rangeAccUpCoordZ,
    double? rangeGyroUpCoordX,
    double? rangeGyroUpCoordY,
    double? rangeGyroUpCoordZ,
  }) =>
      Repetition(
        id: id ?? this.id,
        isHealthy: isHealthy ?? this.isHealthy,
        rangeAngularUp: rangeAngularUp ?? this.rangeAngularUp,
        scoreId: scoreId ?? this.scoreId,
        rangeAccBackCoordX: rangeAccBackCoordX ?? this.rangeAccBackCoordX,
        rangeAccBackCoordY: rangeAccBackCoordY ?? this.rangeAccBackCoordY,
        rangeAccBackCoordZ: rangeAccBackCoordZ ?? this.rangeAccBackCoordZ,
        rangeGyroBackCoordX: rangeGyroBackCoordX ?? this.rangeGyroBackCoordX,
        rangeGyroBackCoordY: rangeGyroBackCoordY ?? this.rangeGyroBackCoordY,
        rangeGyroBackCoordZ: rangeGyroBackCoordZ ?? this.rangeGyroBackCoordZ,
        rangeAccUpCoordX: rangeAccUpCoordX ?? this.rangeAccUpCoordX,
        rangeAccUpCoordY: rangeAccUpCoordY ?? this.rangeAccUpCoordY,
        rangeAccUpCoordZ: rangeAccUpCoordZ ?? this.rangeAccUpCoordZ,
        rangeGyroUpCoordX: rangeGyroUpCoordX ?? this.rangeGyroUpCoordX,
        rangeGyroUpCoordY: rangeGyroUpCoordY ?? this.rangeGyroUpCoordY,
        rangeGyroUpCoordZ: rangeGyroUpCoordZ ?? this.rangeGyroUpCoordZ,
      );
}
