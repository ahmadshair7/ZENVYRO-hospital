import 'package:uuid/uuid.dart';

class DispensedMedicine {
  final String name;
  final String type; // Tablet, Capsule, Injection, etc.
  final int quantity;
  final double pricePerUnit;
  final double totalPrice;

  DispensedMedicine({
    required this.name,
    required this.type,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'quantity': quantity,
    'pricePerUnit': pricePerUnit,
    'totalPrice': totalPrice,
  };

  factory DispensedMedicine.fromJson(Map<String, dynamic> json) => DispensedMedicine(
    name: json['name'],
    type: json['type'],
    quantity: json['quantity'],
    pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
    totalPrice: (json['totalPrice'] as num).toDouble(),
  );
}

class PharmacyBill {
  final String id;
  final String patientId;
  final String patientName;
  final String patientAge;
  final String patientMobile;
  final String source; // OPD, Emergency, Indoor
  final List<DispensedMedicine> medicines;
  final DateTime date;
  final double grandTotal;

  PharmacyBill({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientMobile,
    required this.source,
    required this.medicines,
    required this.date,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'patientAge': patientAge,
    'patientMobile': patientMobile,
    'source': source,
    'medicines': medicines.map((m) => m.toJson()).toList(),
    'date': date.toIso8601String(),
    'grandTotal': grandTotal,
  };

  factory PharmacyBill.fromJson(Map<String, dynamic> json) => PharmacyBill(
    id: json['id'],
    patientId: json['patientId'],
    patientName: json['patientName'],
    patientAge: json['patientAge'],
    patientMobile: json['patientMobile'],
    source: json['source'],
    medicines: (json['medicines'] as List).map((m) => DispensedMedicine.fromJson(m)).toList(),
    date: DateTime.parse(json['date']),
    grandTotal: (json['grandTotal'] as num).toDouble(),
  );

  static String generateId() => const Uuid().v4();
}
