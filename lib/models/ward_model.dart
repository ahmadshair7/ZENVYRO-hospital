import 'package:flutter/material.dart';

class Bed {
  final String id;
  bool isOccupied;
  String? patientId;
  String? patientName;
  String? patientAge;
  String? patientSex;
  String? registrationDate;
  String? registrationTime;
  String? triagePriority;
  String? administeredMedicines;
  String? medicalHistory;
  String? admissionDate;
  String? admissionTime;
  String? otDate;
  String? otTime;
  String? inpatientMedicines; // Added for ward medicine tracking
  bool isInpatientMedicinesDispensed;
  final List<String> assignedStaffIds;

  Bed({
    required this.id,
    this.isOccupied = false,
    this.patientId,
    this.patientName,
    this.patientAge,
    this.patientSex,
    this.registrationDate,
    this.registrationTime,
    this.triagePriority,
    this.administeredMedicines,
    this.medicalHistory,
    this.admissionDate,
    this.admissionTime,
    this.otDate,
    this.otTime,
    this.inpatientMedicines,
    this.isInpatientMedicinesDispensed = false,
    this.assignedStaffIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isOccupied': isOccupied,
        'patientId': patientId,
        'patientName': patientName,
        'patientAge': patientAge,
        'patientSex': patientSex,
        'registrationDate': registrationDate,
        'registrationTime': registrationTime,
        'triagePriority': triagePriority,
        'administeredMedicines': administeredMedicines,
        'medicalHistory': medicalHistory,
        'admissionDate': admissionDate,
        'admissionTime': admissionTime,
        'otDate': otDate,
        'otTime': otTime,
        'inpatientMedicines': inpatientMedicines,
        'isInpatientMedicinesDispensed': isInpatientMedicinesDispensed,
        'assignedStaffIds': assignedStaffIds,
      };

  factory Bed.fromJson(Map<String, dynamic> json) => Bed(
        id: json['id'],
        isOccupied: json['isOccupied'] ?? false,
        patientId: json['patientId'],
        patientName: json['patientName'],
        patientAge: json['patientAge'],
        patientSex: json['patientSex'],
        registrationDate: json['registrationDate'],
        registrationTime: json['registrationTime'],
        triagePriority: json['triagePriority'],
        administeredMedicines: json['administeredMedicines'],
        medicalHistory: json['medicalHistory'],
        admissionDate: json['admissionDate'],
        admissionTime: json['admissionTime'],
        otDate: json['otDate'],
        otTime: json['otTime'],
        inpatientMedicines: json['inpatientMedicines'],
        isInpatientMedicinesDispensed: json['isInpatientMedicinesDispensed'] ?? false,
        assignedStaffIds: List<String>.from(json['assignedStaffIds'] ?? []),
      );
}

class Ward {
  final String name;
  final IconData icon;
  final Color color;
  final List<Bed> beds;

  Ward({
    required this.name,
    required this.icon,
    required this.color,
    required this.beds,
  });

  int get occupiedBedsCount => beds.where((bed) => bed.isOccupied).length;
  int get availableBedsCount => beds.length - occupiedBedsCount;

  Map<String, dynamic> toJson() => {
        'name': name,
        'beds': beds.map((b) => b.toJson()).toList(),
      };

  factory Ward.fromJson(Map<String, dynamic> json, Ward template) {
    final List<dynamic> bedsData = json['beds'] ?? [];
    return Ward(
      name: template.name,
      icon: template.icon,
      color: template.color,
      beds: bedsData.map((b) => Bed.fromJson(b)).toList(),
    );
  }
}

final List<Ward> predefinedWards = [
  Ward(
    name: 'Pediatrics Ward',
    icon: Icons.baby_changing_station_rounded,
    color: Colors.lightBlueAccent,
    beds: List.generate(15, (i) => Bed(id: 'PED-${i + 1}')),
  ),
  Ward(
    name: 'Gynecology Ward',
    icon: Icons.female_rounded,
    color: Colors.pinkAccent,
    beds: List.generate(15, (i) => Bed(id: 'GYN-${i + 1}')),
  ),
  Ward(
    name: 'Pulmonology Ward',
    icon: Icons.air_rounded,
    color: Colors.blueGrey,
    beds: List.generate(15, (i) => Bed(id: 'PUL-${i + 1}')),
  ),
  Ward(
    name: 'Male Medical Ward',
    icon: Icons.man_rounded,
    color: Colors.blue,
    beds: List.generate(15, (i) => Bed(id: 'MMW-${i + 1}')),
  ),
  Ward(
    name: 'Female Medical Ward',
    icon: Icons.woman_rounded,
    color: Colors.pink,
    beds: List.generate(15, (i) => Bed(id: 'FMW-${i + 1}')),
  ),
  Ward(
    name: 'Surgical Ward',
    icon: Icons.medical_services_rounded,
    color: Colors.redAccent,
    beds: List.generate(15, (i) => Bed(id: 'SUR-${i + 1}')),
  ),
  Ward(
    name: 'Orthopedic Ward',
    icon: Icons.healing_rounded,
    color: Colors.orangeAccent,
    beds: List.generate(15, (i) => Bed(id: 'ORT-${i + 1}')),
  ),
  Ward(
    name: 'CCU (Cardiac Care Unit)',
    icon: Icons.favorite_rounded,
    color: Colors.red,
    beds: List.generate(15, (i) => Bed(id: 'CCU-${i + 1}')),
  ),
  Ward(
    name: 'ICU (Intensive Care Unit)',
    icon: Icons.emergency_rounded,
    color: Colors.deepOrange,
    beds: List.generate(15, (i) => Bed(id: 'ICU-${i + 1}')),
  ),
];

final List<Ward> emergencyUnits = [
  Ward(
    name: 'Triage',
    icon: Icons.assignment_ind_rounded,
    color: Colors.redAccent,
    beds: List.generate(5, (i) => Bed(id: 'TR-${i + 1}')),
  ),
  Ward(
    name: 'Main Emergency',
    icon: Icons.emergency_rounded,
    color: Colors.red,
    beds: List.generate(20, (i) => Bed(id: 'ER-${i + 1}')),
  ),
];

final List<Ward> operationTheaters = [
  Ward(
    name: 'Main OT (General)',
    icon: Icons.personal_video_rounded,
    color: Colors.deepPurple,
    beds: [Bed(id: 'OT-Main')],
  ),
  Ward(
    name: 'Orthopedic OT',
    icon: Icons.hardware_rounded,
    color: Colors.orange,
    beds: [Bed(id: 'OT-Ortho')],
  ),
  Ward(
    name: 'Cardiac OT',
    icon: Icons.monitor_heart_rounded,
    color: Colors.red,
    beds: [Bed(id: 'OT-Cardiac')],
  ),
  Ward(
    name: 'Gynecology OT',
    icon: Icons.female_rounded,
    color: Colors.pink,
    beds: [Bed(id: 'OT-Gynae')],
  ),
  Ward(
    name: 'Eye / ENT OT',
    icon: Icons.visibility_rounded,
    color: Colors.blue,
    beds: [Bed(id: 'OT-Eye')],
  ),
];
