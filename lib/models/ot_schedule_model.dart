
class OTSchedule {
  final String id;
  final String patientId;
  final String patientName;
  final String patientAge;
  final String? patientSex;
  final String otRoom;
  final String date; // DD-MM-YYYY
  final String time; // HH:mm
  final String medicalHistory;
  final String estimatedDuration;
  final String scheduledBy; // Doctor Category or Name
  final String status; // Pending, Active, Completed

  OTSchedule({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    this.patientSex,
    required this.otRoom,
    required this.date,
    required this.time,
    required this.medicalHistory,
    required this.estimatedDuration,
    required this.scheduledBy,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'patientAge': patientAge,
    'patientSex': patientSex,
    'otRoom': otRoom,
    'date': date,
    'time': time,
    'medicalHistory': medicalHistory,
    'estimatedDuration': estimatedDuration,
    'scheduledBy': scheduledBy,
    'status': status,
  };

  factory OTSchedule.fromJson(Map<String, dynamic> json) => OTSchedule(
    id: json['id'],
    patientId: json['patientId'],
    patientName: json['patientName'],
    patientAge: json['patientAge'],
    patientSex: json['patientSex'],
    otRoom: json['otRoom'],
    date: json['date'],
    time: json['time'],
    medicalHistory: json['medicalHistory'] ?? '',
    estimatedDuration: json['estimatedDuration'] ?? '',
    scheduledBy: json['scheduledBy'] ?? '',
    status: json['status'] ?? 'Pending',
  );
}
