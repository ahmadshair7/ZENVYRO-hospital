import 'package:flutter/material.dart';

class DoctorCategory {
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  DoctorCategory({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}

class Consultation {
  final DateTime date;
  final String complaint;
  final String diagnosis; // Added diagnosis
  final String vitals;
  final List<String> medicines;
  final bool isDispensed;

  Consultation({
    required this.date,
    required this.complaint,
    required this.diagnosis,
    required this.vitals,
    required this.medicines,
    this.isDispensed = false,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'complaint': complaint,
    'diagnosis': diagnosis,
    'vitals': vitals,
    'medicines': medicines,
    'isDispensed': isDispensed,
  };

  factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
    date: DateTime.parse(json['date']),
    complaint: json['complaint'] ?? '',
    diagnosis: json['diagnosis'] ?? '',
    vitals: json['vitals'] ?? '',
    medicines: List<String>.from(json['medicines'] ?? []),
    isDispensed: json['isDispensed'] ?? false,
  );
}

class Patient {
  final String id;
  final String name;
  final String age;
  final String mobile;
  final String categoryName;
  final String status;
  final int tokenNumber; // Added tokenNumber
  final String? sex;
  final String? emergencyCategory;
  final String? triagePriority;
  final String? registrationDate;
  final String? registrationTime;
  final String? initialComplaint;
  final String? emergencyMedicines;
  final String? otDate;
  final String? otTime;
  final String? otName;
  final bool isReferredToIndoor;
  final bool isReferredToEmergency;
  final bool isEmergencyMedicinesDispensed;
  final String? dischargeMedicines;
  final bool isDischargeMedicinesDispensed;
  final List<Consultation> history;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.mobile,
    required this.categoryName,
    required this.tokenNumber,
    this.status = 'Pending',
    this.sex,
    this.emergencyCategory,
    this.triagePriority,
    this.registrationDate,
    this.registrationTime,
    this.initialComplaint,
    this.emergencyMedicines,
    this.otDate,
    this.otTime,
    this.otName,
    this.isReferredToIndoor = false,
    this.isReferredToEmergency = false,
    this.isEmergencyMedicinesDispensed = false,
    this.dischargeMedicines,
    this.isDischargeMedicinesDispensed = false,
    this.history = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'mobile': mobile,
    'categoryName': categoryName,
    'status': status,
    'tokenNumber': tokenNumber,
    'sex': sex,
    'emergencyCategory': emergencyCategory,
    'triagePriority': triagePriority,
    'registrationDate': registrationDate,
    'registrationTime': registrationTime,
    'initialComplaint': initialComplaint,
    'emergencyMedicines': emergencyMedicines,
    'otDate': otDate,
    'otTime': otTime,
    'otName': otName,
    'isReferredToIndoor': isReferredToIndoor,
    'isReferredToEmergency': isReferredToEmergency,
    'isEmergencyMedicinesDispensed': isEmergencyMedicinesDispensed,
    'dischargeMedicines': dischargeMedicines,
    'isDischargeMedicinesDispensed': isDischargeMedicinesDispensed,
    'history': history.map((c) => c.toJson()).toList(),
  };

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    mobile: json['mobile'],
    categoryName: json['categoryName'],
    tokenNumber: json['tokenNumber'] ?? 0,
    status: json['status'] ?? 'Pending',
    sex: json['sex'],
    emergencyCategory: json['emergencyCategory'],
    triagePriority: json['triagePriority'],
    registrationDate: json['registrationDate'],
    registrationTime: json['registrationTime'],
    initialComplaint: json['initialComplaint'],
    emergencyMedicines: json['emergencyMedicines'],
    otDate: json['otDate'],
    otTime: json['otTime'],
    otName: json['otName'],
    isReferredToIndoor: json['isReferredToIndoor'] ?? false,
    isReferredToEmergency: json['isReferredToEmergency'] ?? false,
    isEmergencyMedicinesDispensed: json['isEmergencyMedicinesDispensed'] ?? false,
    dischargeMedicines: json['dischargeMedicines'],
    isDischargeMedicinesDispensed: json['isDischargeMedicinesDispensed'] ?? false,
    history: (json['history'] as List?)
            ?.map((c) => Consultation.fromJson(c))
            .toList() ?? [],
  );

  Patient copyWith({
    String? name,
    String? age,
    String? mobile,
    String? status,
    int? tokenNumber,
    String? sex,
    String? emergencyCategory,
    String? triagePriority,
    String? registrationDate,
    String? registrationTime,
    String? initialComplaint,
    String? emergencyMedicines,
    String? otDate,
    String? otTime,
    String? otName,
    bool? isReferredToIndoor,
    bool? isReferredToEmergency,
    bool? isEmergencyMedicinesDispensed,
    String? dischargeMedicines,
    bool? isDischargeMedicinesDispensed,
    List<Consultation>? history,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      mobile: mobile ?? this.mobile,
      categoryName: categoryName,
      status: status ?? this.status,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      sex: sex ?? this.sex,
      emergencyCategory: emergencyCategory ?? this.emergencyCategory,
      triagePriority: triagePriority ?? this.triagePriority,
      registrationDate: registrationDate ?? this.registrationDate,
      registrationTime: registrationTime ?? this.registrationTime,
      initialComplaint: initialComplaint ?? this.initialComplaint,
      emergencyMedicines: emergencyMedicines ?? this.emergencyMedicines,
      otDate: otDate ?? this.otDate,
      otTime: otTime ?? this.otTime,
      otName: otName ?? this.otName,
      isReferredToIndoor: isReferredToIndoor ?? this.isReferredToIndoor,
      isReferredToEmergency: isReferredToEmergency ?? this.isReferredToEmergency,
      isEmergencyMedicinesDispensed: isEmergencyMedicinesDispensed ?? this.isEmergencyMedicinesDispensed,
      dischargeMedicines: dischargeMedicines ?? this.dischargeMedicines,
      isDischargeMedicinesDispensed: isDischargeMedicinesDispensed ?? this.isDischargeMedicinesDispensed,
      history: history ?? this.history,
    );
  }
}

class TokenManager {
  static int _globalTokenCount = 0; // Centralized count

  static void setTokens(int count) {
    _globalTokenCount = count;
  }

  static int getNextToken() {
    _globalTokenCount++;
    return _globalTokenCount;
  }

  static int getTokens() => _globalTokenCount;
}

class EmergencyTokenManager {
  static int _emergencyTokenCount = 0;

  static void setTokens(int count) {
    _emergencyTokenCount = count;
  }

  static int getNextToken() {
    _emergencyTokenCount++;
    return _emergencyTokenCount;
  }

  static int getTokens() => _emergencyTokenCount;
}

final List<DoctorCategory> opdCategories = [
  DoctorCategory(
    name: 'Surgeon',
    icon: Icons.medical_services_rounded,
    description: 'Expert surgical consultations and minor procedures.',
    color: Colors.redAccent,
  ),
  DoctorCategory(
    name: 'Orthopedic',
    icon: Icons.healing_rounded,
    description: 'Specialized care for bones, joints, and ligaments.',
    color: Colors.orangeAccent,
  ),
  DoctorCategory(
    name: 'Medical',
    icon: Icons.local_hospital_rounded,
    description: 'General medicine and comprehensive health check-ups.',
    color: Colors.blueAccent,
  ),
  DoctorCategory(
    name: 'Child Specialist',
    icon: Icons.baby_changing_station_rounded,
    description: 'Compassionate pediatric care for infants and children.',
    color: Colors.lightBlueAccent,
  ),
  DoctorCategory(
    name: 'Gynecologist',
    icon: Icons.female_rounded,
    description: 'Women\'s health, maternity, and prenatal services.',
    color: Colors.pinkAccent,
  ),
  DoctorCategory(
    name: 'Psychologist',
    icon: Icons.psychology_alt_rounded,
    description: 'Professional counseling and mental health support.',
    color: Colors.purpleAccent,
  ),
  DoctorCategory(
    name: 'Physiotherapist',
    icon: Icons.accessibility_new_rounded,
    description: 'Physical therapy, recovery, and rehabilitation.',
    color: Colors.greenAccent,
  ),
  DoctorCategory(
    name: 'Cardiologist',
    icon: Icons.favorite_rounded,
    description: 'Advanced heart care and cardiovascular diagnostics.',
    color: Colors.red,
  ),
  DoctorCategory(
    name: 'NCD Clinic',
    icon: Icons.monitor_heart_rounded,
    description: 'Chronic disease management and wellness clinic.',
    color: Colors.tealAccent,
  ),
];
